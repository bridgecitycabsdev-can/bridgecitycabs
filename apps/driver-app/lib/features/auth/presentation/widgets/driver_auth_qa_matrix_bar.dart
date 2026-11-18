import 'package:flutter/material.dart';
import '../../data/models/driver_auth_status.dart';

class DriverAuthQaMatrixBar extends StatelessWidget {
  final DriverAuthStatus currentStatus;
  final ValueChanged<DriverAuthStatus> onSelectStatus;

  const DriverAuthQaMatrixBar({
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
            _buildChip('1. Empty', DriverAuthStatus.initial),
            const SizedBox(width: 6),
            _buildChip('2. Valid (Surge)', DriverAuthStatus.valid),
            const SizedBox(width: 6),
            _buildChip('3. Incomplete', DriverAuthStatus.invalid),
            const SizedBox(width: 6),
            _buildChip('4. Unregistered', DriverAuthStatus.unregistered),
            const SizedBox(width: 6),
            _buildChip('5. Locked (15m)', DriverAuthStatus.locked),
            const SizedBox(width: 6),
            _buildChip('6. Sending Code', DriverAuthStatus.submitting),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, DriverAuthStatus status) {
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
