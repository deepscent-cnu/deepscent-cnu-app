import 'package:flutter/material.dart';

class ButtonBasic extends StatelessWidget {
  final String content;
  final Icon? icon;
  final double? fontSize;
  final VoidCallback? function;

  const ButtonBasic({
    super.key,
    required this.content,
    this.icon,
    this.fontSize,
    this.function,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        function == null ? Colors.grey : const Color(0xFFF9F9F9);
    final foregroundColor =
        function == null ? Colors.white : const Color(0xFF335928);

    return icon != null
        ? ElevatedButton.icon(
          onPressed: function, // ✅ null이면 자동 비활성화
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(10),
          ),
          icon: icon!,
          label: Text(
            content,
            style: TextStyle(
              fontSize: fontSize ?? 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
        : ElevatedButton(
          onPressed: function,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(10),
          ),
          child: FittedBox(
            child: Text(
              content,
              style: TextStyle(
                fontSize: fontSize ?? 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
  }
}
