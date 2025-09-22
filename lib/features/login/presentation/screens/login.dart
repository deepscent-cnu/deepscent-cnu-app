import 'package:deepscent_cnu/common/presentation/controller/auth_controller.dart';
import 'package:deepscent_cnu/features/training_list/presentation/screens/olfactory_training_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'signup.dart';
import 'package:deepscent_cnu/common/widgets/custom_alert.dart';
import '../../data/auth_api.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final authController = Get.find<AuthController>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  Future<void> handleLogin() async {
    try {
      final response = await AuthApi.login(
        username: phoneController.text,
        password: pwController.text,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['data'];

        // 액세스 토큰 로컬 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwtToken', token);

        // 로그인 성공 처리
        authController.accessToken.value = token;
        print('로그인 성공: $data');

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const OlfactoryTrainingListScreen(),
            transitionsBuilder: (_, animation, __, child) {
              final slide = Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );
              return SlideTransition(
                position: slide,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('로그인 실패', style: TextStyle(fontSize: 28)),
                content: const Text(
                  '아이디 또는 비밀번호가 올바르지 않습니다.',
                  style: TextStyle(fontSize: 24),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('확인', style: TextStyle(fontSize: 24)),
                  ),
                ],
              ),
        );
      }
    } catch (_) {
      CustomAlert.show(
        context,
        title: '연결 오류',
        message: '서버와 연결할 수 없습니다.\n네트워크 상태를 확인해주세요.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenWidth * 0.105),
                Image.asset(
                  'assets/images/logo.png',
                  width: 260,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: screenWidth * 0.085),
                TextField(
                  controller: phoneController,
                  style: TextStyle(fontSize: screenWidth * 0.05),
                  decoration: InputDecoration(
                    hintText: '전화번호를 입력해주세요.',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.05,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: screenWidth * 0.05),
                TextField(
                  controller: pwController,
                  obscureText: true,
                  style: TextStyle(fontSize: screenWidth * 0.05),
                  decoration: InputDecoration(
                    hintText: '비밀번호를 입력해주세요.',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.05,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: screenWidth * 0.105),
                SizedBox(
                  width: double.infinity,
                  height: screenWidth * 0.105,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF43A047),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: handleLogin, // 여기서 API 호출
                    child: Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenWidth * 0.035),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpPage(),
                      ),
                    );
                  },
                  child: Text(
                    '아직 계정이 없으신가요?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.05,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
