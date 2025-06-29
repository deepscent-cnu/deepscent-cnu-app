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
      home: OlfactoryTrainingListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
