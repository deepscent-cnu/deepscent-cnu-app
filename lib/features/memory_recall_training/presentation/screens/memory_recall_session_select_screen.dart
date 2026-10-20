import 'package:deepscent_cnu/features/memory_recall_training/data/memory_recall_training_api.dart';
import 'package:deepscent_cnu/features/memory_recall_training/presentation/screens/memory_recall_scent_select_screen.dart';
import 'package:deepscent_cnu/common/widgets/custom_app_bar.dart';
import 'package:deepscent_cnu/features/memory_recall_training/presentation/screens/memory_recall_result_screen.dart';
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

  Future<void> _openFinishedSession(int round) async {
    // 로딩 표시 (간단 다이얼로그)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final data = await MemoryRecallTrainingApi.readRound(round);
      if (data == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('회차 데이터를 불러오지 못했습니다.')));
        return;
      }

      // API의 scent가 있으면 selectedScent로 전달(없으면 빈 문자열)
      final selectedScent = (data['scent'] ?? '') as String? ?? '';

      if (!mounted) return;
      Navigator.pop(context); // 로딩 닫기
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => MemoryRecallResultScreen(
                sessionIndex: round, // UI에 보일 회차
                selectedScent: selectedScent, // 결과 화면 상단 "오늘의 향기"
                roundData: data, // 서버 응답 전체 전달
              ),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // 로딩 닫기
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류: $e')));
      }
    }
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
    final screenWidth = MediaQuery.of(context).size.width;
    final int firstIncompleteIndex = completedSessions.indexWhere(
      (element) => element == false,
    );

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: CustomAppBar(
        mode: CustomAppBarMode.sub,
        title: "기억 회상 훈련 회차 선택",
        onBackPressed: () {
          Navigator.pop(context);
        },
        logoutEnabled: false,
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
              : Stack(
                children: [
                  // 흐릿한 배경 이미지
                  Positioned.fill(
                    top: kToolbarHeight,
                    child: Image.asset(
                      'assets/images/blurred_background.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  // 회차 버튼
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 0,
                      left: 40,
                      right: 40,
                      bottom: 0,
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
                          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (isDone) {
                                //완료된 회차: 히스토리 보기
                                _openFinishedSession(
                                  index + 1,
                                ); // round == sessionIndex + 1
                              } else if (isCurrent) {
                                // 진행해야 할 현재 회차: 훈련 시작
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
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('이 회차는 아직 진행할 수 없습니다.'),
                                  ),
                                );
                              }
                            },

                            icon: Icon(Icons.flag, size: screenWidth * 0.08),
                            label: Text(
                              '${index + 1}회차${isDone ? " (완료)" : ""}',
                              style: TextStyle(fontSize: screenWidth * 0.08),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: backgroundColor,
                              foregroundColor: foregroundColor,
                              side: border,
                              minimumSize: Size(double.infinity, screenWidth * 0.15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                              ),
                              // 눌러도 효과 없게 시각만 비슷하게 유지
                              elevation: isCurrent ? 2 : 0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
