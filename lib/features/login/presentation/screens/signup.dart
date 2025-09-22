import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:deepscent_cnu/common/widgets/custom_alert.dart';
import 'package:deepscent_cnu/common/widgets/loading_overlay.dart';
import '../../data/auth_api.dart';
import 'dart:convert';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final birthController = TextEditingController();
  final phoneController = TextEditingController();
  final pwController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    birthController.dispose();
    phoneController.dispose();
    pwController.dispose();
    super.dispose();
  }

  Future<void> handleSignUp(double screenWidth) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LoadingOverlay(message: '회원가입 중입니다...'),
    );

    try {
      final response = await AuthApi.signup(
        name: nameController.text,
        birthDate: birthController.text,
        phoneNumber: phoneController.text,
        password: pwController.text,
      );

      Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('회원가입 성공: $data');
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: Text(
                  "회원가입 완료",
                  style: TextStyle(fontSize: screenWidth * 0.06),
                ),
                content: Text(
                  "로그인 화면으로 이동합니다.",
                  style: TextStyle(fontSize: screenWidth * 0.07),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text(
                      "확인",
                      style: TextStyle(fontSize: screenWidth * 0.05),
                    ),
                  ),
                ],
              ),
        );
      } else {
        debugPrint('회원가입 실패: ${jsonDecode(utf8.decode(response.bodyBytes))}');
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: Text(
                  "회원가입 실패",
                  style: TextStyle(fontSize: screenWidth * 0.06),
                ),
                content: Text(
                  jsonDecode(utf8.decode(response.bodyBytes))['message'],
                  style: TextStyle(fontSize: screenWidth * 0.07),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "확인",
                      style: TextStyle(fontSize: screenWidth * 0.05),
                    ),
                  ),
                ],
              ),
        );
      }
    } catch (e, stack) {
      Navigator.pop(context);
      print('회원가입 예외 발생: $e');
      print(stack);
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.07),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        size: screenWidth * 0.09,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.015),
                      child: Text(
                        "로그인 화면으로",
                        style: TextStyle(fontSize: screenWidth * 0.05),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 260,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextFormField(
                        screenWidth: screenWidth,
                        hintText: '이름',
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '이름을 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                      _buildTextFormField(
                        screenWidth: screenWidth,
                        hintText: '생년월일 (YYYY-MM-DD)',
                        controller: birthController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '생년월일을 입력해주세요.';
                          }
                          final regex = RegExp(r'^\d{4}-\d{1,2}-\d{1,2}$');
                          if (!regex.hasMatch(value)) {
                            return '올바른 날짜 형식이 아닙니다.\n(올바른 형식 : YYYY-MM-DD)';
                          }
                          try {
                            final date = DateTime.parse(value);
                            if (date.isAfter(DateTime.now())) {
                              return '미래 날짜는 입력할 수 없습니다.';
                            }
                          } catch (e) {
                            return '존재하지 않는 날짜입니다.';
                          }
                          return null;
                        },
                      ),
                      _buildTextFormField(
                        screenWidth: screenWidth,
                        hintText: '전화번호 (\'-\' 제외)',
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '전화번호를 입력해주세요.';
                          }
                          final regex = RegExp(r'^010\d{8}$');
                          if (!regex.hasMatch(value)) {
                            return '올바른 전화번호 형식이 아닙니다.\n(올바른 형식 : 010-1234-5678)';
                          }
                          return null;
                        },
                      ),
                      _buildTextFormField(
                        screenWidth: screenWidth,
                        hintText: '비밀번호',
                        controller: pwController,
                        isObscure: true, // 비밀번호 숨김 처리
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '비밀번호를 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF43A047),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          // Form의 유효성 검사 실행
                          if (formKey.currentState!.validate()) {
                            // 검사가 모두 통과했을 때 실행될 로직
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '회원가입 처리중...',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            );
                            // 실제 회원가입 API 호출
                            handleSignUp(screenWidth);
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.035),
                          child: Text(
                            '가입하기',
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
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

Widget _buildTextFormField({
  required String hintText,
  required TextEditingController controller,
  required String? Function(String?) validator,
  required double screenWidth,
  bool isObscure = false,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: screenWidth * 0.015),
    child: TextFormField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(fontSize: screenWidth * 0.05),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: screenWidth * 0.05),
        // 기본 테두리
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        // 포커스되었을 때 테두리
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.deepPurple,
            width: 2,
          ), // 포커스 색상 강조
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.035,
          vertical: screenWidth * 0.03,
        ),
        errorMaxLines: 3,
        errorStyle: TextStyle(
          fontSize: screenWidth * 0.048,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
