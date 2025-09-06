import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:deepscent_cnu/common/presentation/controller/auth_controller.dart';
import 'package:deepscent_cnu/features/login/presentation/screens/login.dart';

enum CustomAppBarMode { main, sub }

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final CustomAppBarMode mode;
  final String? title;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    this.mode = CustomAppBarMode.main,
    this.title,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final logoWidth = screenWidth * 0.20; // 화면 너비의 20%
    final iconSize = screenWidth * 0.05;  // 화면 너비의 6%
    final horizontalPadding = screenWidth * 0.05;
    final topPadding = screenHeight * 0.025; // 화면 높이의 2.5%

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: kToolbarHeight + topPadding, // AppBar 자체 높이 늘림
      leadingWidth: mode == CustomAppBarMode.main
          ? logoWidth + horizontalPadding * 2
          : null,
      leading: mode == CustomAppBarMode.main
          ? Padding(
              padding: EdgeInsets.only(left: horizontalPadding),
              child: Image.asset(
                'assets/images/logo.png',
                width: logoWidth,
                fit: BoxFit.contain,
              ),
            )
          : Padding(
              padding: EdgeInsets.only(left: horizontalPadding),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, size: iconSize, color: Colors.black),
                onPressed: onBackPressed ?? () => Navigator.pop(context),
              ),
            ),
      title: mode == CustomAppBarMode.sub && title != null
          ? Text(
              title!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            )
          : null,
      centerTitle: false,
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
    final topPadding = screenHeight * 0.025;
    return Size.fromHeight(kToolbarHeight + topPadding);
  }
}
