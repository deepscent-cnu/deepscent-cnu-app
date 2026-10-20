import 'package:deepscent_cnu/common/widgets/button_basic.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/data/models/scent_options.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/data/normal_olfactory_training_api.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/controllers/normal_olfactory_training_controller.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/screens/normal_olfactory_training_scent_strength.dart';
import 'package:deepscent_cnu/common/widgets/custom_app_bar.dart';
import 'package:deepscent_cnu/features/training_list/presentation/screens/olfactory_training_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/screens/normal_olfactory_training_screen.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/screens/normal_olfactory_training_result.dart';

class NormalOlfactoryTrainingQuestionScreen extends StatefulWidget {
  const NormalOlfactoryTrainingQuestionScreen({super.key});

  @override
  State<NormalOlfactoryTrainingQuestionScreen> createState() =>
      _NormalOlfactoryTrainingQuestionScreenState();
}

class _NormalOlfactoryTrainingQuestionScreenState
    extends State<NormalOlfactoryTrainingQuestionScreen> {
  final normalOlfactoryTrainingController =
      Get.find<NormalOlfactoryTrainingController>();
  bool isLoading = true;
  ScentOptions? scentOptions;
  late DateTime startTime;
  bool _isSubmitting = false; // State에 추가

  @override
  void initState() {
    super.initState();
    getScentOptions();
    startTime = DateTime.now();
  }

  Future<void> getScentOptions() async {
    String correctOption =
        normalOlfactoryTrainingController.getCorrectScentByRound().scentName;
    scentOptions = await NormalOlfactoryTrainingApi.getScentOptions(
      correctOption,
    );
    if (scentOptions != null) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showTrainingStopModal(BuildContext context) {
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
                              child: ButtonBasic(
                                content: '훈련 재개하기',
                                icon: Icon(Icons.rocket_launch, size: 20),
                                function: () => {Navigator.pop(context)},
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              child: ButtonBasic(
                                content: '훈련 끝내기',
                                icon: Icon(Icons.exit_to_app, size: 20),
                                function: () {
                                  // 1) 다이얼로그 닫기
                                  Get.back(); // = Navigator.pop(context)랑 같지만 GetX 방식

                                  // 2) 상태 초기화
                                  normalOlfactoryTrainingController.reset();

                                  // 3) 홈/훈련목록으로 "명시적으로" 이동 (여기만 너 목적지로 바꾸면 됨)
                                  Get.offAll(
                                    () => OlfactoryTrainingListScreen(),
                                  );
                                  // 또는 Get.offAll(() => TrainingListScreen());
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _getJosa(String text) {
    if (text.isEmpty) {
      return '';
    }

    // 마지막 글자의 유니코드(UTF-16) 코드를 가져옵니다.
    int lastCharCode = text.codeUnitAt(text.length - 1);

    // 한글 유니코드 범위 (가-힣) 안에 있는지 확인합니다.
    if (lastCharCode < 0xAC00 || lastCharCode > 0xD7A3) {
      // 한글이 아니면 기본값 '을'을 반환
      return '를';
    }

    // 받침(종성)이 있는지 확인합니다.
    // 한글 유니코드 계산식: (글자 코드 - 0xAC00) % 28
    // 이 결과가 0이면 받침이 없고, 0이 아니면 받침이 있습니다.
    final bool hasJongseong = (lastCharCode - 0xAC00) % 28 != 0;

    return hasJongseong ? '을' : '를';
  }

  void scentSelectionModal(BuildContext context, String selectedOption) {
    final screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              "답안 선택",
              style: TextStyle(fontSize: screenWidth * 0.06),
            ),
            content: Text(
              "정말 [$selectedOption] ${_getJosa(selectedOption)} 선택하시겠습니까?",
              style: TextStyle(fontSize: screenWidth * 0.07),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  //기존
                  _goScentStrengthScreen(selectedOption);
                  //수정
                  // _submitAndGoNext(selectedOption);
                },
                child: Text(
                  "확인",
                  style: TextStyle(fontSize: screenWidth * 0.05),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "취소",
                  style: TextStyle(fontSize: screenWidth * 0.05),
                ),
              ),
            ],
          ),
    );
  }

  //기존
  void _goScentStrengthScreen(String selectedOption) {
    final endTime = DateTime.now();
    final timeTaken = endTime.difference(startTime).inSeconds;

    normalOlfactoryTrainingController.selectedOption = selectedOption;
    normalOlfactoryTrainingController.timeTaken = timeTaken;

    Get.off(() => NormalOlfactoryTrainingScentStrengthScreen());
  }

  //수정
  Future<void> _submitAndGoNext(String selectedOption) async {
    //추가
    if (_isSubmitting) return;
    _isSubmitting = true;

    final endTime = DateTime.now();
    final timeTaken = endTime.difference(startTime).inSeconds;

    normalOlfactoryTrainingController.selectedOption = selectedOption;
    normalOlfactoryTrainingController.timeTaken = timeTaken;

    // ✅ 강도는 미수집(-1)로 저장
    normalOlfactoryTrainingController.addLog(-1);

    final isLastRound =
        normalOlfactoryTrainingController.currentRound.value >=
        normalOlfactoryTrainingController.totalRounds;

    // if (isLastRound) {
    //   Get.offAll(() => NormalOlfactoryTrainingResultScreen());
    //   return;
    // }
    //
    // normalOlfactoryTrainingController.nextRound();
    // normalOlfactoryTrainingController.resetRound();
    //
    // Get.offAll(() => NormalOlfactoryTrainingScreen());

    try {
      if (isLastRound) {
        // ✅ payload 구성
        final roundLogsPayload =
            normalOlfactoryTrainingController.logs
                .map((log) => log.toJson())
                .toList();

        await NormalOlfactoryTrainingApi.submitTrainingLog(
          normalOlfactoryTrainingController.totalTimeTaken,
          roundLogsPayload,
        );

        Get.offAll(() => NormalOlfactoryTrainingResultScreen());
        return;
      }

      normalOlfactoryTrainingController.nextRound();
      normalOlfactoryTrainingController.resetRound();
      Get.offAll(() => NormalOlfactoryTrainingScreen());
    } finally {
      _isSubmitting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final bottomPad = MediaQuery.of(context).padding.bottom + 24;

    const Map<String, String> scentImageMap = {
      '커피': 'assets/scent/coffee.jpg',
      '라벤더': 'assets/scent/lavender.jpg',
      '레몬': 'assets/scent/lemon.jpg',
      '장미': 'assets/scent/rose.jpg',
      '꽃': 'assets/scent/rose.jpg',

      '베이비파우더': 'assets/scent/babypowder.png',
      '베이비파우더(화장품)': 'assets/scent/babypowder.png',

      '사과': 'assets/scent/apple.jpg',
      '카레': 'assets/scent/carry.jpg',
      '초콜릿': 'assets/scent/chocolate.jpg',
      '딸기': 'assets/scent/strawberry.jpg',
      '계피': 'assets/scent/sinamon.jpg',
      '홍삼/인삼': 'assets/scent/ginseng.jpg',
      '홍삼': 'assets/scent/ginseng.jpg',
      '인삼': 'assets/scent/ginseng.jpg',
      '수박': 'assets/scent/watermelon.jpg',
      '복숭아': 'assets/scent/peach.jpg',
      '땅콩': 'assets/scent/peanut.jpg',

      '건포도': 'assets/scent/plum.jpg',
      '자두': 'assets/scent/jado.jpg',

      '멜론': 'assets/scent/melon.jpg',
      '누룽지': 'assets/scent/rice.jpg',
      '아카시아꽃': 'assets/scent/acasia.jpg',
      '아카시아': 'assets/scent/acasia.jpg',
      '박하': 'assets/scent/mint.jpg',
      '오렌지': 'assets/scent/orange.jpg',
      '나무': 'assets/scent/tree.jpg',
      '쑥': 'assets/scent/mugwort.jpg',
      '마늘': 'assets/scent/garlic.jpg',
      '김치': 'assets/scent/gimchi.jpg',
      '파스': 'assets/scent/pas.jpg',
      '체리': 'assets/scent/cherry.jpg',
      '솜사탕': 'assets/scent/somcandy.jpg',
      '꿀': 'assets/scent/honey.jpg',
      '자몽': 'assets/scent/grapefruit.jpg',
      '유자': 'assets/scent/yuzu.png',
      '옥수수': 'assets/scent/corn.jpg',
      '비누': 'assets/scent/soap.jpg',
      '생강': 'assets/scent/ginger.jpg',
      '바나나': 'assets/scent/banana.jpg',
      '포도': 'assets/scent/grape.jpg',

      '한약': 'assets/scent/komedicine.jpg',
      '숯불고기': 'assets/scent/meet.jpg',
      '소나무': 'assets/scent/pine.jpg',
      '나프탈렌': 'assets/scent/nap.png',
    };

    //추가
    final options = normalOlfactoryTrainingController.getCurrentOptions();

    return PopScope(
      canPop: false, // 기본 pop 동작 차단
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          showTrainingStopModal(context); // 시스템 뒤로가기 누르면 모달 띄움
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          mode: CustomAppBarMode.sub,
          title: "일반 후각 훈련",
          onBackPressed: () {
            showTrainingStopModal(context);
          },
        ),
        body: SafeArea(
          child:
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
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/blurred_background.png',
                          fit: BoxFit.cover,
                          opacity: AlwaysStoppedAnimation(0.5),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: bottomPad),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                child: Text(
                                  "방금 맡은 향은 어떤 향인지\n다음 보기 중에서 골라보세요!",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.07,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 40),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 40,
                                  mainAxisSpacing: 40,
                                  childAspectRatio: 1,
                                  children: [
                                    for (final opt in options)
                                      ButtonBasic(
                                        content: opt,
                                        fontSize:
                                            screenWidth * 0.05, // 60은 너무 큼
                                        imageAssetPath: scentImageMap[opt],
                                        function:
                                            () => scentSelectionModal(
                                              context,
                                              opt,
                                            ),
                                        // fontSize: 60,
                                        // function: () => scentSelectionModal(context, opt),
                                      ),
                                    //기존
                                    // ButtonBasic(
                                    //   content: scentOptions!.scentOption1,
                                    //   fontSize: 60,
                                    //   function:
                                    //       () => scentSelectionModal(
                                    //         context,
                                    //         scentOptions!.scentOption1,
                                    //       ),
                                    // ),
                                    // ButtonBasic(
                                    //   content: scentOptions!.scentOption2,
                                    //   fontSize: 60,
                                    //   function:
                                    //       () => scentSelectionModal(
                                    //         context,
                                    //         scentOptions!.scentOption2,
                                    //       ),
                                    // ),
                                    // ButtonBasic(
                                    //   content: scentOptions!.scentOption3,
                                    //   fontSize: 60,
                                    //   function:
                                    //       () => scentSelectionModal(
                                    //         context,
                                    //         scentOptions!.scentOption3,
                                    //       ),
                                    // ),
                                    // ButtonBasic(
                                    //   content: scentOptions!.scentOption4,
                                    //   fontSize: 60,
                                    //   function:
                                    //       () => scentSelectionModal(
                                    //         context,
                                    //         scentOptions!.scentOption4,
                                    //       ),
                                    // ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                child: ButtonBasic(
                                  content: "잘 모르겠어요",
                                  fontSize: 32,
                                  function:
                                      () => scentSelectionModal(
                                        context,
                                        "잘 모르겠어요",
                                      ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
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
