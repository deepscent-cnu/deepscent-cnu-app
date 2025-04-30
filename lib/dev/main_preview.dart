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
        body: SafeArea(child: ScenTrainingHeader(trainingTitle: '일반 후각 훈련')),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}