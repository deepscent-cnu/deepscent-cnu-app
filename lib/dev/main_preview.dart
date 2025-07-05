import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/screens/normal_olfactory_training_answer.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/screens/normal_olfactory_training_question.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/screens/normal_olfactory_training_result.dart';
import 'package:deepscent_cnu/features/training_list/presentation/screens/olfactory_training_list.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: NormalOlfactoryTrainingResultScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
