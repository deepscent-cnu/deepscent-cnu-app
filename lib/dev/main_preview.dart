import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/screens/normal_olfactory_training_screen.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/screens/olfactoryTrainingLIst.dart';
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
      home: TrainingListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
