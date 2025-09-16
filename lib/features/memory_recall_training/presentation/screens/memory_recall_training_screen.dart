import 'package:deepscent_cnu/common/data/device_api.dart';
import 'package:deepscent_cnu/common/widgets/button_basic.dart';
import 'package:deepscent_cnu/features/memory_recall_training/data/memory_recall_training_api.dart';
import 'package:deepscent_cnu/features/memory_recall_training/presentation/controllers/memory_recall_training_controller.dart';
import 'package:deepscent_cnu/features/training_list/presentation/screens/olfactory_training_list.dart';
import 'package:deepscent_cnu/features/memory_recall_training/presentation/screens/memory_recall_chat_screen.dart';
import 'package:deepscent_cnu/common/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemoryRecallTrainingScreen extends StatefulWidget {
  final int sessionIndex; // 회차
  final String selectedScent; // 선택된 향

  const MemoryRecallTrainingScreen({
    super.key,
    required this.sessionIndex,
    required this.selectedScent,
  });

  @override
  State<MemoryRecallTrainingScreen> createState() =>
      MemoryRecallTrainingScreenState();
}

class MemoryRecallTrainingScreenState
    extends State<MemoryRecallTrainingScreen> {
  final memoryRecallTrainingController =
      Get.find<MemoryRecallTrainingController>();
  int remainTime = 10;
  String message = "초 뒤, 발향이 중지됩니다.";
  bool isStopped = false;
  bool showHelp = false;

  void toggleHelp() {
    setState(() {
      showHelp = !showHelp;
    });
  }

  @override
  void initState() {
    super.initState();
    startTrainingCycle();
  }

  Future<void> startTrainingCycle() async {
    isStopped = false;
    int deviceNumber = memoryRecallTrainingController.deviceNumber;
    int fanNumber = memoryRecallTrainingController.fanNumber;
    await DeviceApi.controlScentDeviceSlot(deviceNumber, fanNumber, 3);
    await Future.delayed(const Duration(seconds: 1));

    while (remainTime > 1) {
      if (isStopped) {
        return;
      }

      setState(() {
        remainTime -= 1;
      });

      await Future.delayed(const Duration(seconds: 1));
    }

    if (!isStopped && context.mounted) {
      await DeviceApi.controlScentDeviceSlot(deviceNumber, fanNumber, 0);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => MemoryRecallChatScreen(
                sessionIndex: widget.sessionIndex,
                selectedScent: widget.selectedScent,
              ),
        ),
      );
    }
  }

  Future<void> stopTrainingCycle() async {
    isStopped = true;
    int deviceNumber = memoryRecallTrainingController.deviceNumber;
    int fanNumber = memoryRecallTrainingController.fanNumber;
    await DeviceApi.controlScentDeviceSlot(deviceNumber, fanNumber, 0);
    await MemoryRecallTrainingApi.deleteMemoryRecallRoundLog(
      memoryRecallTrainingController.roundId,
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OlfactoryTrainingListScreen()),
      (route) => false,
    );
  }

  void extendTime() {
    setState(() {
      remainTime += 10;
    });
  }

  void showTrainingCarouselModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          // 둥근 모양의 다이얼로그 박스
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: 300, // 모달 너비
                height: 450, // 모달 높이
                child: Column(
                  children: [
                    Expanded(
                      // 남은 영역을 PageView로 채움 (좌우로 넘길 수 있는 영역)
                      child: Padding(
                        padding: const EdgeInsets.all(16.0), // 내용 여백
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center, // 세로 중앙 정렬
                          children: [
                            Text(
                              // 안내 멘트 텍스트
                              '훈련 중지를 원하시나요?',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20), // 위아래 여백
                            Text(
                              // 안내 멘트 텍스트
                              '지금까지 진행한 훈련 기록이 모두 삭제됩니다.',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            const Divider(
                              // 구분선
                              thickness: 1,
                              height: 1,
                              color: Color(0xFFE0E0E0),
                            ),
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              child: ButtonBasic(
                                content: '훈련 재개하기',
                                icon: Icon(Icons.rocket_launch, size: 20),
                                function: () => {Navigator.pop(context)},
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              child: ButtonBasic(
                                content: '훈련 끝내기',
                                icon: Icon(Icons.exit_to_app, size: 20),
                                function: stopTrainingCycle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 기본 pop 동작 차단
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          showTrainingCarouselModal(context); // 시스템 뒤로가기 누르면 모달 띄움
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          mode: CustomAppBarMode.sub,
          title: "[${widget.sessionIndex}회차] 기억 회상 훈련",
          onBackPressed: () {
            showTrainingCarouselModal(context); // 상단 뒤로가기 버튼도 동일 동작
          },
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                top: 80,
                child: Image.asset(
                  'assets/images/blurred_background.png',
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    const SizedBox(height: 16),
                    Text(
                      memoryRecallTrainingController.scentName.isNotEmpty
                          ? '${memoryRecallTrainingController.scentName} 향을 발향하는 중입니다.'
                          : '향을 발향하는 중입니다.',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              remainTime.toString(),
                              style: const TextStyle(
                                fontSize: 92,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "초 뒤, 발향이 중지됩니다.",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      child: ButtonBasic(
                        content: '시간 연장하기',
                        fontSize: 32,
                        icon: Icon(Icons.timer, size: 32),
                        function: () => extendTime(),
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
              if (showHelp)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: toggleHelp,
                    child: Container(
                      color: Colors.black.withOpacity(0.8),
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 24),
                          padding: EdgeInsets.only(
                            top: 130,
                            left: 20,
                            right: 20,
                            bottom: 20,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '남은 시간을 보여줍니다.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 12),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 30,
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFF5F2DC),
                                      Color(0xFFE7D6AC),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Color(0xFFD99A25),
                                    width: 3,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '10',
                                      style: TextStyle(
                                        fontSize: 90,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      '초 뒤, 발향이 중지됩니다.',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 40),
                              Text(
                                '버튼을 클릭해 발향 시간을\n연장할 수 있습니다.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 12),
                              SizedBox(
                                width: 250,
                                height: 50,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.timer,
                                        color: Color(0xFF335928),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '시간 연장하기',
                                        style: TextStyle(
                                          color: Color(0xFF335928),
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
