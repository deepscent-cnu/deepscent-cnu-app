import 'package:flutter/material.dart';

import '../features/realtime_voice_test/presentation/realtime_voice_test_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RealtimeVoicePreviewApp());
}

class RealtimeVoicePreviewApp extends StatelessWidget {
  const RealtimeVoicePreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '실시간 향기 대화 테스트',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F7F68)),
        useMaterial3: true,
      ),
      home: const RealtimeVoiceTestScreen(),
    );
  }
}
