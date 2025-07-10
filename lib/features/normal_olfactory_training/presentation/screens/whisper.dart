import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

class AutoStopRecorderPage extends StatefulWidget {
  const AutoStopRecorderPage({super.key});

  @override
  State<AutoStopRecorderPage> createState() => _AutoStopRecorderPageState();
}

class _AutoStopRecorderPageState extends State<AutoStopRecorderPage> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _filePath;
  bool _isRecording = false;
  String? _transcription; // ✅ 추가: STT 결과 저장용

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (!_isRecording) {
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

      setState(() => _isRecording = true);
      print('🎙️ 녹음 시작: $_filePath');
    } else {
      await _recorder.stop();
      setState(() => _isRecording = false);
      print('🛑 녹음 종료');

      if (_filePath != null && File(_filePath!).existsSync()) {
        await _sendRecordingToServer(_filePath!);
      }
    }
  }

  Future<void> _sendRecordingToServer(String filePath) async {
    print('📏 녹음 파일 크기: ${File(filePath).lengthSync()} bytes');
    final uri = Uri.parse("http://10.0.2.2:8080/api/stt/upload");
    final request = http.MultipartRequest("POST", uri);
    request.files.add(await http.MultipartFile.fromPath("audio", filePath));

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('📦 응답 상태코드: ${response.statusCode}');
      print('📦 응답 본문: $responseBody');

      if (response.statusCode == 200) {
        print('✅ 전송 성공: $responseBody');

        final text = RegExp(r'"transcript"\s*:\s*"([^"]+)"')
            .firstMatch(responseBody)
            ?.group(1);

        if (text != null) {
          setState(() {
            _transcription = text; // ✅ STT 결과 화면에 표시
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('STT 결과가 성공적으로 수신되었습니다.')),
        );
      } else {
        print('❌ 오류 응답: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('STT 요청 실패: $responseBody')),
        );
      }
    } catch (e) {
      print('🚨 전송 중 예외 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('STT 요청 중 에러 발생')),
      );
    }
  }

  Future<void> _playRecording() async {
    if (_filePath != null && File(_filePath!).existsSync()) {
      print('▶️ 재생 시작: $_filePath');
      await _audioPlayer.play(DeviceFileSource(_filePath!));
    } else {
      print('❌ 녹음 파일 없음');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('녹음된 파일이 없습니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎤 STT 녹음기')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _toggleRecording,
              child: Text(_isRecording ? '🛑 녹음 종료 및 STT 요청' : '🎙️ 녹음 시작'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _playRecording,
              child: const Text('▶️ 녹음된 음성 재생'),
            ),
            const SizedBox(height: 30),
            if (_transcription != null) // ✅ STT 결과 표시
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '📝 인식 결과: $_transcription',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
