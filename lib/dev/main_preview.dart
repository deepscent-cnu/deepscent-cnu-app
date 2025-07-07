import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/controllers/normal_olfactory_training_controller.dart';
import 'package:deepscent_cnu/features/training_list/presentation/screens/olfactory_training_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  Get.put(NormalOlfactoryTrainingController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: OlfactoryTrainingListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
