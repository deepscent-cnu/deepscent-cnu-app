import 'package:flutter/material.dart';

class ButtonBasic extends StatelessWidget {
  final String content;
  final Icon icon;
  final VoidCallback function;

  const ButtonBasic({super.key, required this.content, required this.icon, required this.function});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: function,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: Color(0xFFF9F9F9),
        foregroundColor: Color(0xFF335928),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: icon,
      label: Text(
        content,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
