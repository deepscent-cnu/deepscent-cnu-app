import 'dart:convert';
import 'dart:io';
import 'package:deepscent_cnu/features/memory_recall_training/data/model/scent_info.dart';
import 'package:deepscent_cnu/secrets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:deepscent_cnu/common/presentation/controller/auth_controller.dart';
import 'package:get/get.dart';

class MemoryRecallTrainingApi {
  /// 🧠 1. STT만 처리 (userId 필요 없음)
  static Future<String?> sendAudioToSTT(File audioFile) async {
    final authController = Get.find<AuthController>();
    final accessToken = authController.accessToken.value;

    final sttApiUrl = 'http://10.0.2.2:8080/api/stt/upload';

    final request = http.MultipartRequest("POST", Uri.parse(sttApiUrl));
    request.files.add(
      await http.MultipartFile.fromPath("audio", audioFile.path),
    );
    request.headers.addAll({
      'Content-type': 'multipart/form-data',
      'Authorization': 'Bearer $accessToken',
    });

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        debugPrint('(Debug) STT 응답 상태 코드: ${response.statusCode}');
        debugPrint('(Debug) STT 응답 본문: $responseBody');

        final match = RegExp(
          r'"transcript"\s*:\s*"([^"]+)"',
        ).firstMatch(responseBody);
        if (match != null) {
          return match.group(1); // 텍스트만 반환
        } else {
          debugPrint('(Debug) 정규식 매칭 실패');
          return null;
        }
      } else {
        debugPrint('(Debug) STT 요청 실패: $responseBody');
        return null;
      }
    } catch (e) {
      debugPrint('(Debug) STT 요청 중 예외 발생: $e');
      return null;
    }
  }

  /// 💬 2. Chat API (userId 필요)
  static Future<String?> sendChatToAI(int userId, String userMessage) async {
    final authController = Get.find<AuthController>();
    final accessToken = authController.accessToken.value;

    final chatApiUrl = 'http://10.0.2.2:8080/api/chat1/$userId';

    try {
      final response = await http.post(
        Uri.parse(chatApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'userMessage': userMessage}),
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        debugPrint(
          'Chat 실패: ${response.statusCode} - ${jsonDecode(utf8.decode(response.bodyBytes))}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Chat 예외 발생: $e');
      return null;
    }
  }

  static Future<int> getLastRound() async {
    final authController = Get.find<AuthController>();
    final apiUrl = '$apiBaseUrl/api/chat/last-round';
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
        return jsonData['lastRound'] ?? 0;
      } else {
        debugPrint('(Debug) 마지막 완료 회차 수 조회 API 호출 중 오류 발생');
        return 0;
      }
    } catch (e) {
      debugPrint('(Debug) 마지막 완료 회차 수 조회 API 호출 중 오류 발생: $e');
    }

    return 0;
  }

  static Future<List<ScentInfo>?> getScentAll() async {
    final authController = Get.find<AuthController>();
    final apiUrl = '$apiBaseUrl/api/device/fragrance/capsule-info';
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

        final Map<String, dynamic> jsonData = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        final List<dynamic> scentAll = jsonData['capsuleInfoList'];
        return scentAll.map((item) => ScentInfo.fromJson(item)).toList();
      } else {
        debugPrint('(Debug) 일반 후각 훈련 정답 향기 4개 선별 API 호출 중 오류 발생');
        return null;
      }
    } catch (e) {
      debugPrint('(Debug) 일반 후각 훈련 정답 향기 4개 선별 API 호출 중 오류 발생: $e');
    }
    return null;
  }
}
