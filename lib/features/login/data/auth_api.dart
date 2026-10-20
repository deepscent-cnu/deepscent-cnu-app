// lib/src/features/auth/data/auth_api.dart
import 'package:deepscent_cnu/secrets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthApi {
  static Future<http.Response> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$apiBaseUrl/api/auth/login');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phoneNumber': username,
        'password': password,
      }),
    );
  }

  static Future<http.Response> signup({
    required String name,
    required String birthDate,
    required String phoneNumber,
    required String password,
  }) async {
    final url = Uri.parse('$apiBaseUrl/api/auth/signup');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'birthDate': birthDate,
        'phoneNumber': phoneNumber,
        'password': password,
      }),
    );
  }
}
