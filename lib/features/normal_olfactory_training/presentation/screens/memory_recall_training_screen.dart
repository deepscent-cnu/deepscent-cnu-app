import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:deepscent_cnu/features/memory_recall_training/data/memory_recall_training_api.dart';

class MemoryRecallTrainingScreen extends StatefulWidget {
  const MemoryRecallTrainingScreen({super.key});

  @override
  State<MemoryRecallTrainingScreen> createState() => _MemoryRecallTrainingScreenState();
}

class _MemoryRecallTrainingScreenState extends State<MemoryRecallTrainingScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  String? _filePath;
  bool isRecording = false;
  String? transcriptText;
  bool isLoading = false;
  late final Stopwatch stopwatch;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch();
  }

  @override
  void dispose() {
    stopwatch.stop();
    timer?.cancel();
    super.dispose();
  }

  void toggleRecording() async {
    if (!isRecording) {
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
      transcriptText = '로딩 중...'; // ✅ 표시
    });

    final result = await MemoryRecallTrainingApi.sendAudioToSTT(File(filePath));

    setState(() {
      isLoading = false;
      transcriptText = result ?? '결과를 인식하지 못했어요.';
    });
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('기억 회상 훈련', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/blurred_background_2.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                const Text(
                  '방금 맡은 냄새는\n어떤 향기인 것 같나요?',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  constraints: const BoxConstraints(minHeight: 120),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    transcriptText ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF43A047),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  label: const Text('다음 질문으로', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                const Spacer(),
                GestureDetector(
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
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
