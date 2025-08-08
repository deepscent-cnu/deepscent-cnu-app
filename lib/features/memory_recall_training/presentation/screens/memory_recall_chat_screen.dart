import 'dart:async';
import 'dart:io';

import 'package:deepscent_cnu/common/widgets/button_basic.dart';
import 'package:deepscent_cnu/features/memory_recall_training/presentation/screens/memory_recall_result_screen.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/data/memory_recall_training_api.dart';
import 'package:flutter/material.dart';
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

  List<String> testQuestionList = [
    "이 향기를 맡았을 때 어떤 기억이 떠올랐나요",
  ];

  List<String> testAnswerList = [
    "마이크를 누르고 말씀해주세요\n응답이 완료되었으면 마이크를 한번 더 눌러주시면 됩니다\n",
  ];

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    stopwatch.stop();
    timer?.cancel();
    super.dispose();
  }

  void toggleRecording() async {
    if (!isRecording) {
      // 권한 확인/요청
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

    final sttResult = await MemoryRecallTrainingApi.sendAudioToSTT(File(filePath));

    setState(() {
      isLoading = false;
      transcriptText = sttResult ?? '음성을 인식하지 못했어요.';
    });
  }

  void _onNextPressed() async {
    if (transcriptText != null && transcriptText!.isNotEmpty) {
      final chatResult = await MemoryRecallTrainingApi.sendChatToAI(1, transcriptText!);

      if (chatResult != null && chatResult.isNotEmpty) {
        currentIndex++;
        interactionCount++;

        setState(() {
          transcriptText = null;
          if (testQuestionList.length <= currentIndex) {
            testQuestionList.add(chatResult);
          } else {
            testQuestionList[currentIndex] = chatResult;
          }
        });
      }
    }

    if (interactionCount >= 5) {
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

  @override
  Widget build(BuildContext context) {
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/blurred_background_2.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20)
                  .copyWith(bottom: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      ),
                      const Text(
                        '기억 회상 훈련',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      testQuestionList[currentIndex],
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 7,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Scrollbar(
                        controller: _scrollCtrl,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _scrollCtrl,
                          primary: false,
                          padding: const EdgeInsets.only(right: 10),
                          child: Text(
                            transcriptText ?? testAnswerList[0],
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: GestureDetector(
                      onTap: toggleRecording,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: const Color(0xFF2E7D32),
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
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    child: ButtonBasic(
                      content: interactionCount >= 4 ? '훈련 저장하기' : '다음 질문으로',
                      icon: const Icon(Icons.double_arrow),
                      function: _onNextPressed,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
