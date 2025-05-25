import 'package:flutter/material.dart';

class MemoryRecallResultScreen extends StatelessWidget {
  const MemoryRecallResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.arrow_back),
                  const SizedBox(width: 8),
                  Text(
                    'deepscent',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                '기억 회상 훈련',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                '훈련이 끝났어요!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              const Text(
                '오늘의 향기: 🍋 레몬그라스',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF558B2F),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '상쾌하고 활력을 주는 허브 향입니다.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),

              const Text(
                '오늘의 회상:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF558B2F),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                ' 📝 외갓집 마당에서의 봄날, 풀냄새와 함께 떠오른 따뜻한 기억을 이야기해주셨어요.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),

              const Text(
                '오늘의 감정:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF558B2F),
                ),
              ),
              const SizedBox(height: 4),
              const Text('☺ 편안함, 🥲 그리움', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.description),
                  label: const Text('훈련 기록 보기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8F5E9),
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.list),
                  label: const Text('훈련 목록 보기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F8E9),
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
