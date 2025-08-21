import 'dart:math';

import 'package:deepscent_cnu/common/data/device_api.dart';
import 'package:deepscent_cnu/common/widgets/button_basic.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/data/models/round_log.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/data/normal_olfactory_training_api.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/controllers/normal_olfactory_training_controller.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/screens/normal_olfactory_training_result.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/screens/normal_olfactory_training_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NormalOlfactoryTrainingAnswerScreen extends StatefulWidget {
  const NormalOlfactoryTrainingAnswerScreen({super.key});

  @override
  State<NormalOlfactoryTrainingAnswerScreen> createState() =>
      _NormalOlfactoryTrainingAnswerScreenState();
}

class _NormalOlfactoryTrainingAnswerScreenState
    extends State<NormalOlfactoryTrainingAnswerScreen> {
  final normalOlfactoryTrainingController =
      Get.find<NormalOlfactoryTrainingController>();
  int remainTime = 20;
  String message = "초 뒤, 다른 향기가 분출됩니다.";
  bool isLoading = false;
  bool isStopped = false;

  @override
  void initState() {
    super.initState();
    isStopped = false;
    if (normalOlfactoryTrainingController.currentRound.value != 4) {
      startTrainingCycle();
    }
  }

  Future<void> startTrainingCycle() async {
    await DeviceApi.controlScentDeviceSlot(
      normalOlfactoryTrainingController.currentRound.value,
      3,
    );
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

    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      isLoading = false;
    });

    nextRound();
  }

  Future<void> stopTrainingCycle() async {
    isStopped = true;

    if (context.mounted) {
      normalOlfactoryTrainingController.reset();
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  void showTrainingStopModal(BuildContext context) {
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
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void nextRound() async {
    if (normalOlfactoryTrainingController.currentRound.value == 4) {
      var totalScore = 0;
      var totalTimeTaken = 0;

      for (RoundLog log in normalOlfactoryTrainingController.logs) {
        if (log.isCorrect) {
          totalScore++;
        }

        totalTimeTaken += log.timeTaken;
      }

      normalOlfactoryTrainingController.totalScore = totalScore;
      normalOlfactoryTrainingController.totalTimeTaken = totalTimeTaken;

      await NormalOlfactoryTrainingApi.submitTrainingLog(
        totalTimeTaken,
        normalOlfactoryTrainingController.logs.map((e) => e.toJson()).toList(),
      );

      Get.off(() => NormalOlfactoryTrainingResultScreen());
    } else {
      normalOlfactoryTrainingController.currentRound.value++;
      normalOlfactoryTrainingController.resetRound();
      Get.off(() => NormalOlfactoryTrainingScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        height: 56,
        color: Colors.grey[200],
        alignment: Alignment.center,
        child: const Text('하단 네비게이션 바', style: TextStyle(fontSize: 16)),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 120,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Image.asset(
            'assets/images/logo.png',
            width: 120,
            height: 50,
            fit: BoxFit.contain,
          ),
        ),
        actions: const [
          Icon(Icons.help_outline, color: Colors.black),
          SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child:
            isLoading
                ? Container(
                  color: Colors.black.withOpacity(0.5), // 화면 어두워짐
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          '로딩 중...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
                : Stack(
                  children: [
                    Positioned(
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
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  showTrainingStopModal(context);
                                },
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 20,
                                ),
                              ),
                              const Text(
                                '일반 후각 훈련',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              '${normalOlfactoryTrainingController.isCorrect ? "맞았어요!" : "앗, 아쉬워요!"} 방금 맡은 향은\n${normalOlfactoryTrainingController.correctOption} 향이었습니다.',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          normalOlfactoryTrainingController
                                      .currentRound
                                      .value !=
                                  4
                              ? Expanded(
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
                                      Text(
                                        message,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              : Expanded(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    child: ButtonBasic(
                                      content: "훈련 결과 보기",
                                      icon: Icon(Icons.double_arrow),
                                      function: nextRound,
                                    ),
                                  ),
                                ),
                              ),
                          normalOlfactoryTrainingController
                                      .currentRound
                                      .value !=
                                  4
                              ? Column(
                                children: [
                                  const SizedBox(height: 5),
                                  Text(
                                    "다음 단계를 위해, 표시된 시간 동안 편안하게 휴식해주세요!",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF335928),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 100),
                                ],
                              )
                              : SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
