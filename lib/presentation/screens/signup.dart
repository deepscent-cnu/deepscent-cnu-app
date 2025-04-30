import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

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
                _buildTextField('이름을 입력해주세요.'),
                const SizedBox(height: 12),
                _buildTextField('생년월일을 입력해주세요.'),
                const SizedBox(height: 12),
                _buildTextField('전화번호를 입력해주세요.'),
                const SizedBox(height: 12),
                _buildTextField('ID를 입력해주세요.', isBold: true),
                const SizedBox(height: 12),
                _buildTextField('비밀번호를 입력해주세요.', isObscure: true),
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
                    onPressed: () {},
                    child: const Text(
                      '회원가입',
                      style: TextStyle(fontSize: 18),
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

  Widget _buildTextField(String hintText, {bool isObscure = false, bool isBold = false}) {
    return TextField(
      obscureText: isObscure,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
