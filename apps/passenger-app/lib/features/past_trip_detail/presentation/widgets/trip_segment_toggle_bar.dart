import 'package:flutter/material.dart';
import '../../data/models/past_trip_detail_model.dart';

class TripSegmentToggleBar extends StatelessWidget {
  final TripDetailSegment selectedSegment;
  final ValueChanged<TripDetailSegment> onSegmentChanged;

  const TripSegmentToggleBar({
    super.key,
    required this.selectedSegment,
    required this.onSegmentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _buildSegmentItem(TripDetailSegment.completedCard),
          _buildSegmentItem(TripDetailSegment.completedCash),
          _buildSegmentItem(TripDetailSegment.inProgress),
        ],
      ),
    );
  }

  Widget _buildSegmentItem(TripDetailSegment segment) {
    final bool isSelected = segment == selectedSegment;

    return Expanded(
      child: GestureDetector(
        onTap: () => onSegmentChanged(segment),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              segment.label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF111827)
                    : const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
