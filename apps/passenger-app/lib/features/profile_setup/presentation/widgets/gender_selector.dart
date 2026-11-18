import 'package:flutter/material.dart';
import '../../data/models/profile_setup_config.dart';

/// Gender selection pills matching the design (`Male`, `✓ Female`, `Other`).
class GenderSelector extends StatelessWidget {
  final String selectedGender;
  final ValueChanged<String> onGenderSelected;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onGenderSelected,
  });

  static const List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header Row: Label & Safety Tag
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ProfileSetupConfig.genderLabel,
                style: TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                ProfileSetupConfig.genderSafetyHint,
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // 3 Segmented Option Pills
        Row(
          children: _genders.map((gender) {
            final isSelected = gender.toLowerCase() == selectedGender.toLowerCase();

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => onGenderSelected(gender),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFF1F2) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFB71C1C)
                            : Colors.transparent,
                        width: isSelected ? 1.4 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSelected) ...[
                          const Icon(
                            Icons.check_rounded,
                            color: Color(0xFFB71C1C),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          gender,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF980F1B)
                                : const Color(0xFF1E1E1E),
                            fontSize: 13.5,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
