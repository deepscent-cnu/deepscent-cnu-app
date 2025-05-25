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

  @override
  Widget build(BuildContext context) {
    final bool isLastQuestion = currentIndex == testQuestionList.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFF1F1F1),
        child: SizedBox(
          height: 60,
          child: Center(
            child: Text('하단 네비게이션 바', style: TextStyle(color: Colors.black54)),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8,
              ),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back),
                  const SizedBox(width: 8),
                  Text(
                    'deepscent',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '기억 회상 훈련',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                testQuestionList[currentIndex],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  testAnswerList[currentIndex],
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  _onNextPressed();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDCEDC8),
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(48),
                  elevation: 0,
                ),
                icon: const Icon(Icons.double_arrow),
                label: Text(isLastQuestion ? '훈련 저장하기' : '다음 질문으로'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
