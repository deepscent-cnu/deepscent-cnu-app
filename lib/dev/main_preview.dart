import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/widgets/scent_notice.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/widgets/scentraining_header.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: SafeArea(child: ScentNotice(message: "10초간 레몬 향을 발향합니다. 레몬 향을 상상하면서 향기에 집중해주세요!")),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}