import 'dart:async';
import 'dart:io';
import 'package:deepscent_cnu/common/widgets/button_basic.dart';
import 'package:deepscent_cnu/common/widgets/question_step_chip.dart';
import 'package:deepscent_cnu/features/memory_recall_training/presentation/screens/memory_recall_result_screen.dart';
import 'package:deepscent_cnu/features/training_list/presentation/screens/olfactory_training_list.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/data/memory_recall_training_api.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class MemoryRecallChatScreen extends StatefulWidget {
  const MemoryRecallChatScreen({super.key});

  @override
  State<MemoryRecallChatScreen> createState() => _MemoryRecallChatScreenState();
}

class _MemoryRecallChatScreenState extends State<MemoryRecallChatScreen> {
  final _scrollCtrl = ScrollController();
  int currentIndex = 0;
  int interactionCount = 0;
  final AudioRecorder _recorder = AudioRecorder();
  String? _filePath;
  bool isRecording = false;
  String? transcriptText;
  bool isLoading = false;
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
    setState(() => isLoading = true);
    try {
      final firstQuestion = await MemoryRecallTrainingApi.sendChatToAI(
        1,
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
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
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
              title: const Text("재녹음 하시겠습니까?"),
              content: const Text(
                "이미 음성 인식된 내용이 있습니다. 이전 내용을 삭제하고 다시 녹음하시겠습니까?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("취소"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("확인"),
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

  Future<void> sendRecordingToServer(String filePath) async {
    setState(() {
      isLoading = true;
      transcriptText = '로딩 중...';
    });

    final sttResult = await MemoryRecallTrainingApi.sendAudioToSTT(
      File(filePath),
    );

    setState(() {
      isLoading = false;
      transcriptText = sttResult ?? '음성을 인식하지 못했어요.';
    });
  }

  void _onNextPressed() async {
    final bool isLastStep = interactionCount >= 4;

    if (!isLastStep && transcriptText != null && transcriptText!.isNotEmpty) {
      setState(() => isLoading = true);
      try {
        final chatResult = await MemoryRecallTrainingApi.sendChatToAI(
          1,
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
        if (mounted) setState(() => isLoading = false);
      }
    }

    if (isLastStep) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MemoryRecallResultScreen()),
      );
    }
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
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
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

  @override
  Widget build(BuildContext context) {
    final bool isLastStep = interactionCount >= 4;
    final bool isNextEnabled =
        (isLastStep ||
            (transcriptText != null &&
                transcriptText!.isNotEmpty &&
                transcriptText != '로딩 중...' &&
                !isLoading));

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        height: 56,
        color: Colors.grey[200],
        alignment: Alignment.center,
        child: const Text('하단 네비게이션 바', style: TextStyle(fontSize: 16)),
      ),
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
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/blurred_background_2.png',
                fit: BoxFit.cover,
                opacity: AlwaysStoppedAnimation(0.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      ),
                      const Text(
                        '기억 회상 훈련',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: QuestionStepChip(
                        currentStep: interactionCount + 1,
                        totalSteps: 5,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
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
                                fontSize: 20,
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
                    child: Row(
                      children: [
                        isLastStep
                            ? SizedBox.shrink()
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
                              horizontal: 24,
                              vertical: 16,
                            ),
                            child: ButtonBasic(
                              content:
                                  interactionCount >= 4 ? '훈련 저장하기' : '다음 질문으로',
                              icon: const Icon(Icons.double_arrow),
                              function: isNextEnabled ? _onNextPressed : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            if (isLoading) ...[
              const ModalBarrier(
                dismissible: false,
                color: Colors.black26,
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text(
                      '질문을 생성중입니다',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
