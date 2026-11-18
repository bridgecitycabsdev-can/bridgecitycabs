import 'package:flutter/material.dart';
import '../../data/models/trip_history_model.dart';

class TripsDateFilterChips extends StatelessWidget {
  final TripHistoryFilter selectedFilter;
  final ValueChanged<TripHistoryFilter> onFilterSelected;

  const TripsDateFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      TripHistoryFilter.today,
      TripHistoryFilter.yesterday,
      TripHistoryFilter.thisWeek,
      TripHistoryFilter.thisMonth,
      if (selectedFilter == TripHistoryFilter.custom) TripHistoryFilter.custom,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onFilterSelected(filter),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFDC2626) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  filter.displayName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF374151),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
