import 'package:flutter/material.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/screens/login.dart'; // 경로는 네 프로젝트에 맞게 수정

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(), // ✅ 여기에서 바로 로그인 페이지 실행
    );
  }
}
