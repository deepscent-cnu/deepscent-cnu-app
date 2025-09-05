import 'dart:async';
import 'package:deepscent_cnu/common/widgets/button_basic.dart';
import 'package:deepscent_cnu/features/memory_recall_training/data/memory_recall_training_api.dart';
import 'package:deepscent_cnu/features/training_list/presentation/screens/olfactory_training_list.dart';
import 'package:flutter/material.dart';

class MemoryRecallResultScreen extends StatelessWidget {
  const MemoryRecallResultScreen({super.key});

  /// 오늘 느낀 점 입력 필드를 제어하기 위한 컨트롤러
  static final TextEditingController _feelingController = TextEditingController();

  /// 느낀점 저장
  Future<void> _saveFeelingIfNeeded() async {
    final feeling = _feelingController.text.trim();
    if (feeling.isNotEmpty) {
      final success = await MemoryRecallTrainingApi.saveFeeling(1, feeling); // 실제 회차 반영 필요
      if (success) {
        debugPrint('느낀점 저장 성공');
      } else {
        debugPrint('느낀점 저장 실패');
      }
    }
  }

  /// 훈련 목록 보기
  Future<void> _goToTrainingList(BuildContext context) async {
    await _saveFeelingIfNeeded();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OlfactoryTrainingListScreen()),
      (route) => false,
    );
  }

  /// 훈련 기록 보기
  Future<void> _goToTrainingLog(BuildContext context) async {
    await _saveFeelingIfNeeded();
    // 실제 이동 구현 필요
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('훈련 기록 보기 실행')),
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
            Positioned.fill(
              child: Image.asset(
                'assets/images/blurred_background_2.png',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _goToTrainingList(context),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      ),
                      const Text(
                        '기억 회상 훈련',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // 큰 타이틀
                          const Text(
                            '1회차 훈련이 끝났어요!',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // 오늘의 향기
                          const Text(
                            '오늘의 향기:',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF335928),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '🌬️ 연기 향',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 오늘의 회상
                          const Text(
                            '오늘의 회상:',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF335928),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '📝 외갓집 마당에서의 봄날, 풀냄새와 함께 떠오른 따뜻한 기억을 이야기해 주셨어요.',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 32),
 
                          // 오늘 느낀 점
                          const Text(
                            '오늘의 느낀 점:',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF335928),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: TextField(
                              controller: _feelingController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: '오늘 훈련을 통해 느낀 점을 적어주세요. (선택사항)',
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            child: ButtonBasic(
                              content: '훈련 기록 보기',
                              fontSize: 32,
                              icon: Icon(Icons.edit_document, size: 32),
                              function: () => _goToTrainingLog(context),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            child: ButtonBasic(
                              content: '훈련 목록 보기',
                              icon: Icon(Icons.list, size: 36),
                              fontSize: 32,
                              function: () => _goToTrainingList(context),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
