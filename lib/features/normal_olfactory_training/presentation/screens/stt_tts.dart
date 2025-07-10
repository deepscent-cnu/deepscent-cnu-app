import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

// STT & TTS 기능 테스트 페이지
class STT_TTS_TestPage extends StatefulWidget {
  const STT_TTS_TestPage({super.key});

  @override
  State<STT_TTS_TestPage> createState() => _STT_TTS_TestPageState();
}

class _STT_TTS_TestPageState extends State<STT_TTS_TestPage> {
  // STT 인식 객체
  final stt.SpeechToText _speech = stt.SpeechToText();
  // TTS 객체
  final FlutterTts _flutterTts = FlutterTts();

  // 인식된 텍스트 저장 변수
  String _recognizedText = '';

  // 음성 인식 중인지 여부
  bool _isListening = false;

  // 사용자가 입력한 텍스트를 저장할 컨트롤러 (TTS용)
  final TextEditingController _ttsInputController = TextEditingController();

  @override
  void dispose() {
    _flutterTts.stop(); // 페이지 종료 시 TTS 중지
    _ttsInputController.dispose(); // 컨트롤러 정리
    super.dispose();
  }

  // 음성 인식 시작 함수
Future<void> _startListening() async {
  bool available = await _speech.initialize();
  if (available) {
    setState(() => _isListening = true);
    _speech.listen(
      localeId: 'ko_KR',
      onResult: (result) {
        print("🎤 인식된 텍스트: ${result.recognizedWords}");
        setState(() {
          _recognizedText = result.recognizedWords;
        });
      },
      listenFor: const Duration(hours: 1), // 아주 길게 설정
      pauseFor: const Duration(minutes: 1), // 정적 시간도 길게
      partialResults: true,
      cancelOnError: false,
    );
  }
}


  // 음성 인식 중단 함수
  Future<void> _stopListening() async {
    await _speech.stop(); // STT 종료
    setState(() => _isListening = false);
  }


  Future<void> _speak() async {
    if (_ttsInputController.text.isNotEmpty) {
      await _flutterTts.setLanguage("ko-KR");
      await _flutterTts.speak(_ttsInputController.text); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎙️ STT & 🔊 TTS Test')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 음성 인식 결과 텍스트
            Text(
              '🎙️ 음성 인식 결과:',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            // 결과 보여주는 박스
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              height: 80,
              width: double.infinity,
              child: Text(_recognizedText),
            ),

            // 음성 인식 시작/중지 버튼
            ElevatedButton(
              onPressed: _isListening ? _stopListening : _startListening,
              child: Text(_isListening ? '🛑 Stop Listening' : '🎤 Start Listening'),
            ),

            const SizedBox(height: 30),

            // TTS 입력 안내
            Text(
              '🔊 텍스트를 음성으로 변환',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            // 텍스트 입력 필드
            TextField(
              controller: _ttsInputController,
              decoration: const InputDecoration(
                hintText: '여기에 텍스트 입력', // 사용자 안내 문구
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            // TTS 실행 버튼
            ElevatedButton(
              onPressed: _speak,
              child: const Text('📢 전송(TTS)'),
            ),
          ],
        ),
      ),
    );
  }
}
