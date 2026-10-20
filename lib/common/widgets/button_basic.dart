import 'package:flutter/material.dart';

class ButtonBasic extends StatelessWidget {
  final String content;
  final Icon? icon;
  final double? fontSize;
  final VoidCallback? function;
  // ✅ 추가
  final String? imageAssetPath;
  final double? imageHeight;

  const ButtonBasic({
    super.key,
    required this.content,
    this.icon,
    this.fontSize,
    this.function,
    this.imageAssetPath,
    this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        function == null ? Colors.grey : const Color(0xFFF9F9F9);
    final foregroundColor =
        function == null ? Colors.white : const Color(0xFF335928);

    //추가
    final baseStyle = ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(50),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
    );

//수정
    // 1) icon 버튼은 기존 유지 (원하면 여기도 이미지 지원 가능)
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: function,
        style: baseStyle,
        icon: icon!,
        label: Text(
          content,
          style: TextStyle(
            fontSize: fontSize ?? 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // 2) 이미지+텍스트 버튼 (질문 보기용)
    if (imageAssetPath != null) {
      return ElevatedButton(
        onPressed: function,
        style: baseStyle,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Image.asset(
                  imageAssetPath!,
                  height: imageHeight, // Expanded 안이라 없어도 OK
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize ?? 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // 3) 텍스트-only 버튼 (기존 유지)
    return ElevatedButton(
      onPressed: function,
      style: baseStyle,
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

    //기존
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
