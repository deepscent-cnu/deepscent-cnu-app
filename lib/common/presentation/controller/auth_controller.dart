import 'dart:convert';

import 'package:deepscent_cnu/secrets.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  var accessToken = ''.obs;

  Future<void> adminLogin() async {
    final apiUrl = '$apiBaseUrl/api/auth/login';
    final requestHeaders = {'Content-type': 'application/json'};

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: requestHeaders,
        body: jsonEncode({
          'username': adminUsername,
          'password': adminPassword,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('(Debug) 관리자 로그인 API 응답 상태 코드: ${response.statusCode}');

        final Map<String, dynamic> body = jsonDecode(
          utf8.decode(response.bodyBytes),
        );

        accessToken.value = body['data'];
      } else {
        debugPrint('(Debug) 관리자 로그인 실패: ${response.statusCode}');
        debugPrint(
          '(Debug) 응답 본문: ${jsonDecode(utf8.decode(response.bodyBytes))}',
        );
      }
    } catch (e) {
      debugPrint('(Debug) 관리자 로그인 중 오류 발생 : $e');
    }
  }
}
