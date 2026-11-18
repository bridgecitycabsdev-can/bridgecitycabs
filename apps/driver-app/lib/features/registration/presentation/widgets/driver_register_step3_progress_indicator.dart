import 'package:flutter/material.dart';
import '../../data/models/driver_register_step3_status.dart';

class DriverRegisterStep3ProgressIndicator extends StatelessWidget {
  final DriverRegisterStep3Status status;

  const DriverRegisterStep3ProgressIndicator({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 4-segment progress bar (3 segments filled with red)
        Row(
          children: List.generate(4, (index) {
            final isCompleted = index < 3;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < 3 ? 6.0 : 0.0),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFFC62828)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),

        // Text & Status Tag Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Step 3 of 4 · Documents',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B5563),
              ),
            ),
            _buildTrailingTag(),
          ],
        ),
      ],
    );
  }

  Widget _buildTrailingTag() {
    switch (status) {
      case DriverRegisterStep3Status.ready:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFC8E6C9)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check_circle, size: 12, color: Color(0xFF2E7D32)),
              SizedBox(width: 4),
              Text(
                'All Required Docs Attached',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
        );

      case DriverRegisterStep3Status.actionRequired:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFCDD2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.error_outline, size: 12, color: Color(0xFFC62828)),
              SizedBox(width: 4),
              Text(
                '1 ACTION REQUIRED',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFC62828),
                ),
              ),
            ],
          ),
        );

      case DriverRegisterStep3Status.submitting:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFC62828),
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              'Transmitting to Fleet...',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFC62828),
              ),
            ),
          ],
        );

      default:
        return const Text(
          '75% Completed',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFFC62828),
          ),
        );
    }
  }
}
