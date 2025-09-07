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

  Future<void> goNextPage(ScentInfo? scentInfo) async {
    if (isSubmitting) return;

    if (scentInfo == null) {
      // 없음 버튼: 랜덤 scent 선택
      if (scentAll != null && scentAll!.isNotEmpty) {
        final random = Random();
        scentInfo = scentAll![random.nextInt(scentAll!.length)];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('선택할 수 있는 향이 없습니다.')),
        );
        return;
      }
    }

    // 1) 선택한 향기 정보를 전역 컨트롤러에 저장
    memoryRecallTrainingController.scentName = scentInfo.scentName;
    memoryRecallTrainingController.deviceNumber = scentInfo.deviceNumber;
    memoryRecallTrainingController.fanNumber = scentInfo.fanNumber;

    // 2) API 호출 (userId는 서버에서 1로 하드코딩)
    setState(() => isSubmitting = true);

    final result = await MemoryRecallTrainingApi.startChatWithScent(
      roundId: widget.sessionIndex,
      scent: memoryRecallTrainingController.scentName,
    );

    setState(() => isSubmitting = false);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('세션 생성에 실패했어요. 다시 시도해 주세요.')),
      );
      return;
    }

    memoryRecallTrainingController.round =
        (result['id'] as num?)?.toInt() ?? widget.sessionIndex;

    // 4) 다음 페이지
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MemoryRecallTrainingScreen(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        mode: CustomAppBarMode.sub,
        title: "[${widget.sessionIndex}회차] 기억 회상 훈련",
        onBackPressed: () {
          Navigator.pop(context);
        },
        logoutEnabled: true
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
                      vertical: 20,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 2.5 / 1, // 버튼의 가로/세로 비율
                              ),
                              itemCount: scentAll!.length,
                              itemBuilder: (context, index) {
                                  ScentInfo scentInfo = scentAll![index];

                                return OutlinedButton.icon(
                                    onPressed: () => goNextPage(scentInfo),
                                  label: Text(
                                    scentInfo.scentName,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 24,
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
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width *
                                            0.5 -
                                        48, // 좌우 padding 고려
                                  child: OutlinedButton.icon(
                                      onPressed: () => goNextPage(null),
                                    icon: const Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ),
                                    label: const Text(
                                      '없음',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 24,
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
