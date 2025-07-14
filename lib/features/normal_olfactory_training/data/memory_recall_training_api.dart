import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MemoryRecallTrainingApi {
  static Future<String?> sendAudioToSTT(File audioFile) async {
    final apiUrl = 'http://10.0.2.2:8080/api/stt/upload';
    final request = http.MultipartRequest("POST", Uri.parse(apiUrl));
    request.files.add(await http.MultipartFile.fromPath("audio", audioFile.path));

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        debugPrint('(Debug) STT 응답 상태 코드: ${response.statusCode}');
        debugPrint('(Debug) STT 응답 본문: $responseBody');

        final match = RegExp(r'"transcript"\s*:\s*"([^"]+)"')
            .firstMatch(responseBody);

        if (match != null) {
          return match.group(1);
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
}
