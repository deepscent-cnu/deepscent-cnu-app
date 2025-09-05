import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:deepscent_cnu/common/presentation/controller/auth_controller.dart';
import 'package:deepscent_cnu/features/login/presentation/screens/login.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final logoWidth = screenWidth * 0.20; // 화면 너비의 25%
    final iconSize = screenWidth * 0.05;  // 화면 너비의 6%
    final horizontalPadding = screenWidth * 0.05;
    final topPadding = screenHeight * 0.05; // 화면 높이의 5%

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: kToolbarHeight + topPadding, // AppBar 자체 높이 늘림
      leadingWidth: logoWidth + horizontalPadding * 2,
      leading: Padding(
        padding: EdgeInsets.only(left: horizontalPadding),
        child: Image.asset(
          'assets/images/logo.png',
          width: logoWidth,
          fit: BoxFit.contain,
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: horizontalPadding),
          child: IconButton(
            icon: Icon(Icons.logout, color: Colors.black, size: iconSize),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('로그아웃'),
                  content: const Text('정말 로그아웃 하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('확인'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                final authController = Get.find<AuthController>();
                authController.accessToken.value = '';

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize {
    // toolbarHeight와 동일하게 맞춤
    final screenHeight = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.height /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    final topPadding = screenHeight * 0.05;
    return Size.fromHeight(kToolbarHeight + topPadding);
  }
}
