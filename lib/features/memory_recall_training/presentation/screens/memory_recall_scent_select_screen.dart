import 'dart:math';
import 'package:deepscent_cnu/features/memory_recall_training/presentation/screens/memory_recall_training_screen.dart';
import 'package:flutter/material.dart';

class MemoryRecallScentSelectScreen extends StatelessWidget {
  final int sessionIndex;

  const MemoryRecallScentSelectScreen({super.key, required this.sessionIndex});

  @override
  Widget build(BuildContext context) {
    // 향기 이름 및 이모지
    final scentItems = [
      ['🫘 된장', '🧼 비누'],
      ['💨 연기', '🍖 숯불고기'],
      ['👕 탈취제', '🍊 귤'],
      ['🌿 페퍼민트', '🍫 초콜릿'],
    ];

    // 전체 향기 리스트
    final allScents = scentItems.expand((pair) => pair).toList();

    void navigateWithScent(String scent) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MemoryRecallTrainingScreen(
            sessionIndex: sessionIndex,
            selectedScent: scent, // 선택한 향 전달
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
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
      body: Stack(
        children: [
          // 흐릿한 배경 이미지
          Positioned.fill(
            top: 50,
            child: Image.asset(
              'assets/images/blurred_background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 뒤로 가기 + 타이틀
                    Row(
                      children: [
                        const SizedBox(height: 24),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                        ),
                        Text(
                          '[$sessionIndex회차] 기억 회상 훈련',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '오늘은 학교와 친구들에 대한 기억을 나누는 시간입니다.',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '다음 중 떠오르는 향기를 하나 골라주세요.',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    // 향기 버튼 8개 (2x4)
                    ...scentItems.map(
                      (pair) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children:
                              pair.map((label) {
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    child: OutlinedButton(
                                      onPressed: () => navigateWithScent(label),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.white, // 흰 배경
                                        foregroundColor: const Color(
                                          0xFF335928,
                                        ),
                                        side: const BorderSide(
                                          color: Color(0xFF335928),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        label,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                    // 없음 버튼
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width:
                                MediaQuery.of(context).size.width * 0.5 -
                                48, // 좌우 padding 고려
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // 랜덤 선택
                                final random = Random();
                                final scent =
                                    allScents[random.nextInt(allScents.length)];
                                navigateWithScent(scent);
                              },
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              label: const Text(
                                '없음',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 24,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
          ),
        ],
      ),
    );
  }
}
