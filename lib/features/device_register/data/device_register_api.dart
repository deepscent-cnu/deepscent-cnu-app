import 'dart:convert';

import 'package:deepscent_cnu/common/presentation/controller/auth_controller.dart';
import 'package:deepscent_cnu/features/device_register/model/device_ids.dart';
import 'package:deepscent_cnu/secrets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class DeviceRegisterApi {
  static Future<DeviceIds?> getDeviceIds() async {
    final authController = Get.find<AuthController>();
    final apiUrl = '$apiBaseUrl/api/device';
    final requestHeaders = {
      'Content-type': 'application/json',
      'Authorization': 'Bearer ${authController.accessToken.value}',
    };

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: requestHeaders,
      );

      if (response.statusCode == 200) {
        debugPrint('(Debug) 응답 상태 코드: ${response.statusCode}');

        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        return DeviceIds.fromJson(jsonData);
      } else {
        debugPrint('(Debug) 문제 선택지 API 호출 중 오류 발생');
        return null;
      }
    } catch (e) {
      debugPrint('(Debug) 기기 ID 전체 조회 API 호출 중 오류 발생: $e');
    }

    return null;
  }

  static Future<http.Response> registerDeviceId(
    int deviceNumber,
    String deviceId,
  ) async {
    final authController = Get.find<AuthController>();
    final apiUrl = '$apiBaseUrl/api/device/register';
    final requestHeaders = {
      'Content-type': 'application/json',
      'Authorization': 'Bearer ${authController.accessToken.value}',
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: requestHeaders,
      body: jsonEncode({
        "deviceNumber": deviceNumber.toString(),
        "deviceId": deviceId,
      }),
    );

    if (response.statusCode == 204) {
      debugPrint('(Debug) 응답 상태 코드: ${response.statusCode}');
    } else {
      debugPrint('(Debug) 기기 ID 등록 API 호출 중 오류 발생');
      debugPrint(
        '(Debug) 응답 본문: ${jsonDecode(utf8.decode(response.bodyBytes))}',
      );
    }

    return response;
  }
}
