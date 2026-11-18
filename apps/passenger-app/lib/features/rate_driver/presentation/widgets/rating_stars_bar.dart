import 'package:flutter/material.dart';

class RatingStarsBar extends StatelessWidget {
  final int selectedStars;
  final ValueChanged<int> onStarsSelected;
  final bool isInteractive;
  final String? sentimentLabel;

  const RatingStarsBar({
    super.key,
    required this.selectedStars,
    required this.onStarsSelected,
    this.isInteractive = true,
    this.sentimentLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starNumber = index + 1;
            final isFilled = starNumber <= selectedStars;

            return GestureDetector(
              onTap: isInteractive ? () => onStarsSelected(starNumber) : null,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Icon(
                  isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 42,
                  color: isFilled
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFFCBD5E1),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        if (selectedStars > 0 && sentimentLabel != null)
          _buildSentimentPill(context, sentimentLabel!)
        else if (isInteractive)
          const Text(
            'Tap a star to rate',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
          ),
      ],
    );
  }

  Widget _buildSentimentPill(BuildContext context, String label) {
    final isLow = selectedStars <= 2;
    final isExcellent = selectedStars == 5;

    final bgColor = isExcellent
        ? const Color(0xFFFEE2E2)
        : (isLow ? const Color(0xFFF1F5F9) : const Color(0xFFFEF3C7));

    final textColor = isExcellent
        ? const Color(0xFF991B1B)
        : (isLow ? const Color(0xFF334155) : const Color(0xFF92400E));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
