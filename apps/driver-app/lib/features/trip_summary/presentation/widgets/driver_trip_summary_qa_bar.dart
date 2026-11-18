import 'package:flutter/material.dart';
import '../../data/models/driver_trip_summary_status.dart';

class DriverTripSummaryQaBar extends StatelessWidget {
  final DriverTripSummaryStatus currentStatus;
  final ValueChanged<DriverTripSummaryStatus> onStatusSelected;

  const DriverTripSummaryQaBar({
    super.key,
    required this.currentStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    const states = [
      (DriverTripSummaryStatus.cardSettled, '1. Card Summary'),
      (DriverTripSummaryStatus.cashDue, '2. Cash Payment Due'),
      (DriverTripSummaryStatus.ratePassenger, '3. Rate Passenger'),
      (DriverTripSummaryStatus.edgeStatesGallery, '4. 6 Edge States'),
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
