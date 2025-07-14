import 'package:flutter/material.dart';
import '../../data/auth_api.dart';
import 'dart:convert';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final birthController = TextEditingController();
  final phoneController = TextEditingController();
  final idController = TextEditingController();
  final pwController = TextEditingController();

  Future<void> handleSignUp() async {
    final response = await AuthApi.signup(
      name: nameController.text,
      birthDate: birthController.text,
      phoneNumber: phoneController.text,
      username: idController.text,
      password: pwController.text,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint('회원가입 성공: $data');
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("회원가입 완료"),
              content: const Text("로그인 화면으로 이동합니다."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text("확인"),
                ),
              ],
            ),
      );
    } else {
      debugPrint('회원가입 실패: ${response.body}');
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("회원가입 실패"),
              content: const Text("정보를 다시 확인해주세요."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("확인"),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: const Color(0xFFE8F5E9),
                    child: const Text(
                      'SCENTRAINING',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF43A047),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _buildTextField('이름을 입력해주세요.', controller: nameController),
                const SizedBox(height: 12),
                _buildTextField('생년월일을 입력해주세요.', controller: birthController),
                const SizedBox(height: 12),
                _buildTextField('전화번호를 입력해주세요.', controller: phoneController),
                const SizedBox(height: 12),
                _buildTextField(
                  'ID를 입력해주세요.',
                  controller: idController,
                  isBold: true,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  '비밀번호를 입력해주세요.',
                  controller: pwController,
                  isObscure: true,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF43A047),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: handleSignUp,
                    child: const Text('회원가입', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hintText, {
    required TextEditingController controller,
    bool isObscure = false,
    bool isBold = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
