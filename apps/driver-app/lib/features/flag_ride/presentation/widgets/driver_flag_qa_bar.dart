import 'package:flutter/material.dart';
import '../../data/models/driver_flag_ride_status.dart';

class DriverFlagQaBar extends StatelessWidget {
  final DriverFlagRideStatus currentStatus;
  final ValueChanged<DriverFlagRideStatus> onStatusSelected;

  const DriverFlagQaBar({
    super.key,
    required this.currentStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    const states = [
      (DriverFlagRideStatus.startFlagRide, '1. Start Flag Ride'),
      (DriverFlagRideStatus.flagInProgress, '2. In Progress'),
      (DriverFlagRideStatus.flagComplete, '3. Flag Complete'),
      (DriverFlagRideStatus.edgeStates, '4. 7 Edge States'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: states.map((item) {
            final isSelected = currentStatus == item.$1;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: InkWell(
                onTap: () => onStatusSelected(item.$1),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFBA0C2F)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    item.$2,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF374151),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
