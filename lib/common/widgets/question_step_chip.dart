import 'package:flutter/material.dart';

class QuestionStepChip extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const QuestionStepChip({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return RawChip(
      backgroundColor: const Color(0xFF2E7D32),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 4,
      shadowColor: Colors.black45,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Q.',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(width: 6),

          // 애니메이션 되는 부분만 따로 AnimatedSwitcher
          SizedBox(
            height: 20,
            child: ClipRect(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) {
                  final isNew =
                      (child.key as ValueKey<int>).value == currentStep;

                  final offsetTween = Tween<Offset>(
                    begin: isNew ? const Offset(0, -0.7) : Offset.zero,
                    end: isNew ? Offset.zero : const Offset(0, 0.7),
                  );

                  return SlideTransition(
                    position: offsetTween.animate(
                      CurvedAnimation(parent: anim, curve: Curves.ease),
                    ),
                    child: FadeTransition(opacity: anim, child: child),
                  );
                },
                child: Text(
                  '$currentStep',
                  key: ValueKey<int>(currentStep),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 0.5,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 2),
          Text(
            ' / $totalSteps',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
