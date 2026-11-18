import 'package:flutter/material.dart';

class DriverOnboardingQaMatrixBar extends StatelessWidget {
  final int currentIndex;
  final bool isSubmitting;
  final Function(int targetIndex, bool isSubmitting) onSelectState;

  const DriverOnboardingQaMatrixBar({
    super.key,
    required this.currentIndex,
    required this.isSubmitting,
    required this.onSelectState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildChip(
              label: '1. Get Rides',
              index: 0,
              submitting: false,
            ),
            const SizedBox(width: 6),
            _buildChip(
              label: '2. Earn More',
              index: 1,
              submitting: false,
            ),
            const SizedBox(width: 6),
            _buildChip(
              label: '3. Support (Ready)',
              index: 2,
              submitting: false,
            ),
            const SizedBox(width: 6),
            _buildChip(
              label: '4. Setting Up Dispatch',
              index: 2,
              submitting: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required int index,
    required bool submitting,
  }) {
    final isSelected = currentIndex == index && isSubmitting == submitting;
    return GestureDetector(
      onTap: () => onSelectState(index, submitting),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC91A25) : Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
