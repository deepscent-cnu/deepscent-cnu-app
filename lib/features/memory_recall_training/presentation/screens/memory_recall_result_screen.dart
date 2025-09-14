import 'dart:async';
import 'package:deepscent_cnu/common/widgets/button_basic.dart';
import 'package:deepscent_cnu/features/memory_recall_training/data/memory_recall_training_api.dart';
import 'package:deepscent_cnu/features/training_list/presentation/screens/olfactory_training_list.dart';
import 'package:deepscent_cnu/common/widgets/custom_app_bar.dart';
import 'package:deepscent_cnu/features/memory_recall_training/presentation/screens/memory_recall_session_select_screen.dart';
import 'package:flutter/material.dart';

class MemoryRecallResultScreen extends StatelessWidget {
  final int sessionIndex;
  final String selectedScent;
  final Map<String, dynamic> roundData;

  MemoryRecallResultScreen({
    super.key,
    required this.sessionIndex,
    required this.selectedScent,
    required this.roundData,
  });

  /// 오늘 느낀 점 입력 필드를 제어하기 위한 컨트롤러
  final TextEditingController _feelingController = TextEditingController();

  /// 느낀점 저장
  Future<void> _saveFeelingIfNeeded() async {
    final feeling = _feelingController.text.trim();
    if (feeling.isNotEmpty) {
      final success = await MemoryRecallTrainingApi.saveFeeling(
        sessionIndex,
        feeling,
      ); // 실제 회차 반영
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MemoryRecallSessionSelectScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // roundData에서 안전하게 꺼내 쓰기
    final String scentFromApi = (roundData['scent'] ?? '') as String;
    final String summaryFromApi = (roundData['summary'] ?? '') as String;
    final String feelingFromApi = (roundData['feeling'] ?? '') as String;
    final String createdAt = (roundData['createdAt'] ?? '') as String;

    // 서버에 이미 feeling이 있으면 입력창에 미리 채워주기(한 번만)
    if (feelingFromApi.isNotEmpty && _feelingController.text.isEmpty) {
      _feelingController.text = feelingFromApi;
    }

    return PopScope(
      canPop: false, // 기본 pop 동작 차단
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goToTrainingList(context);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          mode: CustomAppBarMode.sub,
          title: "기억 회상 훈련 결과",
          onBackPressed: () => _goToTrainingList(context),
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
                    const SizedBox(height: 24),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 타이틀
                            Text(
                              '$sessionIndex회차 훈련이 끝났어요!',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (createdAt.isNotEmpty)
                              Text(
                                '진행 시각: $createdAt',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black54,
                                ),
                              ),
                            const SizedBox(height: 28),

                            //오늘의 향기 (서버값 우선, 없으면 선택값)
                            Text(
                              '$sessionIndex회차의 향기: ${scentFromApi.isNotEmpty ? scentFromApi : selectedScent}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF335928),
                              ),
                            ),
                            const SizedBox(height: 32),

                            Text(
                              '$sessionIndex회차의 회상:',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF335928),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              summaryFromApi.isNotEmpty
                                  ? summaryFromApi
                                  : '요약이 아직 없습니다.',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // 오늘의 느낀 점 (입력/수정 가능)
                            Text(
                              '$sessionIndex회차 훈련 후 느낀 점:',
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
      ),
    );
  }
}
