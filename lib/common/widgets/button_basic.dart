import 'package:flutter/material.dart';

class ButtonBasic extends StatelessWidget {
  final String content;
  final Icon? icon;
  final double? fontSize;
  final VoidCallback function;

  const ButtonBasic({
    super.key,
    required this.content,
    this.icon,
    this.fontSize,
    required this.function,
  });

  @override
  Widget build(BuildContext context) {
    return icon != null
        ? ElevatedButton.icon(
          onPressed: function,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: Color(0xFFF9F9F9),
            foregroundColor: Color(0xFF335928),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: icon,
          label: Text(
            content,
            style: TextStyle(
              fontSize: fontSize ?? 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
        : ElevatedButton.icon(
          onPressed: function,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: Color(0xFFF9F9F9),
            foregroundColor: Color(0xFF335928),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          label: Text(
            content,
            style: TextStyle(
              fontSize: fontSize ?? 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
  }
}
