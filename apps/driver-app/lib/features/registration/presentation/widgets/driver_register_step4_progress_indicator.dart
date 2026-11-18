import 'package:flutter/material.dart';
import '../../data/models/driver_register_step4_status.dart';

class DriverRegisterStep4ProgressIndicator extends StatelessWidget {
  final DriverRegisterStep4Status status;

  const DriverRegisterStep4ProgressIndicator({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 4 Segment Progress Bar
        Row(
          children: List.generate(4, (index) {
            final color = _getSegmentColor(index);
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < 3 ? 6.0 : 0.0),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),

        // Text & Status Tag
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (status == DriverRegisterStep4Status.actionRequired) ...[
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFC62828),
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
                Text(
                  _getHeaderTitle(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: _getHeaderColor(),
                  ),
                ),
              ],
            ),
            _buildTrailingBadge(),
          ],
        ),
      ],
    );
  }

  Color _getSegmentColor(int index) {
    switch (status) {
      case DriverRegisterStep4Status.approved:
        return const Color(0xFF2E7D32); // All green

      case DriverRegisterStep4Status.actionRequired:
      case DriverRegisterStep4Status.rejected:
        return index < 3
            ? const Color(0xFF2E7D32) // First 3 green
            : const Color(0xFFC62828); // 4th red

      case DriverRegisterStep4Status.reviewing:
      case DriverRegisterStep4Status.offline:
      default:
        return index < 3
            ? const Color(0xFFC62828)
            : (status == DriverRegisterStep4Status.offline
                ? const Color(0xFFC62828)
                : const Color(0xFFE5E7EB));
    }
  }

  String _getHeaderTitle() {
    switch (status) {
      case DriverRegisterStep4Status.approved:
        return 'STEP 4 OF 4 · APPROVED';
      case DriverRegisterStep4Status.actionRequired:
        return 'STEP 4 OF 4 · ACTION REQUIRED';
      case DriverRegisterStep4Status.rejected:
        return 'STEP 4 OF 4 · APPLICATION STATUS';
      case DriverRegisterStep4Status.reviewing:
      case DriverRegisterStep4Status.offline:
      default:
        return 'STEP 4 OF 4 · REVIEW';
    }
  }

  Color _getHeaderColor() {
    switch (status) {
      case DriverRegisterStep4Status.approved:
        return const Color(0xFF1B5E20);
      case DriverRegisterStep4Status.actionRequired:
      case DriverRegisterStep4Status.rejected:
        return const Color(0xFFB71C1C);
      default:
        return const Color(0xFF881337);
    }
  }

  Widget _buildTrailingBadge() {
    switch (status) {
      case DriverRegisterStep4Status.approved:
        return Row(
          children: const [
            Icon(Icons.check_circle_outline,
                size: 14, color: Color(0xFF2E7D32)),
            SizedBox(width: 4),
            Text(
              'Complete',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        );

      case DriverRegisterStep4Status.actionRequired:
        return const Text(
          '90% Completed',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4B5563),
          ),
        );

      case DriverRegisterStep4Status.rejected:
        return Row(
          children: const [
            Icon(Icons.cancel_outlined, size: 14, color: Color(0xFFC62828)),
            SizedBox(width: 4),
            Text(
              'Action Needed',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFC62828),
              ),
            ),
          ],
        );

      case DriverRegisterStep4Status.reviewing:
      case DriverRegisterStep4Status.offline:
      default:
        return Row(
          children: const [
            Icon(Icons.check_circle_outline,
                size: 13, color: Color(0xFF2E7D32)),
            SizedBox(width: 4),
            Text(
              'Final Verification',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B5563),
              ),
            ),
          ],
        );
    }
  }
}
