import 'package:flutter/material.dart';
import '../../data/models/driver_otp_status.dart';

class DriverOtpQaMatrixBar extends StatelessWidget {
  final DriverOtpStatus currentStatus;
  final ValueChanged<DriverOtpStatus> onSelectStatus;

  const DriverOtpQaMatrixBar({
    super.key,
    required this.currentStatus,
    required this.onSelectStatus,
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
            _buildChip('1. Fresh Entry', DriverOtpStatus.initial),
            const SizedBox(width: 6),
            _buildChip('2. Ready (842917)', DriverOtpStatus.ready),
            const SizedBox(width: 6),
            _buildChip('3. Incorrect Code', DriverOtpStatus.incorrect),
            const SizedBox(width: 6),
            _buildChip('4. Expired Code', DriverOtpStatus.expired),
            const SizedBox(width: 6),
            _buildChip('5. Verifying...', DriverOtpStatus.submitting),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, DriverOtpStatus status) {
    final isSelected = currentStatus == status;
    return GestureDetector(
      onTap: () => onSelectStatus(status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFC91A25)
              : Colors.white.withOpacity(0.18),
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
