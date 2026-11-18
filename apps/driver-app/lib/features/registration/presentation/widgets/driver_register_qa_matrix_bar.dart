import 'package:flutter/material.dart';
import '../../data/models/driver_register_step1_status.dart';

class DriverRegisterQaMatrixBar extends StatelessWidget {
  final DriverRegisterStep1Status currentStatus;
  final ValueChanged<DriverRegisterStep1Status> onSelectStatus;

  const DriverRegisterQaMatrixBar({
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
            _buildChip('1. Initial (Empty)', DriverRegisterStep1Status.initial),
            const SizedBox(width: 6),
            _buildChip('2. Valid (25%)', DriverRegisterStep1Status.valid),
            const SizedBox(width: 6),
            _buildChip('3. Validation Errors', DriverRegisterStep1Status.invalid),
            const SizedBox(width: 6),
            _buildChip('4. Photo Modal', DriverRegisterStep1Status.photoModal),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, DriverRegisterStep1Status status) {
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
