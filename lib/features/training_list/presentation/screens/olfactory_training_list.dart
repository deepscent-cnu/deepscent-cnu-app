import 'package:deepscent_cnu/features/device_register/data/device_register_api.dart';
import 'package:deepscent_cnu/features/device_register/model/device_ids.dart';
import 'package:deepscent_cnu/features/device_register/presentation/device_register_screen.dart';
import 'package:deepscent_cnu/features/memory_recall_training/data/memory_recall_training_api.dart';
import 'package:deepscent_cnu/features/memory_recall_training/data/model/scent_info.dart';
import 'package:deepscent_cnu/features/memory_recall_training/presentation/screens/memory_recall_session_select_screen.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/controllers/normal_olfactory_training_controller.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/screens/normal_olfactory_training_screen.dart';
import 'package:deepscent_cnu/common/widgets/custom_app_bar.dart';
import 'package:deepscent_cnu/common/widgets/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class OlfactoryTrainingListScreen extends StatefulWidget {
  const OlfactoryTrainingListScreen({super.key});

  @override
  State<OlfactoryTrainingListScreen> createState() =>
      _OlfactoryTrainingListScreenState();
}

class _OlfactoryTrainingListScreenState
    extends State<OlfactoryTrainingListScreen> {
  final normalOlfactoryTrainingController =
      Get.find<NormalOlfactoryTrainingController>();

  final String NORMAL_MODE = "NORMAL";
  final String MEMORY_RECALL_MODE = "MEMORY_RECALL";
  bool isLoading = false;
  bool tapLocked = false;
  DeviceIds? deviceIds;
  List<ScentInfo>? scentInfo;

  Future<bool> checkDeviceRegistration() async {
    deviceIds = await DeviceRegisterApi.getDeviceIds();

    if (deviceIds == null) return false;

    if (deviceIds!.deviceId1 == null ||
        deviceIds!.deviceId2 == null ||
        deviceIds!.deviceId3 == null) {
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text("기기 등록 필요", style: TextStyle(fontSize: 28)),
                content: const Text(
                  "훈련을 진행하기 전, 기기 등록 페이지에서 모든 기기의 ID를 등록해주세요.",
                  style: TextStyle(fontSize: 24),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("확인", style: TextStyle(fontSize: 24)),
                  ),
                ],
              ),
        );
      }
      return false;
    }
    return true;
  }

  Future<bool> checkScentMapping() async {
    scentInfo = await MemoryRecallTrainingApi.getScentAll();

    if (scentInfo == null) {
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text("향기 매핑 필요", style: TextStyle(fontSize: 28)),
                content: const Text(
                  "향기 매핑 정보가 부족하여 훈련을 진행할 수 없습니다. 관리자에게 문의해주세요.",
                  style: TextStyle(fontSize: 24),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("확인", style: TextStyle(fontSize: 24)),
                  ),
                ],
              ),
        );
      }
      return false;
    }
    return true;
  }

  Future<void> showTrainingCarouselModal(
    BuildContext context,
    String mode,
  ) async {
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

    final bool isDevicesRegistered = await checkDeviceRegistration();

    if (!isDevicesRegistered) {
      if (mounted) {
        setState(() {
          tapLocked = false;
          isLoading = false;
        });
      }
      return;
    }

    final bool isScentMapped = await checkScentMapping();

    if (!isScentMapped) {
      if (mounted) {
        setState(() {
          tapLocked = false;
          isLoading = false;
        });
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // 개발용 모달 상시 표시
    // await prefs.remove(NORMAL_MODE);
    // await prefs.remove(MEMORY_RECALL_MODE);
    final hasSeenModal = prefs.getBool(mode) ?? false;

    // 다음 화면으로 이동하는 로직을 함수로 분리
    Future<void> navigateToTrainingScreen() async {
      // Navigator.push가 Future를 반환하므로 await으로 기다릴 수 있음
      await Navigator.push(
        context, // 이 context는 OlfactoryTrainingListScreen의 것이므로 안전함
        MaterialPageRoute(
          builder: (context) {
            if (mode == NORMAL_MODE) {
              return const NormalOlfactoryTrainingScreen();
            } else if (mode == MEMORY_RECALL_MODE) {
              return MemoryRecallSessionSelectScreen();
            } else {
              throw Exception('Invalid training mode');
            }
          },
        ),
      );
    }

    if (!hasSeenModal) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false, // 바깥 클릭으로 모달이 닫히지 않도록
        builder: (BuildContext dialogContext) {
          int currentPage = 0; // 현재 보고 있는 페이지의 인덱스

          return WillPopScope(
            onWillPop: () async {
              Navigator.of(dialogContext).pop(false); // 취소로 간주
              return false; // 우리가 pop했으니 기본 pop은 막기
            },
            child: Dialog(
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
                              if (mounted) {
                                setState(() {
                                  currentPage = index;
                                });
                              }
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
                                        totalPages -
                                            1) // 마지막 페이지가 아닌 경우에만 이미지 표시
                                      AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 500,
                                        ),
                                        child: Container(
                                          key: ValueKey(imagePaths[index]),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 8,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
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
                                          Navigator.of(context).pop(true);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
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
                                borderRadius: BorderRadius.circular(
                                  5,
                                ), // 둥근 테두리
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
            ),
          );
        },
      );

      if (!mounted) return;

      if (confirmed == true) {
        await prefs.setBool(mode, true);
        await navigateToTrainingScreen();
      }

      setState(() {
        tapLocked = false;
        isLoading = false;
      });
    } else {
      await navigateToTrainingScreen();
      if (!mounted) return;

      setState(() {
        tapLocked = false;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 반응형 처리
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double titleFontSize = screenWidth * 0.06; // 대제목
    final double subtitleFontSize = screenWidth * 0.07; // 소제목
    final double elementMargin = screenHeight * 0.05; // 마진
    final double bodyFontSize = screenWidth * 0.04; // 본문
    final double cardPadding = screenWidth * 0.05; // 카드 내부 패딩

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        mode: CustomAppBarMode.main,
        logoutEnabled: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: SingleChildScrollView(
                child: AnimationLimiter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 600),
                      childAnimationBuilder:
                          (widget) => SlideAnimation(
                            verticalOffset: elementMargin,
                            child: FadeInAnimation(child: widget),
                          ),
                      children: [
                        SizedBox(height: elementMargin),

                        // 1. 상단 타이틀 + 기기 등록 버튼
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '후각 훈련 목록',
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF2F2F2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DeviceRegisterScreen(),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.all(2),
                                child: Text(
                                  '기기 등록',
                                  style: TextStyle(
                                    fontSize: bodyFontSize,
                                    color: Color(0xFF335928),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: elementMargin / 3),

                        // 2. 오늘은 멘트
                        Text(
                          '오늘은\n어떤 훈련을 진행할까요?',
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: elementMargin),

                        AbsorbPointer(
                          absorbing: tapLocked,
                          child: Column(
                            children: [
                              // 3. 첫 번째 카드
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: cardPadding,
                                ),
                                child: _buildTrainingCard(
                                  context,
                                  icon: Icons.local_florist,
                                  title: '일반 후각 훈련',
                                  subtitle: '의료기관에서\n진행하는 훈련',
                                  onPressed:
                                      () => showTrainingCarouselModal(
                                        context,
                                        NORMAL_MODE,
                                      ),
                                  titleFontSize: screenWidth * 0.07,
                                  subtitleFontSize: screenWidth * 0.05,
                                  elementMargin: elementMargin,
                                ),
                              ),

                              SizedBox(height: elementMargin / 2),

                              // 4. 두 번째 카드
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: cardPadding,
                                ),
                                child: _buildTrainingCard(
                                  context,
                                  icon: Icons.lightbulb,
                                  title: '기억 회상 훈련',
                                  subtitle: '향을 맡고 기억을\n회상하는 훈련',
                                  onPressed:
                                      () => showTrainingCarouselModal(
                                        context,
                                        MEMORY_RECALL_MODE,
                                      ),
                                  titleFontSize: screenWidth * 0.07,
                                  subtitleFontSize: screenWidth * 0.05,
                                  elementMargin: elementMargin,
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
            ),

            // 로딩 오버레이
            if (isLoading) const LoadingOverlay(),
          ],
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
    required double titleFontSize,
    required double subtitleFontSize,
    required double elementMargin,
  }) {
    // 이 위젯 내부에서만 쓰는 매우 가벼운 상태
    bool pressed = false;

    return StatefulBuilder(
      builder: (context, setInner) {
        return AnimatedScale(
          scale: pressed ? 0.98 : 1.0, // 살짝 축소
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(elementMargin / 3),
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
                        Icon(
                          icon,
                          color: const Color(0xFF335928),
                          size: titleFontSize,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF335928),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: elementMargin / 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: elementMargin / 3),
                    Text(
                      '≫ 클릭하여 훈련 진행하기',
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned.fill(
                child: Material(
                  type: MaterialType.transparency,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      if (tapLocked) return;

                      if (mounted) {
                        setState(() {
                          tapLocked = true;
                          isLoading = true;
                        });
                      }

                      onPressed();
                    },
                    onHighlightChanged: (v) => setInner(() => pressed = v),
                    highlightColor: Colors.black.withOpacity(0.03),
                    splashColor: Colors.black.withOpacity(0.07),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
