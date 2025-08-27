import 'package:deepscent_cnu/features/memory_recall_training/data/memory_recall_training_api.dart';
import 'package:deepscent_cnu/features/memory_recall_training/presentation/screens/memory_recall_scent_select_screen.dart';
import 'package:flutter/material.dart';

class MemoryRecallSessionSelectScreen extends StatefulWidget {
  const MemoryRecallSessionSelectScreen({super.key});

  @override
  State<MemoryRecallSessionSelectScreen> createState() =>
      _MemoryRecallSessionSelectScreenState();
}

class _MemoryRecallSessionSelectScreenState
    extends State<MemoryRecallSessionSelectScreen> {
  final List<bool> completedSessions = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initCompletedSessions();
  }

  Future<void> initCompletedSessions() async {
    int lastRound = await MemoryRecallTrainingApi.getLastRound();

    for (int idx = 0; idx < lastRound; idx++) {
      completedSessions[idx] = true;
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int firstIncompleteIndex = completedSessions.indexWhere(
      (element) => element == false,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        height: 56,
        color: Colors.grey[200],
        alignment: Alignment.center,
        child: const Text('하단 네비게이션 바', style: TextStyle(fontSize: 16)),
      ),
      extendBodyBehindAppBar: true,
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
      body:
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
                        '불러오는 중...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
              : SafeArea(
                child: Stack(
                  children: [
                    // 흐릿한 배경 이미지
                    Positioned.fill(
                      top: 50,
                      child: Image.asset(
                        'assets/images/blurred_background.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // 상단 뒤로가기 + 타이틀 텍스트
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Row(
                        children: [
                          const SizedBox(height: 24),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 20,
                            ),
                          ),
                          const Text(
                            '기억 회상 훈련 회차 선택',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 회차 버튼
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 100,
                          left: 40,
                          right: 40,
                          bottom: 20,
                        ),
                        child: ListView.builder(
                          itemCount: completedSessions.length,
                          itemBuilder: (context, index) {
                            final bool isDone = completedSessions[index];
                            final bool isCurrent =
                                index == firstIncompleteIndex;

                            Color backgroundColor;
                            Color foregroundColor;
                            BorderSide? border;

                            if (isDone) {
                              backgroundColor = Colors.grey;
                              foregroundColor = Colors.white;
                            } else if (isCurrent) {
                              backgroundColor = const Color(0xFF335928);
                              foregroundColor = Colors.white;
                            } else {
                              backgroundColor = Colors.white;
                              foregroundColor = const Color(0xFF335928);
                              border = const BorderSide(
                                color: Color(0xFF335928),
                              );
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: ElevatedButton.icon(
                                onPressed:
                                    isCurrent
                                        ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) =>
                                                      MemoryRecallScentSelectScreen(
                                                        sessionIndex: index + 1,
                                                      ),
                                            ),
                                          );
                                        }
                                        : () {}, // 나머지는 눌러도 아무 일 없음
                                icon: const Icon(Icons.flag, size: 32),
                                label: Text(
                                  '${index + 1}회차${isDone ? " (완료)" : ""}',
                                  style: const TextStyle(fontSize: 32),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: backgroundColor,
                                  foregroundColor: foregroundColor,
                                  side: border,
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  // 눌러도 효과 없게 시각만 비슷하게 유지
                                  elevation: isCurrent ? 2 : 0,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
