import 'dart:math';
import 'package:deepscent_cnu/features/memory_recall_training/data/memory_recall_training_api.dart';
import 'package:deepscent_cnu/features/memory_recall_training/data/model/scent_info.dart';
import 'package:deepscent_cnu/features/memory_recall_training/presentation/controllers/memory_recall_training_controller.dart';
import 'package:deepscent_cnu/features/memory_recall_training/presentation/screens/memory_recall_training_screen.dart';
import 'package:deepscent_cnu/common/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemoryRecallScentSelectScreen extends StatefulWidget {
  final int sessionIndex;

  const MemoryRecallScentSelectScreen({super.key, required this.sessionIndex});

  @override
  State<MemoryRecallScentSelectScreen> createState() =>
      _MemoryRecallScentSelectScreenState();
}

class _MemoryRecallScentSelectScreenState
    extends State<MemoryRecallScentSelectScreen> {
  final memoryRecallTrainingController =
      Get.find<MemoryRecallTrainingController>();
  List<ScentInfo>? scentAll;
  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    getScentAll();
  }

  Future<void> _goNextPage(ScentInfo? scentInfo) async {
    if (isSubmitting) return;

    if (scentInfo == null) {
      // 없음 버튼: 랜덤 scent 선택
      if (scentAll != null && scentAll!.isNotEmpty) {
        final random = Random();
        scentInfo = scentAll![random.nextInt(scentAll!.length)];
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('선택할 수 있는 향이 없습니다.')));
        return;
      }
    }

    // 1) 선택한 향기 정보를 전역 컨트롤러에 저장
    memoryRecallTrainingController.scentName = scentInfo.scentName;
    memoryRecallTrainingController.deviceNumber = scentInfo.deviceNumber;
    memoryRecallTrainingController.fanNumber = scentInfo.fanNumber;

    // 2) API 호출
    setState(() => isSubmitting = true);

    final result = await MemoryRecallTrainingApi.startChatWithScent(
      round: widget.sessionIndex,
      scent: memoryRecallTrainingController.scentName,
    );

    setState(() => isSubmitting = false);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('세션 생성에 실패했어요. 다시 시도해 주세요.')),
      );
      return;
    }

    memoryRecallTrainingController.roundId = result['id'];
    memoryRecallTrainingController.round =
        (result['round'] as num?)?.toInt() ?? widget.sessionIndex;

    // 4) 다음 페이지
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => MemoryRecallTrainingScreen(
              sessionIndex: widget.sessionIndex,
              selectedScent: memoryRecallTrainingController.scentName,
            ),
      ),
    );
  }

  Future<void> getScentAll() async {
    scentAll = await MemoryRecallTrainingApi.getScentAll();

    if (scentAll != null) {
      setState(() {
        isLoading = false;
      });
    }
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

  void scentSelectionModal(BuildContext context, ScentInfo? scentInfo) {
    double screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              "향기 선택",
              style: TextStyle(fontSize: screenWidth * 0.06),
            ),
            content: Text(
              "정말 [${scentInfo != null ? scentInfo.scentName : "없음"}] ${_getJosa(scentInfo != null ? scentInfo.scentName : "없음")} 선택하시겠습니까?",
              style: TextStyle(fontSize: screenWidth * 0.07),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _goNextPage(scentInfo);
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

  String _getSessionGuide(int sessionIndex) {
    switch (sessionIndex) {
      case 1:
        return "어린 시절의 추억이 담긴\n향기를 골라주세요.";
      case 2:
        return "가족에 대한 추억이 담긴\n향기를 골라주세요.";
      case 3:
        return "학교와 학창 시절의 추억이 담긴\n향기를 골라주세요.";
      case 4:
        return "결혼이나 연애의 추억이 담긴\n향기를 골라주세요.";
      case 5:
        return "자녀와 육아의 추억이 담긴\n향기를 골라주세요.";
      case 6:
        return "취미와 여가의 추억이 담긴\n향기를 골라주세요.";
      case 7:
        return "일과 사회생활의 추억이 담긴\n향기를 골라주세요.";
      case 8:
        return "지금의 나, 나의 삶을 떠올리는\n 향기를 골라주세요.";
      default:
        return "추억이 담긴 향기를 골라주세요.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        mode: CustomAppBarMode.sub,
        title: "[${widget.sessionIndex}회차] 기억 회상 훈련",
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
                    top: 50,
                    child: Image.asset(
                      'assets/images/blurred_background.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 0,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              _getSessionGuide(widget.sessionIndex),
                              style: TextStyle(
                                fontSize: screenWidth * 0.07,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: screenWidth < 400 ? 2.2 : 2.5, // 버튼의 가로/세로 비율
                                    ),
                                itemCount: scentAll!.length,
                                itemBuilder: (context, index) {
                                  ScentInfo scentInfo = scentAll![index];

                                  return OutlinedButton.icon(
                                    onPressed:
                                        () => scentSelectionModal(
                                          context,
                                          scentInfo,
                                        ),
                                    label: Text(
                                      scentInfo.scentName,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.05,
                                        color: Colors.black,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side: const BorderSide(
                                        color: Colors.black,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // 없음 버튼
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: screenWidth * 0.4,
                                  child: OutlinedButton.icon(
                                    onPressed:
                                        () => scentSelectionModal(
                                          context,
                                          null,
                                        ),
                                    icon: const Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ),
                                    label: Text(
                                      '없음',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.05,
                                        color: Colors.red,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side: const BorderSide(
                                        color: Colors.red,
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
                                  ),
                                ),
                              ],
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
