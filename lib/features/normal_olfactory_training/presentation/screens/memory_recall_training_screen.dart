import 'package:deepscent_cnu/features/normal_olfactory_training/data/device_api.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/screens/memory_recall_chat_screen.dart';
import 'package:flutter/material.dart';

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
  bool isStopped = false;

  @override
  void initState() {
    super.initState();
    startTrainingCycle();
  }

  Future<void> startTrainingCycle() async {
    isStopped = false;
    await DeviceApi.controlScentDeviceSlot(0, 3);
    await Future.delayed(const Duration(seconds: 1));

    while (remainTime > 1) {
      if (isStopped) {
        return;
      }

      setState(() {
        remainTime -= 1;
      });

      await Future.delayed(const Duration(seconds: 1));
    }

    if (!isStopped && context.mounted) {
      await DeviceApi.controlScentDeviceSlot(0, 0);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MemoryRecallChatScreen()),
      );
    }
  }

  Future<void> stopTrainingCycle() async {
    isStopped = true;
    await DeviceApi.controlScentDeviceSlot(0, 0);

    if (context.mounted) {
      Navigator.pop(context);
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
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        height: 56,
        color: Colors.grey[200],
        alignment: Alignment.center,
        child: const Text('하단 네비게이션 바', style: TextStyle(fontSize: 16)),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 120,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Image.asset(
            'assets/images/logo.png',
            width: 120,
            height: 50,
            fit: BoxFit.contain,
          ),
        ),
        actions: const [
          Icon(Icons.help_outline, color: Colors.black),
          SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 80,
              child: Image.asset(
                'assets/images/blurred_background.png',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      IconButton(
                        onPressed: stopTrainingCycle,
                        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      ),
                      const Text(
                        '기억 회상 훈련',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '향을 발향하는 중입니다.',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            remainTime.toString(),
                            style: const TextStyle(
                              fontSize: 92,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "초 뒤, 발향이 중지됩니다.",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: extendTime,
                      icon: const Icon(Icons.timer),
                      label: const Text(
                        "시간 연장하기",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: Color(0xFFF9F9F9),
                        foregroundColor: Color(0xFF335928),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
