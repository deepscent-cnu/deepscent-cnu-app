//import 'package:deepscent_cnu/presentation/screens/%08signup.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:deepscent_cnu/common/presentation/controller/auth_controller.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/controllers/normal_olfactory_training_controller.dart';
import 'package:deepscent_cnu/features/memory_recall_training/presentation/controllers/memory_recall_training_controller.dart';
import 'features/login/presentation/screens/login.dart';
import 'features/training_list/presentation/screens/olfactory_training_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // AuthController 등록
  final authController = Get.put(AuthController());
  Get.put(NormalOlfactoryTrainingController());
  Get.put(MemoryRecallTrainingController());

  // 토큰이 로컬에 존재할 경우, 자동 로그인
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwtToken');

  // AuthController 반영
  if (token != null) {
    authController.accessToken.value = token;
  }

  runApp(MyApp(initialToken: token));
}

class MyApp extends StatelessWidget {
  final String? initialToken;
  const MyApp({super.key, this.initialToken});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: initialToken != null
          ? const OlfactoryTrainingListScreen()
          : const LoginPage(),
    );
  }
}


// import 'package:flutter/material.dart';
// // 음성 인식 라이브러리
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// // 텍스트를 음성으로 변환하는 TTS 라이브러리
// import 'package:flutter_tts/flutter_tts.dart';

// void main() {
//   runApp(const MyApp());
// }

// // 앱의 루트 위젯
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: const STT_TTS_TestPage(), // 메인 페이지로 이동
//       debugShowCheckedModeBanner: false, // 오른쪽 위 디버그 배너 제거
//     );
//   }
// }

// // STT & TTS 기능 테스트 페이지
// class STT_TTS_TestPage extends StatefulWidget {
//   const STT_TTS_TestPage({super.key});

//   @override
//   State<STT_TTS_TestPage> createState() => _STT_TTS_TestPageState();
// }

// class _STT_TTS_TestPageState extends State<STT_TTS_TestPage> {
//   // STT 인식 객체
//   final stt.SpeechToText _speech = stt.SpeechToText();
//   // TTS 객체
//   final FlutterTts _flutterTts = FlutterTts();

//   // 인식된 텍스트 저장 변수
//   String _recognizedText = '';

//   // 음성 인식 중인지 여부
//   bool _isListening = false;

//   // 사용자가 입력한 텍스트를 저장할 컨트롤러 (TTS용)
//   final TextEditingController _ttsInputController = TextEditingController();

//   @override
//   void dispose() {
//     _flutterTts.stop(); // 페이지 종료 시 TTS 중지
//     _ttsInputController.dispose(); // 컨트롤러 정리
//     super.dispose();
//   }

//   // 음성 인식 시작 함수
//   Future<void> _startListening() async {
//     bool available = await _speech.initialize(); // STT 초기화
//     if (available) {
//       setState(() => _isListening = true); // 상태: 듣는 중
//       _speech.listen(
//         localeId: 'ko_KR',
//         onResult: (result) {
//           print("🎤 인식된 텍스트: ${result.recognizedWords}");
//           setState(() {
//             _recognizedText = result.recognizedWords; // 결과 저장
//           });
//         },
//       );
//     }
//   }

//   // 음성 인식 중단 함수
//   Future<void> _stopListening() async {
//     await _speech.stop(); // STT 종료
//     setState(() => _isListening = false);
//   }

//   // 텍스트 → 음성 출력 함수
//   Future<void> _speak() async {
//     if (_ttsInputController.text.isNotEmpty) {
//       await _flutterTts.setLanguage("ko-KR");
//       await _flutterTts.speak(_ttsInputController.text); // TTS 실행
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('🎙️ STT & 🔊 TTS Test')),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             // 음성 인식 결과 텍스트
//             Text(
//               '🎙️ 음성 인식 결과:',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),

//             // 결과 보여주는 박스
//             Container(
//               margin: const EdgeInsets.symmetric(vertical: 10),
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               height: 80,
//               width: double.infinity,
//               child: Text(_recognizedText),
//             ),

//             // 음성 인식 시작/중지 버튼
//             ElevatedButton(
//               onPressed: _isListening ? _stopListening : _startListening,
//               child: Text(_isListening ? '🛑 Stop Listening' : '🎤 Start Listening'),
//             ),

//             const SizedBox(height: 30),

//             // TTS 입력 안내
//             Text(
//               '🔊 텍스트를 음성으로 변환',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),

//             // 텍스트 입력 필드
//             TextField(
//               controller: _ttsInputController,
//               decoration: const InputDecoration(
//                 hintText: '여기에 텍스트 입력', // 사용자 안내 문구
//                 border: OutlineInputBorder(),
//               ),
//             ),

//             const SizedBox(height: 10),

//             // TTS 실행 버튼
//             ElevatedButton(
//               onPressed: _speak,
//               child: const Text('📢 전송(TTS)'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
