// lib/common/widgets/loading_overlay.dart
import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final String message;

  const LoadingOverlay({
    super.key,
    this.message = '로딩 중입니다...',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: const ValueKey("loading"),
      children: [
        const ModalBarrier(
          dismissible: false,
          color: Colors.black38,
        ),
        Center(
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 40,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: Color(0xFF335928),
                    strokeWidth: 5,
                  ),
                  const SizedBox(height: 24),

                  // 어색한 줄바꿈 방지
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: message
                        .split(' ')
                        .map(
                          (word) => Text(
                            '$word ',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF335928),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
