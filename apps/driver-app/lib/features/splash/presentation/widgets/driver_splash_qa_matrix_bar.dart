import 'package:flutter/material.dart';
import '../../data/models/driver_splash_model.dart';

/// Interactive toolbar allowing QA / Devs to switch between all 4 driver splash states.
class DriverSplashQaMatrixBar extends StatelessWidget {
  final DriverSplashStatus currentStatus;
  final ValueChanged<DriverSplashStatus> onSelectStatus;

  const DriverSplashQaMatrixBar({
    super.key,
    required this.currentStatus,
    required this.onSelectStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildChip(
              label: '1. Loading',
              status: DriverSplashStatus.initial,
            ),
            const SizedBox(width: 6),
            _buildChip(
              label: '2. Retrying Hub',
              status: DriverSplashStatus.connecting,
            ),
            const SizedBox(width: 6),
            _buildChip(
              label: '3. Offline Modal',
              status: DriverSplashStatus.connectionError,
            ),
            const SizedBox(width: 6),
            _buildChip(
              label: '4. Update Modal',
              status: DriverSplashStatus.updateRequired,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required DriverSplashStatus status,
  }) {
    final isSelected = currentStatus == status;
    return GestureDetector(
      onTap: () => onSelectStatus(status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? const Color(0xFFC91A25) : Colors.white,
          ),
        ),
      ),
    );
  }
}
