import 'dart:async';

import 'package:deepscent_cnu/common/widgets/button_basic.dart';
import 'package:deepscent_cnu/common/widgets/custom_app_bar.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/data/local/normal_training_local_database.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/data/models/normal_training_survey.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/data/normal_olfactory_training_api.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/controllers/normal_olfactory_training_controller.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/screens/normal_olfactory_training_result.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/screens/normal_olfactory_training_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

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

  Future<void> _syncTrainingToServer({
    required String clientId,
    required int totalTimeTaken,
    required List<Map<String, dynamic>> roundLogs,
  }) async {
    final localDatabase = NormalTrainingLocalDatabase.instance;

    try {
      await NormalOlfactoryTrainingApi.submitTrainingLog(
        totalTimeTaken,
        roundLogs,
      );
    } catch (e) {
      try {
        await localDatabase.markSyncFailed(clientId, e);
      } catch (localStatusError) {
        debugPrint('(Debug) 로컬 동기화 실패 상태 저장 중 오류: $localStatusError');
      }

      Get.snackbar(
        '휴대폰 저장 완료',
        '서버 전송에는 실패했지만 훈련 기록은 이 휴대폰에 저장되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await localDatabase.markSynced(clientId);
    } catch (localStatusError) {
      debugPrint('(Debug) 로컬 동기화 성공 상태 저장 중 오류: $localStatusError');
    }
  }

  Future<void> _goNext() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    try {
      final isLastRound = c.currentRound.value >= c.totalRounds;

      if (isLastRound) {
        final roundLogsPayload = c.logs.map((e) => e.toJson()).toList();
        final clientId = const Uuid().v4();
        final localDatabase = NormalTrainingLocalDatabase.instance;
        final surveyResponses = <Map<String, String>>[
          for (final question in normalTrainingSurveyQuestions)
            if ((c.surveyResponses[question.key] ?? '').trim().isNotEmpty)
              {
                'question_key': question.key,
                'question_text': question.question,
                'answer': c.surveyResponses[question.key]!.trim(),
              },
        ];

        // 서버 상태와 관계없이 휴대폰에 먼저 보관한다.
        await localDatabase.saveTraining(
          clientId: clientId,
          participantCode: c.participantCode,
          participantName: c.participantName,
          participantBirthYear: c.participantBirthYear,
          surveyResponses: surveyResponses,
          totalTimeTaken: c.totalTimeTaken,
          roundLogs: roundLogsPayload,
        );

        unawaited(
          _syncTrainingToServer(
            clientId: clientId,
            totalTimeTaken: c.totalTimeTaken,
            roundLogs: roundLogsPayload,
          ),
        );
        Get.offAll(() => NormalOlfactoryTrainingResultScreen());
        return;
      }

      // ✅ 다음 라운드로
      c.nextRound();
      c.resetRound();
      Get.offAll(() => NormalOlfactoryTrainingScreen());
    } catch (e) {
      debugPrint('(Debug) 일반 후각 훈련 완료 처리 중 오류 발생: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('휴대폰에 훈련 기록을 저장하지 못했습니다. 다시 시도해주세요.\n$e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      } else {
        _isProcessing = false;
      }
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
                        content: _isProcessing ? "저장 중..." : "다음 단계로",
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
