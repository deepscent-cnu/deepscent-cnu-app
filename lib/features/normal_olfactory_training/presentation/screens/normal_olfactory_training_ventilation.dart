import 'package:deepscent_cnu/common/widgets/button_basic.dart';
import 'package:deepscent_cnu/common/widgets/custom_app_bar.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/data/normal_olfactory_training_api.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/controllers/normal_olfactory_training_controller.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/screens/normal_olfactory_training_result.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/screens/normal_olfactory_training_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NormalOlfactoryTrainingVentilationScreen extends StatefulWidget {
  const NormalOlfactoryTrainingVentilationScreen({super.key});

  @override
  State<NormalOlfactoryTrainingVentilationScreen> createState() =>
      _NormalOlfactoryTrainingVentilationScreenState();
}

class _NormalOlfactoryTrainingVentilationScreenState
    extends State<NormalOlfactoryTrainingVentilationScreen> {
  final c = Get.find<NormalOlfactoryTrainingController>();

  bool _isProcessing = false;

  Future<void> _goNext() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final isLastRound = c.currentRound.value >= c.totalRounds;

      if (isLastRound) {
        // ✅ 마지막이면 DB 저장 후 결과
        final roundLogsPayload = c.logs.map((e) => e.toJson()).toList();
        await NormalOlfactoryTrainingApi.submitTrainingLog(
          c.totalTimeTaken,
          roundLogsPayload,
        );
        Get.offAll(() => NormalOlfactoryTrainingResultScreen());
        return;
      }

      // ✅ 다음 라운드로
      c.nextRound();
      c.resetRound();
      Get.offAll(() => NormalOlfactoryTrainingScreen());
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        appBar: CustomAppBar(
          mode: CustomAppBarMode.sub,
          title: "일반 후각 훈련",
          onBackPressed: () {}, // 환기중엔 뒤로가기 막는게 보통 안전
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/blurred_background.png',
                  fit: BoxFit.cover,
                  opacity: const AlwaysStoppedAnimation(0.5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      "지금은 향기 환기 중입니다.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "잠시만 기다린 후, 다음 단계로 진행해주세요.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.07,
                        vertical: screenWidth * 0.05,
                      ),
                      child: ButtonBasic(
                        content: "다음 단계로",
                        fontSize: screenWidth * 0.06,
                        function: _isProcessing ? null : _goNext,
                      ),
                    ),
                    const SizedBox(height: 30),
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
