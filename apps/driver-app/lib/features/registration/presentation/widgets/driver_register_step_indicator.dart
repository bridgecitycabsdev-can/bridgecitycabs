import 'package:flutter/material.dart';
import '../../data/models/driver_register_config.dart';
import '../../data/models/driver_register_step1_status.dart';

class DriverRegisterStepIndicator extends StatelessWidget {
  final DriverRegisterStep1Status status;

  const DriverRegisterStepIndicator({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isValid = status == DriverRegisterStep1Status.valid;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top 4-Segment Progress Bar
        Row(
          children: List.generate(4, (index) {
            final isCurrent = index == 0;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(
                  right: index < 3 ? 6.0 : 0.0,
                ),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? const Color(0xFFC91A25) // Active red
                      : const Color(0xFFE5E7EB), // Inactive grey
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),

        // Label and Badge Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              status == DriverRegisterStep1Status.invalid
                  ? 'STEP 1 OF 4'
                  : DriverRegisterConfig.stepInfo,
              style: TextStyle(
                fontSize: 12,
                fontWeight: status == DriverRegisterStep1Status.invalid
                    ? FontWeight.w900
                    : FontWeight.w600,
                color: status == DriverRegisterStep1Status.invalid
                    ? const Color(0xFF991B1B)
                    : const Color(0xFF4B5563),
                letterSpacing: status == DriverRegisterStep1Status.invalid ? 0.8 : 0,
              ),
            ),
            if (isValid)
              const Text(
                DriverRegisterConfig.percentageBadge,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFC91A25),
                ),
              )
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  DriverRegisterConfig.requiredBadge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF991B1B),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
