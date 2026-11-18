import 'package:flutter/material.dart';
import '../../data/models/notification_item_model.dart';

class NotificationFilterChips extends StatelessWidget {
  final NotificationCategory selectedCategory;
  final int totalCount;
  final ValueChanged<NotificationCategory> onCategoryChanged;

  const NotificationFilterChips({
    super.key,
    required this.selectedCategory,
    required this.totalCount,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: NotificationCategory.values.map((category) {
          final isSelected = category == selectedCategory;
          final label = category == NotificationCategory.all
              ? 'All ($totalCount)'
              : category.displayName;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onCategoryChanged(category),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF475569),
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
