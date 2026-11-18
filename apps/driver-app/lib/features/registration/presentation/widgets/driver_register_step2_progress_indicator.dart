import 'package:flutter/material.dart';
import '../../data/models/driver_register_step2_status.dart';

class DriverRegisterStep2ProgressIndicator extends StatelessWidget {
  final DriverRegisterStep2Status status;

  const DriverRegisterStep2ProgressIndicator({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isInvalid = status == DriverRegisterStep2Status.invalid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 4 Segment Progress Bar
        Row(
          children: List.generate(4, (index) {
            final isCompletedOrCurrent = index < 2;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < 3 ? 6.0 : 0.0),
                decoration: BoxDecoration(
                  color: isCompletedOrCurrent
                      ? const Color(0xFFC62828)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),

        // Progress Text & Percentage
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isInvalid
                  ? 'STEP 2 OF 4 · VEHICLE'
                  : 'Step 2 of 4 · Vehicle',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isInvalid ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: isInvalid ? 0.6 : 0.0,
                color: const Color(0xFF4B5563),
              ),
            ),
            Text(
              isInvalid ? '50% Completed' : '50%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFFC62828),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
