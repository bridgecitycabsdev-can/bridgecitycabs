import 'package:flutter/material.dart';
import '../../data/models/driver_trip_history_status.dart';

class DriverHistoryQABar extends StatelessWidget {
  final DriverTripHistoryStatus currentStatus;
  final ValueChanged<DriverTripHistoryStatus> onStatusSelected;

  const DriverHistoryQABar({
    super.key,
    required this.currentStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: DriverTripHistoryStatus.values.map((status) {
            final isSelected = currentStatus == status;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(
                  status.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFFB0BEC5),
                  ),
                ),
                selected: isSelected,
                selectedColor: const Color(0xFFD32F2F),
                backgroundColor: const Color(0xFF2E2E2E),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onSelected: (_) => onStatusSelected(status),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
