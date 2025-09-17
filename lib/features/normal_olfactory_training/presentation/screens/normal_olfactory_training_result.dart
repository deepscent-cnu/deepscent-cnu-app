import 'package:deepscent_cnu/common/widgets/button_basic.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/controllers/normal_olfactory_training_controller.dart';
import 'package:deepscent_cnu/common/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NormalOlfactoryTrainingResultScreen extends StatelessWidget {
  final normalOlfactoryTrainingController =
      Get.find<NormalOlfactoryTrainingController>();

  NormalOlfactoryTrainingResultScreen({super.key});

  void returnTrainingList(BuildContext context) {
    normalOlfactoryTrainingController.reset();
    Navigator.pop(context);
  }

  String displaySelectedOption(String selectedOption) {
    return selectedOption.isEmpty ? "모름" : selectedOption;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        mode: CustomAppBarMode.sub,
        title: "일반 후각 훈련",
        onBackPressed: () {
          returnTrainingList(context);
        },
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/blurred_background_2.png',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      '훈련이 끝났어요!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      '총 점수',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF335928),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '4개의 향기 중, ${normalOlfactoryTrainingController.totalScore}개의 향기를 맞추었어요!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 48),
                    const Text(
                      '답안지',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF335928),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        resultLabel(
                          context,
                          isCorrect:
                              normalOlfactoryTrainingController
                                  .logs[0]
                                  .isCorrect,
                        ),
                        const SizedBox(width: 32),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '정답: ${normalOlfactoryTrainingController.logs[0].correctOption}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '선택: ${displaySelectedOption(normalOlfactoryTrainingController.logs[0].selectedOption)}',
                              style: TextStyle(fontSize: 28),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        resultLabel(
                          context,
                          isCorrect:
                              normalOlfactoryTrainingController
                                  .logs[1]
                                  .isCorrect,
                        ),
                        const SizedBox(width: 32),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '정답: ${normalOlfactoryTrainingController.logs[1].correctOption}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '선택: ${displaySelectedOption(normalOlfactoryTrainingController.logs[1].selectedOption)}',
                              style: TextStyle(fontSize: 28),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        resultLabel(
                          context,
                          isCorrect:
                              normalOlfactoryTrainingController
                                  .logs[2]
                                  .isCorrect,
                        ),
                        const SizedBox(width: 32),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '정답: ${normalOlfactoryTrainingController.logs[2].correctOption}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '선택: ${displaySelectedOption(normalOlfactoryTrainingController.logs[2].selectedOption)}',
                              style: TextStyle(fontSize: 28),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        resultLabel(
                          context,
                          isCorrect:
                              normalOlfactoryTrainingController
                                  .logs[3]
                                  .isCorrect,
                        ),
                        const SizedBox(width: 32),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '정답: ${normalOlfactoryTrainingController.logs[3].correctOption}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '선택: ${displaySelectedOption(normalOlfactoryTrainingController.logs[3].selectedOption)}',
                              style: TextStyle(fontSize: 28),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    const Text(
                      '문제 풀이에 소요된 총 시간',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF335928),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${normalOlfactoryTrainingController.totalTimeTaken ~/ 60}분 ${normalOlfactoryTrainingController.totalTimeTaken % 60}초',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 32,
                    //     vertical: 16,
                    //   ),
                    //   child: ButtonBasic(
                    //     content: '훈련 기록 보기',
                    //     fontSize: 30,
                    //     icon: Icon(Icons.edit_document, size: 32),
                    //     function: () {},
                    //   ),
                    // ),
                    // const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      child: ButtonBasic(
                        content: '홈으로 돌아가기',
                        fontSize: 28,
                        icon: Icon(Icons.list, size: 32),
                        function: () => returnTrainingList(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget resultLabel(BuildContext context, {required bool isCorrect}) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color:
            isCorrect ? Color.fromARGB(255, 101, 176, 80) : Color(0xFFFF5353),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        isCorrect ? 'O' : 'X',
        style: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
