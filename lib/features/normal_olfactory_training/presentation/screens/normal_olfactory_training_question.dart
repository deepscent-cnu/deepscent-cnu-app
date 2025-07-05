import 'package:deepscent_cnu/common/widgets/button_basic.dart';
import 'package:flutter/material.dart';

class NormalOlfactoryTrainingQuestionScreen extends StatelessWidget {
  const NormalOlfactoryTrainingQuestionScreen({super.key});

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
                                function: () => {Navigator.pop(context)},
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
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          showTrainingStopModal(context);
                        },
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
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      "방금 맡은 향은 어떤 향인지\n다음 보기 중에서 골라보세요!",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 40,
                      mainAxisSpacing: 40,
                      childAspectRatio: 1,
                      children: [
                        ButtonBasic(
                          content: "백미밥",
                          fontSize: 24,
                          function: () {},
                        ),
                        ButtonBasic(
                          content: "참기름",
                          fontSize: 24,
                          function: () {},
                        ),
                        ButtonBasic(
                          content: "장미",
                          fontSize: 24,
                          function: () {},
                        ),
                        ButtonBasic(
                          content: "된장",
                          fontSize: 24,
                          function: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: ButtonBasic(content: "잘 모르겠어요", function: () {}),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
