import 'dart:convert';

import 'package:deepscent_cnu/common/presentation/controller/auth_controller.dart';
import 'package:deepscent_cnu/secrets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class DeviceApi {
  static Future<void> controlScentDeviceSlot(
    int deviceNumber,
    int fanNumber,
    int fanSpeed,
  ) async {
    final authController = Get.find<AuthController>();
    final apiUrl = '$apiBaseUrl/api/device/fragrance/fan-state';

    final requestHeaders = {
      'Content-type': 'application/json',
      'Authorization': 'Bearer ${authController.accessToken.value}',
    };

    final requestBody = jsonEncode({
      'deviceNumber': deviceNumber,
      'fanNumber': fanNumber,
      'fanSpeed': fanSpeed,
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: requestHeaders,
        body: requestBody,
      );

      debugPrint('(Debug) 응답 상태 코드: ${response.statusCode}');
      if (fanSpeed == 0) {
        debugPrint('(Debug) 발향 중지 동작 성공');
      } else {
        debugPrint('(Debug) 발향 시작 동작 성공');
      }
    } catch (e) {
      debugPrint('(Debug) 향기 제어 API 호출 중 오류 발생: $e');
    }
  }
}
