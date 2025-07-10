import 'package:deepscent_cnu/common/widgets/button_basic.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/controllers/normal_olfactory_training_controller.dart';
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
        child: Stack(
          children: [
            Positioned(
              top: 80,
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
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => returnTrainingList(context),
                          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF335928),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '4개의 향기 중, ${normalOlfactoryTrainingController.totalScore}개의 향기를 맞추었어요!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 48),
                    const Text(
                      '답안지',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF335928),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        resultLabel(context, isCorrect: normalOlfactoryTrainingController.logs[0].isCorrect),
                        const SizedBox(width: 12),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '1번',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '정답: ${normalOlfactoryTrainingController.logs[0].correctOption}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('선택: ${normalOlfactoryTrainingController.logs[0].selectedOption}', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        resultLabel(context, isCorrect: normalOlfactoryTrainingController.logs[1].isCorrect),
                        const SizedBox(width: 12),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '2번',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '정답: ${normalOlfactoryTrainingController.logs[1].correctOption}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('선택: ${normalOlfactoryTrainingController.logs[1].selectedOption}', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        resultLabel(context, isCorrect: normalOlfactoryTrainingController.logs[2].isCorrect),
                        const SizedBox(width: 12),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '3번',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '정답: ${normalOlfactoryTrainingController.logs[2].correctOption}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('선택: ${normalOlfactoryTrainingController.logs[2].selectedOption}', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        resultLabel(context, isCorrect: normalOlfactoryTrainingController.logs[3].isCorrect),
                        const SizedBox(width: 12),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '4번',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '정답: ${normalOlfactoryTrainingController.logs[3].correctOption}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('선택: ${normalOlfactoryTrainingController.logs[3].selectedOption}', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 48),
                    const Text(
                      '문제 풀이에 소요된 총 시간',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF335928),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${normalOlfactoryTrainingController.totalTimeTaken ~/ 60}분 ${normalOlfactoryTrainingController.totalTimeTaken % 60}초',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      child: ButtonBasic(
                        content: '훈련 기록 보기',
                        icon: Icon(Icons.edit_document, size: 25),
                        function: () {},
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      child: ButtonBasic(
                        content: '훈련 목록 보기',
                        icon: Icon(Icons.list, size: 30),
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
    return isCorrect
        ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Color(0xFF335928),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            '정답',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
        : Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Color(0xFFFF5353),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            '오답',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
  }
}
