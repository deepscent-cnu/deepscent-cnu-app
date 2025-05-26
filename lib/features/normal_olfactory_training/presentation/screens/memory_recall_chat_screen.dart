import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/screens/memory_recall_result_screen.dart';
import 'package:flutter/material.dart';

class MemoryRecallChatScreen extends StatefulWidget {
  const MemoryRecallChatScreen({super.key});

  @override
  State<MemoryRecallChatScreen> createState() => _MemoryRecallChatScreenState();
}

class _MemoryRecallChatScreenState extends State<MemoryRecallChatScreen> {
  int currentIndex = 0;

  List<String> testQuestionList = [
    "방금 맡은 냄새는 어떤 향기인 것 같나요?",
    "이 향기를 맡았을 때 어떤 기분이 드셨나요?",
    "이 향기를 맡고 떠오르는 기억이나 장면이 있나요?",
  ];

  List<String> testAnswerList = [
    "음... 이 냄새는... 풀잎 냄새 같기도 하고, 어릴 때 외갓집 마당에서 맡았던 냄새랑 좀 비슷하네요. 비 오고 나면 항상 마당에서 이런 흙냄새가 났거든요. 약간 싸하면서도 상쾌한 풀냄새랄까…",
    "맡자마자 좀 편안해졌어요. 그때 외갓집 마루에 앉아서 할머니가 손톱 깎아주시던 기억이 났어요. 그때는 아무 걱정도 없고 그냥 바람이 솔솔 불었는데... 그게 생각나서 마음이 조금 차분해졌네요.",
    "응... 봄방학 때 외갓집 갔던 날이요. 그날은 비가 좀 왔었고, 비 그치고 나서 마당에서고무신 신고 뛰어다녔어요. 할머니가 고추장을 꺼내서 오이 찍어 먹으라고 주셨는데, 그때 흙냄새랑 오이냄새랑 다 섞여서... 그냥",
  ];

  void _onNextPressed() {
    if (currentIndex < testQuestionList.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MemoryRecallResultScreen()),
      );
    }
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
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.rocket_launch, size: 20),
                                label: const Text(
                                  "훈련 재개하기",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                  backgroundColor: Color(0xFFF9F9F9),
                                  foregroundColor: Color(0xFF335928),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              child: ElevatedButton.icon(
                                onPressed:
                                    () => {
                                      Navigator.pop(context),
                                      Navigator.pop(context),
                                    },
                                icon: const Icon(Icons.exit_to_app, size: 20),
                                label: const Text(
                                  "훈련 끝내기",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                  backgroundColor: Color(0xFFF9F9F9),
                                  foregroundColor: Color(0xFF335928),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
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
    final bool isLastQuestion = currentIndex == testQuestionList.length - 1;

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      showTrainingCarouselModal(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  const Text(
                    '기억 회상 훈련',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  testQuestionList[currentIndex],
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 130,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 7,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(right: 10),
                      child: Text(
                        testAnswerList[currentIndex],
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    _onNextPressed();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Color(0xFFF9F9F9),
                    foregroundColor: Color(0xFF335928),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.double_arrow),
                  label: Text(
                    isLastQuestion ? '훈련 저장하기' : '다음 질문으로',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Image.asset(
                  "assets/images/voice_recording.png",
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
