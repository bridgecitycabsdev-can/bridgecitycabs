import 'package:flutter/material.dart';
import '../../data/models/rate_driver_models.dart';

class RatingTagChipsSelector extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<RatingTag> availableTags;
  final List<RatingTag> selectedTags;
  final ValueChanged<RatingTag> onTagToggled;
  final bool isInteractive;

  const RatingTagChipsSelector({
    super.key,
    required this.title,
    this.subtitle,
    required this.availableTags,
    required this.selectedTags,
    required this.onTagToggled,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    if (availableTags.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
                letterSpacing: 0.2,
              ),
            ),
            if (subtitle != null && subtitle!.isNotEmpty)
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: availableTags.map((tag) {
            final isSelected = selectedTags.contains(tag);

            final bgColor = isSelected
                ? const Color(0xFFFEE2E2)
                : const Color(0xFFF1F5F9);
            final borderColor = isSelected
                ? const Color(0xFFFECACA)
                : const Color(0xFFE2E8F0);
            final textColor = isSelected
                ? const Color(0xFF991B1B)
                : const Color(0xFF334155);

            return InkWell(
              onTap: isInteractive ? () => onTagToggled(tag) : null,
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(Icons.check, size: 14, color: Color(0xFF991B1B)),
                      const SizedBox(width: 4),
                    ] else ...[
                      const Icon(Icons.add, size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      tag.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
