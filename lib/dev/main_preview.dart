import 'package:deepscent_cnu/common/presentation/controller/auth_controller.dart';
import 'package:deepscent_cnu/features/login/presentation/screens/login.dart';
import 'package:deepscent_cnu/features/memory_recall_training/presentation/controllers/memory_recall_training_controller.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/controllers/normal_olfactory_training_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authController = Get.put(AuthController());
  await authController.adminLogin();

  Get.put(NormalOlfactoryTrainingController());
  Get.put(MemoryRecallTrainingController());
  runApp(const MyApp());
  debugPrint(authController.accessToken.value);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(home: LoginPage(), debugShowCheckedModeBanner: false);
  }
}
