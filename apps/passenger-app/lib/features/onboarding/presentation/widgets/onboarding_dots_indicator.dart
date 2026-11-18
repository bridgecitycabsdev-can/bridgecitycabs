import 'package:flutter/material.dart';

/// Animated page dots indicator:
/// Active page displays as an elongated crimson pill (22x6),
/// Inactive pages display as compact grey dots (6x6).
class OnboardingDotsIndicator extends StatelessWidget {
  final int activeIndex;
  final int count;

  const OnboardingDotsIndicator({
    super.key,
    required this.activeIndex,
    this.count = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(right: 6),
          width: isActive ? 22 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFB71C1C)
                : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
