import 'dart:convert';

import 'package:deepscent_cnu/secrets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DeviceApi {
  static Future<void> controlScentDeviceSlot(
    int fanNumber,
    int fanSpeed,
  ) async {
    final apiUrl =
        apiBaseUrl + '/api/device/' + deviceId + "/fragrance/fan-state";

    final requestHeaders = {'Content-type': 'application/json'};

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
}
