import 'package:flutter/material.dart';
import '../../data/models/driver_register_config.dart';
import '../../data/models/driver_register_step1_data.dart';
import '../../data/models/driver_register_step1_status.dart';

class DriverRegisterGenderSelector extends StatelessWidget {
  final DriverGender selectedGender;
  final DriverRegisterStep1Status status;
  final ValueChanged<DriverGender> onSelectGender;

  const DriverRegisterGenderSelector({
    super.key,
    required this.selectedGender,
    required this.status,
    required this.onSelectGender,
  });

  @override
  Widget build(BuildContext context) {
    String label;
    String? optionalTag;

    if (status == DriverRegisterStep1Status.valid) {
      label = DriverRegisterConfig.genderIdentificationLabel;
      optionalTag = null;
    } else if (status == DriverRegisterStep1Status.invalid) {
      label = DriverRegisterConfig.genderOfficialIdLabel;
      optionalTag = null;
    } else {
      label = DriverRegisterConfig.genderLabel;
      optionalTag = DriverRegisterConfig.genderOptionalTag;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            if (optionalTag != null)
              Text(
                optionalTag,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // 3 Gender Chips
        Row(
          children: [
            _buildGenderChip(DriverGender.male),
            const SizedBox(width: 8),
            _buildGenderChip(DriverGender.female),
            const SizedBox(width: 8),
            _buildGenderChip(DriverGender.other),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderChip(DriverGender gender) {
    final isSelected = selectedGender == gender;

    return Expanded(
      child: GestureDetector(
        onTap: () => onSelectGender(gender),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFEE2E2)
                : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFCA5A5)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected) ...[
                const Icon(
                  Icons.check,
                  size: 15,
                  color: Color(0xFF991B1B),
                ),
                const SizedBox(width: 5),
              ],
              Text(
                gender.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFF991B1B)
                      : const Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
