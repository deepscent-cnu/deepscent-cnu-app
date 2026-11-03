import 'package:deepscent_cnu/common/data/device_api.dart';
import 'package:deepscent_cnu/common/widgets/button_basic.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/data/models/correct_scent.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/controllers/normal_olfactory_training_controller.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/screens/normal_olfactory_training_question.dart';
import 'package:deepscent_cnu/common/widgets/custom_app_bar.dart';
import 'package:deepscent_cnu/features/training_list/presentation/screens/olfactory_training_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NormalOlfactoryTrainingScreen extends StatefulWidget {
  const NormalOlfactoryTrainingScreen({super.key});

  @override
  State<NormalOlfactoryTrainingScreen> createState() =>
      _NormalOlfactoryTrainingScreenState();
}

class _NormalOlfactoryTrainingScreenState
    extends State<NormalOlfactoryTrainingScreen> {
  final normalOlfactoryTrainingController =
      Get.find<NormalOlfactoryTrainingController>();
  int remainTime = 10;
  bool isStopped = false;
  bool isPaused = false;
  bool _isScentStopped = false;
  bool _isStoppingScent = false;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    startTrainingCycle();
  }

  //수정
  // Future<void> getCorrectScentList() async {
  //   List<CorrectScent>? correctScentList =
  //       await NormalOlfactoryTrainingApi.getCorrectScentList();
  //   normalOlfactoryTrainingController.addCorrectScentList(correctScentList!);
  // }

  Future<void> startTrainingCycle() async {
    //기존
    // await getCorrectScentList();
    // isStopped = false;

    //수정
    setState(() {
      remainTime = 10; // ✅ 라운드 시작마다 초기화 (지금 코드엔 이게 없어서 다음 라운드에서 문제 생김)
      isStopped = false;
      isPaused = false;
      _isScentStopped = false;
      _isStoppingScent = false;
      _isTransitioning = false;
    });

    CorrectScent correctScent =
        normalOlfactoryTrainingController.getCorrectScentByRound();

    await DeviceApi.controlScentDeviceSlot(
      correctScent.deviceNumber,
      correctScent.fanNumber,
      3,
    );
    while (remainTime > 0) {
      await Future.delayed(const Duration(seconds: 1));

      if (isStopped || !mounted) return;

      if (!isPaused) {
        setState(() {
          remainTime -= 1;
        });
      }
    }

    if (!isStopped && mounted) {
      await _stopScentOnly();
    }
  }

  Future<void> _stopScentOnly() async {
    if (_isScentStopped || _isStoppingScent) return;

    setState(() {
      _isStoppingScent = true;
    });

    final correctScent =
        normalOlfactoryTrainingController.getCorrectScentByRound();

    try {
      await DeviceApi.controlScentDeviceSlot(
        correctScent.deviceNumber,
        correctScent.fanNumber,
        0,
      ).timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('(Debug) 발향 중지 요청 중 오류 발생: $e');
    }

    if (!mounted) return;

    setState(() {
      _isScentStopped = true;
      _isStoppingScent = false;
    });
  }

  Future<void> _openQuestion() async {
    if (_isTransitioning || _isStoppingScent) return;

    setState(() {
      _isTransitioning = true;
      isStopped = true;
      isPaused = false;
    });

    await _stopScentOnly();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => NormalOlfactoryTrainingQuestionScreen(),
      ),
    );
  }

  Future<void> stopTrainingCycle() async {
    setState(() {
      isStopped = true;
      isPaused = false;
    });
    CorrectScent correctScent =
        normalOlfactoryTrainingController.getCorrectScentByRound();

    await DeviceApi.controlScentDeviceSlot(
      correctScent.deviceNumber,
      correctScent.fanNumber,
      0,
    );

    if (!mounted) return;

    normalOlfactoryTrainingController.reset();
    Get.offAll(() => const OlfactoryTrainingListScreen());
  }

  void showTrainingStopModal(BuildContext context) async {
    if (_isTransitioning || _isStoppingScent) return;

    setState(() {
      isPaused = true;
    });

    final result = await showDialog(
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
                                function:
                                    () => {
                                      Navigator.pop(context),
                                      setState(() {
                                        isPaused = false;
                                      }),
                                    },
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
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (result == null && mounted) {
      setState(() {
        isPaused = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false, // 기본 pop 동작 차단
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          showTrainingStopModal(context); // 시스템 뒤로가기 누르면 모달 띄움
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          mode: CustomAppBarMode.sub,
          title: "일반 후각 훈련",
          onBackPressed: () {
            showTrainingStopModal(context);
          },
        ),
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
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
                    Center(
                      child: Text(
                        _isScentStopped
                            ? '${normalOlfactoryTrainingController.currentRound.value} 번째 향 발향이 끝났습니다.'
                            : '${normalOlfactoryTrainingController.currentRound.value} 번째 향을 발향 중입니다.\n향을 집중해서 맡아보세요!',
                        style: TextStyle(
                          fontSize: screenWidth * 0.07,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isScentStopped) ...[
                              Icon(
                                Icons.check_circle_outline,
                                size: screenWidth * 0.25,
                                color: const Color(0xFF4F7F68),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                '아래 버튼을 눌러\n다음 문제로 진행해주세요.',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.07,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ] else ...[
                              Text(
                                remainTime.toString(),
                                style: TextStyle(
                                  fontSize: screenWidth * 0.3,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '초 뒤, 발향이 중지됩니다.',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.07,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: screenWidth * 0.07,
                        right: screenWidth * 0.07,
                        bottom: screenWidth * 0.06,
                      ),
                      child: ButtonBasic(
                        content:
                            _isTransitioning
                                ? '이동 중...'
                                : _isStoppingScent
                                ? '발향 중지 중...'
                                : _isScentStopped
                                ? '다음 문제로'
                                : '테스트용 건너뛰기',
                        icon: Icon(
                          _isScentStopped
                              ? Icons.arrow_forward
                              : Icons.fast_forward,
                          size: screenWidth * 0.06,
                        ),
                        fontSize: screenWidth * 0.05,
                        function:
                            _isTransitioning || _isStoppingScent
                                ? null
                                : _openQuestion,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
