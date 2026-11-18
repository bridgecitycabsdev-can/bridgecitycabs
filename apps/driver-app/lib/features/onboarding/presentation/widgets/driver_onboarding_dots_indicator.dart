import 'package:flutter/material.dart';

class DriverOnboardingDotsIndicator extends StatelessWidget {
  final int totalCount;
  final int currentIndex;

  const DriverOnboardingDotsIndicator({
    super.key,
    required this.totalCount,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalCount, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(right: 6),
          height: 6,
          width: isActive ? 22 : 6,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFC91A25) : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
