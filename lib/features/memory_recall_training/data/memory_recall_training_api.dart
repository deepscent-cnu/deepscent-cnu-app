import 'dart:convert';
import 'dart:io';
import 'package:deepscent_cnu/features/memory_recall_training/data/model/scent_info.dart';
import 'package:deepscent_cnu/secrets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:deepscent_cnu/common/presentation/controller/auth_controller.dart';
import 'package:get/get.dart';

class MemoryRecallTrainingApi {
  /// 🧠 1. STT 업로드
  static Future<String?> sendAudioToSTT(File audioFile) async {
    final authController = Get.find<AuthController>();
    final accessToken = authController.accessToken.value;

    final sttApiUrl = 'http://10.0.2.2:8080/api/stt/upload';

    final request = http.MultipartRequest("POST", Uri.parse(sttApiUrl));
    request.files.add(await http.MultipartFile.fromPath("audio", audioFile.path));
    request.headers.addAll({
      'Content-type': 'multipart/form-data',
      'Authorization': 'Bearer $accessToken',
    });

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final match = RegExp(r'"transcript"\s*:\s*"([^"]+)"').firstMatch(responseBody);
        return match?.group(1);
      } else {
        debugPrint('(Debug) STT 요청 실패: $responseBody');
        return null;
      }
    } catch (e) {
      debugPrint('(Debug) STT 예외: $e');
      return null;
    }
  }

  //일반 대화
  static Future<String?> sendChatToAI(int roundId, String userMessage) async {
    final authController = Get.find<AuthController>();
    final accessToken = authController.accessToken.value;

    final chatApiUrl = 'http://10.0.2.2:8080/api/chat/$roundId';

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
        debugPrint('Chat 실패: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}');
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

  /// 3. 사용자가 작성한 "느낀 점" 저장 API
  /// - roundId: 회차 ID
  /// - feeling: 사용자가 입력한 느낀 점
  /// - 성공 시 true 반환, 실패 시 false 반환
  static Future<bool> saveFeeling(int roundId, String feeling) async {
    final authController = Get.find<AuthController>();
    final accessToken = authController.accessToken.value;

    final apiUrl = '$apiBaseUrl/api/memory-recall-training/log/$roundId/feeling';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'feeling': feeling}),
      );

      return response.statusCode == 204;  // 서버에서 noContent 반환 시 성공 처리
    } catch (e) {
      debugPrint('(Debug) saveFeeling 예외 발생: $e');
      return false;
    }
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
      return null;
    }
  }

  static Future<Map<String, dynamic>?> startChatWithScent({
    required int roundId,
    required String scent,
  }) async {
    final authController = Get.find<AuthController>();
    final accessToken = authController.accessToken.value;

    const userId = 1; // 하드코딩
    final url =
        '$apiBaseUrl/api/chat/start/$roundId?scent=${Uri.encodeQueryComponent(scent)}';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({}), 
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else {
          debugPrint('(Debug) JSON 객체가 아님: $decoded');
          return null;
        }
      } else {
        debugPrint('(Debug) startChatWithScent 실패: '
            '${response.statusCode} - ${utf8.decode(response.bodyBytes)}');
        return null;
      }
    } catch (e) {
      debugPrint('(Debug) startChatWithScent 예외: $e');
      return null;
    }
  }
}
