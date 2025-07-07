import 'package:deepscent_cnu/features/memory_recall_training/presentation/screens/memory_recall_training_screen.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/screens/normal_olfactory_training_screen.dart';
import 'package:flutter/material.dart';

class OlfactoryTrainingListScreen extends StatelessWidget {
  final String NORMAL_MODE = "NORMAL";
  final String MEMORY_RECALL_MODE = "MEMORY_RECALL";
  const OlfactoryTrainingListScreen({super.key});

  // 훈련 시작 전 보여줄 스와이프 가능한 안내 모달 함수
  void showTrainingCarouselModal(BuildContext context, String mode) {
    final PageController pageController = PageController();
    const int totalPages = 5; // 총 페이지 수

    final List<String> instructions = [
      '카트리지가 올바르게\n장착되었는지 확인해 주세요.',
      '향의 구성은 3개월마다\n새롭게 변경해 주세요.',
      '향을 맡기 힘들 경우, 자동으로\n발향 강도를 높여줍니다.',
      '향을 맡으며 관련된 추억이나\n장면을 떠올려 보세요.',
      '훈련을 시작할 준비가 되었다면\n아래 버튼을 눌러주세요.',
    ];

    final List<String> imagePaths = [
      'assets/images/cartridge_check.png',
      'assets/images/replace_scent_3months.png',
      'assets/images/auto_intensity_adjust.png',
      'assets/images/recall_memory_scent.png',
      '', // 마지막은 버튼만 표시할 예정
    ];

    showDialog(
      context: context,
      barrierDismissible: false, // 바깥 클릭으로 모달이 닫히지 않도록
      builder: (BuildContext context) {
        int currentPage = 0; // 현재 보고 있는 페이지의 인덱스

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
                      child: PageView.builder(
                        controller: pageController, // 위에서 만든 컨트롤러
                        itemCount: totalPages,
                        onPageChanged: (index) {
                          // 페이지가 바뀔 때 currentPage 상태 업데이트
                          setState(() {
                            currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0), // 내용 여백
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center, // 세로 중앙 정렬
                              children: [
                                Text(
                                  // 안내 멘트 텍스트
                                  instructions[index],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20), // 위아래 여백

                                const Divider(
                                  // 구분선
                                  thickness: 1,
                                  height: 1,
                                  color: Color(0xFFE0E0E0),
                                ),
                                const SizedBox(height: 16),

                                if (index <
                                    totalPages - 1) // 마지막 페이지가 아닌 경우에만 이미지 표시
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 500),
                                    child: Container(
                                      key: ValueKey(imagePaths[index]),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: Image.asset(
                                            imagePaths[index],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                else // 마지막 페이지면 '훈련 시작' 버튼 표시
                                  ElevatedButton(
                                    onPressed: () {
                                      // 모달 닫고 훈련 시작 함수 실행
                                      Navigator.of(context).pop();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            if (mode == NORMAL_MODE) {
                                              return const NormalOlfactoryTrainingScreen();
                                            } else if (mode ==
                                                MEMORY_RECALL_MODE) {
                                              return const MemoryRecallTrainingScreen();
                                            } else {
                                              throw Exception(
                                                'Invalid training mode',
                                              );
                                            }
                                          },
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      backgroundColor: Color(0xFFF9F9F9),
                                    ),
                                    child: const Text(
                                      '🚀 훈련 시작하기',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF335928),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8), // 인디케이터 위 여백
                    Row(
                      // 페이지 인디케이터
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(totalPages, (index) {
                        final isActive = index == currentPage; // 현재 페이지 여부
                        return AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 300,
                          ), // 부드러운 전환
                          margin: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ), // 점 사이 여백
                          width: isActive ? 20 : 10, // 현재 페이지면 더 길게 표시
                          height: 10,
                          decoration: BoxDecoration(
                            color:
                                isActive
                                    ? Colors.green
                                    : Colors.grey[400], // 색상 차이
                            borderRadius: BorderRadius.circular(5), // 둥근 테두리
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16), // 모달 하단 여백
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
      bottomNavigationBar: Container(
        height: 56,
        color: Colors.grey[200],
        alignment: Alignment.center,
        child: const Text('하단 네비게이션 바', style: TextStyle(fontSize: 16)),
      ),
      backgroundColor: Colors.white,
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
          Icon(Icons.search, color: Colors.black),
          SizedBox(width: 12),
          Icon(Icons.notifications_none, color: Colors.black),
          SizedBox(width: 12),
          Icon(Icons.menu, color: Colors.black),
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
              const Text(
                '후각 훈련 목록',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                '오늘은\n어떤 훈련을 진행할까요?',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: _buildTrainingCard(
                        context,
                        icon: Icons.local_florist,
                        title: '일반 후각 훈련',
                        subtitle: '의료기관에서 진행하는 훈련',
                        onPressed:
                            () => {
                              showTrainingCarouselModal(
                                context,
                                NORMAL_MODE,
                              ),
                            },
                      ),
                    ),
                    const SizedBox(height: 60),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: _buildTrainingCard(
                        context,
                        icon: Icons.lightbulb,
                        title: '기억 회상 훈련',
                        subtitle: '향을 맡고 기억을 회상하는 훈련',
                        onPressed:
                            () => {
                              showTrainingCarouselModal(
                                context,
                                MEMORY_RECALL_MODE,
                              ),
                            },
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrainingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 7,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: const Color(0xFF335928), size: 30),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF335928),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '≫ 클릭하여 훈련 진행하기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
