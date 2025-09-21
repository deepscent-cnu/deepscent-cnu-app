import 'dart:convert';

import 'package:deepscent_cnu/features/device_register/data/device_register_api.dart';
import 'package:deepscent_cnu/features/device_register/model/device_ids.dart';
import 'package:deepscent_cnu/common/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeviceRegisterScreen extends StatefulWidget {
  const DeviceRegisterScreen({super.key});

  @override
  State<DeviceRegisterScreen> createState() => _DeviceRegisterScreenState();
}

class _DeviceRegisterScreenState extends State<DeviceRegisterScreen> {
  final formKeys = List.generate(3, (_) => GlobalKey<FormState>());

  final deviceId1Controller = TextEditingController();
  final deviceId2Controller = TextEditingController();
  final deviceId3Controller = TextEditingController();

  final textEditingControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );

  DeviceIds? deviceIds;
  List<String?> currentDeviceIds = [];

  bool isLoading = true;
  bool isLoadingRegister = false;

  @override
  void initState() {
    super.initState();
    getDeviceIds();
  }

  Future<void> getDeviceIds() async {
    deviceIds = await DeviceRegisterApi.getDeviceIds();

    if (deviceIds != null) {
      setState(() {
        isLoading = false;
        currentDeviceIds.addAll([
          deviceIds?.deviceId1,
          deviceIds?.deviceId2,
          deviceIds?.deviceId3,
        ]);
      });
    }
  }

  Future<void> handleRegisterDeviceId(int deviceNumber, String deviceId) async {
    double screenWidth = MediaQuery.of(context).size.width;

    setState(() {
      isLoadingRegister = true;
    });

    final response = await DeviceRegisterApi.registerDeviceId(
      deviceNumber,
      deviceId,
    );

    if (response.statusCode == 204) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text(
                "기기 등록",
                style: TextStyle(fontSize: screenWidth * 0.06),
              ),
              content: Text(
                "$deviceNumber번 기기 등록이 완료되었습니다.",
                style: TextStyle(fontSize: screenWidth * 0.07),
              ),
              actions: [
                TextButton(
                  onPressed: () {
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
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text(
                "기기 등록 실패",
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

    setState(() {
      isLoadingRegister = false;
    });
  }

  @override
  void dispose() {
    deviceId1Controller.dispose();
    deviceId2Controller.dispose();
    deviceId3Controller.dispose();

    for (final controller in textEditingControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        mode: CustomAppBarMode.sub,
        title: "기기 등록",
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child:
            isLoading
                ? Container(
                  color: Colors.black.withOpacity(0.5), // 화면 어두워짐
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          '로딩 중...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
                : Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 24),
                            ...List.generate(3, (index) => buildForm(index)),
                          ],
                        ),
                      ),
                    ),
                    isLoadingRegister
                        ? Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 16),
                                Text(
                                  '로딩 중...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        : SizedBox.shrink(),
                  ],
                ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String hintText,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool isObscure = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        style: TextStyle(fontSize: 24),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 24),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          errorMaxLines: 3,
          errorStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildForm(int index) {
    final deviceNumber = index + 1;
    final currentId = currentDeviceIds[index];
    final controller = textEditingControllers[index];
    final formKey = formKeys[index];

    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "$deviceNumber번 기기",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("현재 등록된 기기", style: TextStyle(fontSize: 24)),
            Text(
              ': ${currentId ?? "없음"}', // null이면 "없음" 표시
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 12),
            _buildTextFormField(
              hintText: '$deviceNumber번 기기의 ID를 입력하세요.',
              controller: controller,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$deviceNumber번 기기의 ID를 입력하세요.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2F2F2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  handleRegisterDeviceId(deviceNumber, controller.text);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: const Text(
                  '등록하기',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFF335928),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Divider(height: 5, color: Colors.grey, thickness: 8),
          ],
        ),
      ),
    );
  }
}
