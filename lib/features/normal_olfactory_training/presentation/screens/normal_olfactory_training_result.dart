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
    return selectedOption.isEmpty || selectedOption == "잘 모르겠어요"
        ? "모름"
        : selectedOption;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
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
                    SizedBox(height: screenWidth * 0.05),
                    Text(
                      '훈련이 끝났어요!',
                      style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.07),
                    Text(
                      '총 점수',
                      style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF335928),
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.01),
                    Text(
                      '4개의 향기 중, ${normalOlfactoryTrainingController.totalScore}개의 향기를 맞추었어요!',
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.08),
                    Text(
                      '답안지',
                      style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF335928),
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.05),
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
                        SizedBox(width: screenWidth * 0.07),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '정답: ${normalOlfactoryTrainingController.logs[0].correctOption}',
                              style: TextStyle(
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Text(
                              '선택: ${displaySelectedOption(normalOlfactoryTrainingController.logs[0].selectedOption)}',
                              style: TextStyle(fontSize: screenWidth * 0.06),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: screenWidth * 0.05),
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
                        SizedBox(width: screenWidth * 0.07),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '정답: ${normalOlfactoryTrainingController.logs[1].correctOption}',
                              style: TextStyle(
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Text(
                              '선택: ${displaySelectedOption(normalOlfactoryTrainingController.logs[1].selectedOption)}',
                              style: TextStyle(fontSize: screenWidth * 0.06),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: screenWidth * 0.05),
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
                        SizedBox(width: screenWidth * 0.07),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '정답: ${normalOlfactoryTrainingController.logs[2].correctOption}',
                              style: TextStyle(
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Text(
                              '선택: ${displaySelectedOption(normalOlfactoryTrainingController.logs[2].selectedOption)}',
                              style: TextStyle(fontSize: screenWidth * 0.06),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: screenWidth * 0.05),
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
                        SizedBox(width: screenWidth * 0.07),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '정답: ${normalOlfactoryTrainingController.logs[3].correctOption}',
                              style: TextStyle(
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Text(
                              '선택: ${displaySelectedOption(normalOlfactoryTrainingController.logs[3].selectedOption)}',
                              style: TextStyle(fontSize: screenWidth * 0.06),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: screenWidth * 0.09),
                    Text(
                      '문제 풀이에 소요된 총 시간',
                      style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF335928),
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.008),
                    Text(
                      '${normalOlfactoryTrainingController.totalTimeTaken ~/ 60}분 ${normalOlfactoryTrainingController.totalTimeTaken % 60}초',
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.09),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.07,
                        vertical: screenWidth * 0.035,
                      ),
                      child: ButtonBasic(
                        content: '홈으로 돌아가기',
                        fontSize: screenWidth * 0.06,
                        icon: Icon(Icons.list, size: screenWidth * 0.07),
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
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.14,
      height: screenWidth * 0.14,
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
          fontSize: screenWidth * 0.07,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
