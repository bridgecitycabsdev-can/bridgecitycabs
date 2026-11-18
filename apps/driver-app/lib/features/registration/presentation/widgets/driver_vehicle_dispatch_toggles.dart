import 'package:flutter/material.dart';

class DriverVehicleDispatchToggles extends StatelessWidget {
  final bool suitableForVanOnly;
  final bool femaleDriverOnly;
  final ValueChanged<bool> onVanOnlyChanged;
  final ValueChanged<bool> onFemaleDriverChanged;

  const DriverVehicleDispatchToggles({
    super.key,
    required this.suitableForVanOnly,
    required this.femaleDriverOnly,
    required this.onVanOnlyChanged,
    required this.onFemaleDriverChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DISPATCH PREFERENCES',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 12),

        // Toggle 1: Van-only requests
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: suitableForVanOnly
                ? const Color(0xFFFFF5F5)
                : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: suitableForVanOnly
                  ? const Color(0xFFFFCDD2)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: suitableForVanOnly
                      ? const Color(0xFFFFEBEE)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.group_outlined,
                  color: suitableForVanOnly
                      ? const Color(0xFFC62828)
                      : const Color(0xFF6B7280),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Suitable for van-only requests',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Vehicle capacity standard (4 seats)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                key: const ValueKey('driver_van_only_switch'),
                value: suitableForVanOnly,
                activeColor: const Color(0xFFC62828),
                onChanged: onVanOnlyChanged,
              ),
            ],
          ),
        ),

        // Toggle 2: Lady-driver-only requests
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: femaleDriverOnly
                ? const Color(0xFFFFF0F2)
                : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: femaleDriverOnly
                  ? const Color(0xFFFFCDD2)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: femaleDriverOnly
                      ? const Color(0xFFFFCDD2)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: femaleDriverOnly
                      ? const Color(0xFFC62828)
                      : const Color(0xFF6B7280),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lady-driver-only requests',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      femaleDriverOnly
                          ? 'Opt-in active for Lethbridge safety network'
                          : 'Opt-in for Lethbridge safety network',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: femaleDriverOnly
                            ? FontWeight.w500
                            : FontWeight.w400,
                        color: femaleDriverOnly
                            ? const Color(0xFFC62828)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                key: const ValueKey('driver_female_driver_switch'),
                value: femaleDriverOnly,
                activeColor: const Color(0xFFC62828),
                onChanged: onFemaleDriverChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
