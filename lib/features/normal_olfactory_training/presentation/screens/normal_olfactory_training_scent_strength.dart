import 'package:deepscent_cnu/common/widgets/button_basic.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/controllers/normal_olfactory_training_controller.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/screens/normal_olfactory_training_answer.dart';
import 'package:deepscent_cnu/common/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NormalOlfactoryTrainingScentStrengthScreen extends StatefulWidget {
  const NormalOlfactoryTrainingScentStrengthScreen({super.key});

  @override
  State<NormalOlfactoryTrainingScentStrengthScreen> createState() =>
      _NormalOlfactoryTrainingScentStrengthScreenState();
}

class _NormalOlfactoryTrainingScentStrengthScreenState
    extends State<NormalOlfactoryTrainingScentStrengthScreen> {
  final normalOlfactoryTrainingController =
      Get.find<NormalOlfactoryTrainingController>();

  @override
  void initState() {
    super.initState();
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
                                function:
                                    () => {
                                      normalOlfactoryTrainingController.reset(),
                                      Navigator.pop(context),
                                      Navigator.pop(context),
                                    },
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

  void goAnswerScreen(int scentStrength) {
    normalOlfactoryTrainingController.addLog(scentStrength);
    Get.off(() => NormalOlfactoryTrainingAnswerScreen());
  }

  @override
  Widget build(BuildContext context) {
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
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/blurred_background.png',
                  fit: BoxFit.cover,
                  opacity: AlwaysStoppedAnimation(0.5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        "향을 맡으셨을 때 느끼신\n강도를 선택해주세요.",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 3,
                            crossAxisSpacing: 30,
                            mainAxisSpacing: 30,
                            childAspectRatio: 1,
                            children: [
                              ButtonBasic(
                                content: "약함",
                                fontSize: 32,
                                function: () => goAnswerScreen(1),
                              ),
                              ButtonBasic(
                                content: "보통",
                                fontSize: 32,
                                function: () => goAnswerScreen(2),
                              ),
                              ButtonBasic(
                                content: "강함",
                                fontSize: 32,
                                function: () => goAnswerScreen(3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
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
