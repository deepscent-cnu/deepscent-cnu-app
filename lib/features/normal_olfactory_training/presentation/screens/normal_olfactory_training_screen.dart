import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/widgets/scent_notice.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/widgets/scentraining_header.dart';
import 'package:flutter/material.dart';
import 'package:deepscent_cnu/secrets.dart';

class NormalOlfactoryTrainingScreen extends StatefulWidget {
  const NormalOlfactoryTrainingScreen({super.key});

  @override
  State<NormalOlfactoryTrainingScreen> createState() =>
      _NormalOlfactoryTrainingScreenState();
}

class _NormalOlfactoryTrainingScreenState
    extends State<NormalOlfactoryTrainingScreen> {
  String message = '10초간 1번 슬롯의 향기를 분출합니다. 향기와 관련된 물체를 상상하면서 향에 집중해주세요!';

  @override
  void initState() {
    super.initState();
    startTrainingCycle();
  }

  Future<void> startTrainingCycle() async {
    for (int fanNumber = 0; fanNumber < 4; fanNumber++) {
      setState(() {
        message =
            '10초간 ${fanNumber + 1}번 슬롯의 향기를 분출합니다. 향기와 관련된 물체를 상상하면서 향에 집중해주세요!';
      });

      await controlScentDeviceSlot(fanNumber, 3);
      await Future.delayed(const Duration(seconds: 10));

      setState(() {
        message = '발향을 중지합니다. 10초간 편안히 휴식해주세요!';
      });

      await controlScentDeviceSlot(fanNumber, 0);
      await Future.delayed(const Duration(seconds: 10));
    }

    // if (context.mounted) {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (_) => const TrainingResult()),
    //   );
    // }
  }

  Future<void> controlScentDeviceSlot(int fanNumber, int fanSpeed) async {
    final apiUrl = apiBaseUrl + '/device/' + deviceId + "/fragrance/fan-state";

    final requestHeaders = {
      'Content-type': 'application/json',
      'Authorization': '$deepscentToken',
    };

    final requestBody = jsonEncode({
      'fan_number': fanNumber,
      'fan_speed': fanSpeed,
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: requestHeaders,
        body: requestBody,
      );

      debugPrint('(Debug) 응답 상태 코드: ${response.statusCode}');
    } catch (e) {
      debugPrint('(Debug) 향기 제어 API 호출 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScenTrainingHeader(trainingTitle: "일반 후각 훈련"),
            Expanded(child: Center(child: ScentNotice(message: message))),
          ],
        ),
      ),
    );
  }
}
