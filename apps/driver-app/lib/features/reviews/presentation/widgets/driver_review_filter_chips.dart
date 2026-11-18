import 'package:flutter/material.dart';
import '../../data/models/driver_rating_distribution.dart';
import '../../data/models/driver_review_filter_star.dart';

class DriverReviewFilterChips extends StatelessWidget {
  final DriverReviewFilterStar selectedFilter;
  final DriverRatingDistribution distribution;
  final ValueChanged<DriverReviewFilterStar> onFilterSelected;

  const DriverReviewFilterChips({
    super.key,
    required this.selectedFilter,
    required this.distribution,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: DriverReviewFilterStar.values.map((filter) {
          final isSelected = selectedFilter == filter;
          final count = distribution.getCountForFilter(filter);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filter.label(count),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF424242),
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFFC62828),
              backgroundColor: const Color(0xFFF5F5F5),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (_) => onFilterSelected(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}
