import 'dart:convert';

import 'package:deepscent_cnu/features/normal_olfactory_training/data/device_api.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/screens/memory_recall_chat_screen.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/widgets/scent_notice.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/widgets/scentraining_header.dart';
import 'package:deepscent_cnu/secrets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MemoryRecallTrainingScreen extends StatefulWidget {
  const MemoryRecallTrainingScreen({super.key});

  @override
  State<MemoryRecallTrainingScreen> createState() =>
      MemoryRecallTrainingScreenState();
}

class MemoryRecallTrainingScreenState
    extends State<MemoryRecallTrainingScreen> {
  int remainTime = 10;
  String message = "초 뒤, 발향이 중지됩니다.";

  @override
  void initState() {
    super.initState();
    startTrainingCycle();
  }

  Future<void> startTrainingCycle() async {
    await DeviceApi.controlScentDeviceSlot(0, 3);
    await Future.delayed(const Duration(seconds: 1));

    while (remainTime > 1) {
      setState(() {
        remainTime -= 1;
      });

      await Future.delayed(const Duration(seconds: 1));
    }

    if (context.mounted) {
      await DeviceApi.controlScentDeviceSlot(0, 0);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MemoryRecallChatScreen()),
      );
    }
  }

  void extendTime() {
    setState(() {
      remainTime += 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScenTrainingHeader(trainingTitle: "기억 회상 훈련"),
            Expanded(
              child: Center(
                child: ScentNotice(message: remainTime.toString() + message),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                extendTime();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('시간 연장하기', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
