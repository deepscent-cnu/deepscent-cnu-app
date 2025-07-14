import 'dart:convert';

import 'package:deepscent_cnu/common/presentation/controller/auth_controller.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/data/models/scent_options.dart';
import 'package:deepscent_cnu/secrets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NormalOlfactoryTrainingApi {
  static Future<ScentOptions?> getScentOptions(int round) async {
    final authController = Get.find<AuthController>();
    final apiUrl =
        '$apiBaseUrl/api/device/$deviceId/fragrance/scent-option?round=$round';
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
        return ScentOptions.fromJson(jsonData);
      } else {
        debugPrint('(Debug) 문제 선택지 API 호출 중 오류 발생');
        return null;
      }
    } catch (e) {
      debugPrint('(Debug) 문제 선택지 API 호출 중 오류 발생: $e');
    }
    return null;
  }

  static Future<void> submitTrainingLog(
    int totalTimeTaken,
    List<Map<String, dynamic>> roundLogs,
  ) async {
    final authController = Get.find<AuthController>();
    final apiUrl = '$apiBaseUrl/api/normal-olfactory-training/log';
    final requestHeaders = {
      'Content-type': 'application/json',
      'Authorization': 'Bearer ${authController.accessToken.value}',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: requestHeaders,
        body: jsonEncode({
          'totalTimeTaken': totalTimeTaken,
          'roundLogs': roundLogs,
        }),
      );

      if (response.statusCode == 204) {
        debugPrint(
          '(Debug) 일반 후각 훈련 로그 등록 API 응답 상태 코드: ${response.statusCode}',
        );
      } else {
        debugPrint('(Debug) 일반 후각 훈련 로그 등록 실패: ${response.statusCode}');
        debugPrint(
          '(Debug) 응답 본문: ${jsonDecode(utf8.decode(response.bodyBytes))}',
        );
      }
    } catch (e) {
      debugPrint('(Debug) 일반 후각 훈련 로그 등록 API 호출 중 오류 발생: $e');
    }
  }
}
