import 'dart:async';
import 'dart:io';
import 'package:deepscent_cnu/common/widgets/button_basic.dart';
import 'package:deepscent_cnu/common/widgets/question_step_chip.dart';
import 'package:deepscent_cnu/features/memory_recall_training/data/memory_recall_training_api.dart';
import 'package:deepscent_cnu/features/memory_recall_training/presentation/controllers/memory_recall_training_controller.dart';
import 'package:deepscent_cnu/features/memory_recall_training/presentation/screens/memory_recall_result_screen.dart';
import 'package:deepscent_cnu/features/training_list/presentation/screens/olfactory_training_list.dart';
import 'package:deepscent_cnu/common/widgets/custom_app_bar.dart';
import 'package:deepscent_cnu/common/widgets/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

enum LoadingType { none, generatingQuestion, transcribingAudio, savingSummary }

class MemoryRecallChatScreen extends StatefulWidget {
  final int sessionIndex;
  final String selectedScent;

  const MemoryRecallChatScreen({
    super.key,
    required this.sessionIndex,
    required this.selectedScent,
  });

  @override
  State<MemoryRecallChatScreen> createState() => _MemoryRecallChatScreenState();
}

class _MemoryRecallChatScreenState extends State<MemoryRecallChatScreen> {
  final memoryRecallTrainingController =
      Get.find<MemoryRecallTrainingController>();
  int currentIndex = 0;
  int interactionCount = 0;
  final AudioRecorder _recorder = AudioRecorder();
  String? _filePath;
  bool isRecording = false;
  String? transcriptText;
  LoadingType loadingType = LoadingType.none;
  late final Stopwatch stopwatch;
  Timer? timer;

  List<String> testQuestionList = [];
  List<String> testAnswerList = [
    "마이크를 누르고 말씀해주세요\n응답이 완료되었으면 마이크를 한번 더 눌러주시면 됩니다\n",
  ];

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch();
    fetchInitialQuestion();
  }

  Future<void> fetchInitialQuestion() async {
    setState(() => loadingType = LoadingType.generatingQuestion);
    try {
      final roundId = memoryRecallTrainingController.roundId;
      if (roundId <= 0) {
        setState(() {
          testQuestionList.add("세션 정보가 없습니다. 이전 화면에서 회차를 시작해 주세요.");
        });
        return;
      }
      final firstQuestion = await MemoryRecallTrainingApi.sendChatToAI(
        roundId,
        "넌 지금 기억회상 후각훈련을 하고 있어 이 향기를 맡으면 어떤 기분이 떠오르나요와 같은 질문으로 대화를 시작해줘",
      );
      setState(() {
        if (firstQuestion != null && firstQuestion.isNotEmpty) {
          testQuestionList.add(firstQuestion);
        } else {
          testQuestionList.add("질문을 불러오지 못했습니다.");
        }
      });
    } finally {
      if (mounted) setState(() => loadingType = LoadingType.none);
    }
  }

  @override
  void dispose() {
    if (isRecording) {
      _recorder.stop();
    }
    _recorder.dispose();
    stopwatch.stop();
    timer?.cancel();
    super.dispose();
  }

  void toggleRecording() async {
    if (transcriptText != null && transcriptText!.isNotEmpty && !isRecording) {
      final shouldReRecord = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
          title: const Text(
            "재녹음 하시겠습니까?",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "이미 음성 인식된 내용이 있습니다. 이전 내용을 삭제하고 다시 녹음하시겠습니까?",
            style: TextStyle(fontSize: 24),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("취소", style: TextStyle(fontSize: 24)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("확인", style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      );
      if (shouldReRecord != true) return;
      setState(() {
        transcriptText = null;
      });
    }

    if (!isRecording) {
      final hasPerm = await _recorder.hasPermission();
      if (!hasPerm) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('마이크 권한이 필요합니다. 설정에서 허용해 주세요.')),
        );
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      _filePath = '${dir.path}/recorded_audio.wav';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _filePath!,
      );

      setState(() {
        isRecording = true;
        stopwatch.reset();
        stopwatch.start();
      });

      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {});
      });
    } else {
      await _recorder.stop();
      stopwatch.stop();
      timer?.cancel();
      setState(() => isRecording = false);
      if (_filePath != null && File(_filePath!).existsSync()) {
        await sendRecordingToServer(_filePath!);
      }
    }
  }

  Future<void> _stopRecordingIfNeeded() async {
    if (isRecording) {
      await _recorder.stop();
      setState(() => isRecording = false);
    }
  }

  Future<void> sendRecordingToServer(String filePath) async {
    setState(() {
      loadingType = LoadingType.transcribingAudio;
      transcriptText = '로딩 중...';
    });

    final sttResult = await MemoryRecallTrainingApi.sendAudioToSTT(
      File(filePath),
    );

    setState(() {
      loadingType = LoadingType.none;
      transcriptText = sttResult ?? '음성을 인식하지 못했어요.';
    });
  }

  void _onNextPressed() async {
    final bool isLastStep = interactionCount >= 9; // 응답 9회 완료 시 저장

    if (!isLastStep && transcriptText != null && transcriptText!.isNotEmpty) {
      setState(() => loadingType = LoadingType.generatingQuestion);
      try {
        final roundId = memoryRecallTrainingController.roundId;
        if (roundId <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('세션 정보가 없습니다. 다시 시도해 주세요.')),
          );
          return;
        }

        final chatResult = await MemoryRecallTrainingApi.sendChatToAI(
          roundId,
          transcriptText!,
        );

        if (chatResult != null && chatResult.isNotEmpty) {
          currentIndex++;
          interactionCount++;

          setState(() {
            transcriptText = null;
            stopwatch.reset();
            if (testQuestionList.length <= currentIndex) {
              testQuestionList.add(chatResult);
            } else {
              testQuestionList[currentIndex] = chatResult;
            }
          });
        }
      } finally {
        if (mounted) setState(() => loadingType = LoadingType.none);
      }
    }

    if (isLastStep) {
      final round = widget.sessionIndex;
      final roundId = memoryRecallTrainingController.roundId;

      setState(() => loadingType = LoadingType.savingSummary);
      try {
        // 1) 요약 저장
        final saved = await MemoryRecallTrainingApi.summarizeRound(roundId);
        if (!saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('요약 저장에 실패했습니다. 잠시 후 다시 시도해 주세요.')),
          );
          return;
        }

        // 2) 요약 저장 후, 읽기 호출
        final roundData = await MemoryRecallTrainingApi.readRound(round);
        if (roundData == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('결과 데이터를 불러오지 못했습니다.')));
          return;
        }

        // 3) 결과 화면으로 이동 (읽은 데이터 전달)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => MemoryRecallResultScreen(
              sessionIndex: widget.sessionIndex,
              selectedScent: widget.selectedScent,
              roundData: roundData,
            ),
          ),
        );
      } finally {
        if (mounted) setState(() => loadingType = LoadingType.none);
      }
      return;
    }
  }

  void _onSkipPressed() async {
    final round = widget.sessionIndex;
    final roundId = memoryRecallTrainingController.roundId;

    setState(() => loadingType = LoadingType.savingSummary);
    try {
      // 1) 요약 저장
      final saved = await MemoryRecallTrainingApi.summarizeRound(roundId);
      if (!saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('요약 저장에 실패했습니다. 잠시 후 다시 시도해 주세요.')),
        );
        return;
      }

      // 2) 요약 저장 후, 읽기 호출
      final roundData = await MemoryRecallTrainingApi.readRound(round);
      if (roundData == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('결과 데이터를 불러오지 못했습니다.')));
        return;
      }

      // 3) 결과 화면으로 이동 (읽은 데이터 전달)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => MemoryRecallResultScreen(
                sessionIndex: widget.sessionIndex,
                selectedScent: widget.selectedScent,
                roundData: roundData,
              ),
        ),
      );
    } finally {
      if (mounted) setState(() => loadingType = LoadingType.none);
    }
    return;
  }

  String formattedTime() {
    final seconds = stopwatch.elapsed.inSeconds;
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$remainingSeconds";
  }

  void showTrainingCarouselModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
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
                                function: () async {
                                  await _stopRecordingIfNeeded();
                                  await MemoryRecallTrainingApi.deleteMemoryRecallRoundLog(
                                    memoryRecallTrainingController.roundId,
                                  );
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const OlfactoryTrainingListScreen(),
                                    ),
                                    (route) => false,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _loadingMessage() {
    switch (loadingType) {
      case LoadingType.generatingQuestion:
        return '질문을 생성하는 중입니다...';
      case LoadingType.transcribingAudio:
        return '음성을 인식하는 중입니다...';
      case LoadingType.savingSummary:
        return '요약을 저장하는 중입니다...';
      default:
        return '로딩 중입니다...';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastStep = interactionCount >= 9;
    final bool isNextEnabled =
        (isLastStep ||
            (transcriptText != null &&
                transcriptText!.isNotEmpty &&
                transcriptText != '로딩 중...' &&
                loadingType == LoadingType.none));

    return PopScope(
      canPop: false, // 기본 pop 동작 차단
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          showTrainingCarouselModal(context); // 시스템 뒤로가기 누르면 모달 띄움
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          mode: CustomAppBarMode.sub,
          title: "[${widget.sessionIndex}회차] 기억 회상 훈련",
          onBackPressed: () {
            showTrainingCarouselModal(context);
          },
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/blurred_background_2.png',
                  fit: BoxFit.cover,
                  opacity: const AlwaysStoppedAnimation(0.5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: QuestionStepChip(
                                currentStep: (currentIndex + 1).clamp(1, 10),
                                totalSteps: 10,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Opacity(
                            opacity: 0.5,
                            child: ButtonBasic(
                              content: '훈련 스킵 (디버깅)',
                              fontSize: 12,
                              function: _onSkipPressed,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      flex: 6,
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          // 질문 바뀔 때 스크롤뷰 재생성
                          key: ValueKey('q-$currentIndex'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: PageTransitionSwitcher(
                              duration: const Duration(milliseconds: 350),
                              transitionBuilder:
                                  (child, primary, secondary) =>
                                      FadeThroughTransition(
                                animation: primary,
                                secondaryAnimation: secondary,
                                fillColor: Colors.transparent,
                                child: child,
                              ),
                              child: Text(
                                testQuestionList.isNotEmpty
                                    ? testQuestionList[currentIndex]
                                    : '',
                                key: ValueKey(currentIndex),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 205, 205, 205),
                      thickness: 5,
                      height: 32,
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom + 8,
                        ),
                        child: Row(
                          children: [
                            isLastStep
                                ? const SizedBox.shrink()
                                : Expanded(
                                    flex: 3,
                                    child: GestureDetector(
                                      onTap: toggleRecording,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 36,
                                        backgroundColor:
                                            isRecording
                                                ? Colors.red
                                                : const Color(0xFF2E7D32),
                                            child: Icon(
                                          isRecording ? Icons.stop : Icons.mic,
                                              color: Colors.white,
                                              size: 36,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            formattedTime(),
                                        style: const TextStyle(fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            Expanded(
                              flex: isLastStep ? 9 : 6,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: ButtonBasic(
                                  content: interactionCount >= 9
                                      ? '훈련 저장하기'
                                      : '다음 질문으로',
                                  icon: const Icon(Icons.double_arrow, size: 24),
                                  fontSize: 24,
                                  function:
                                      isNextEnabled ? _onNextPressed : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // ⬇️ 여기 있던 SizedBox(32) 제거해서 더 이상 바닥 넘어가지 않음
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child:
                    loadingType != LoadingType.none
                        ? LoadingOverlay(message: _loadingMessage())
                        : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
