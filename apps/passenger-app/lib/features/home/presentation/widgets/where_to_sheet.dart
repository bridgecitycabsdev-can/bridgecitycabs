import 'package:flutter/material.dart';
import '../../data/models/home_config.dart';
import '../../data/models/ride_category.dart';
import 'ride_category_chips.dart';

class WhereToSheet extends StatelessWidget {
  final VoidCallback onPickupTapped;
  final VoidCallback onWhereToTapped;
  final VoidCallback onAddStopTapped;
  final String? selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback? onContinueTapped;

  const WhereToSheet({
    super.key,
    required this.onPickupTapped,
    required this.onWhereToTapped,
    required this.onAddStopTapped,
    this.selectedCategory,
    required this.onCategorySelected,
    this.onContinueTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            children: [
              const Text(
                HomeConfig.whereToTitle,
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFB71C1C),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            HomeConfig.whereToSubtitle,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),

          // Pickup and Dropoff Input Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7F7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFCDD2), width: 1.2),
            ),
            child: Column(
              children: [
                // Pickup row
                InkWell(
                  onTap: onPickupTapped,
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'PICKUP',
                              style: TextStyle(
                                color: Color(0xFF880E14),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              HomeConfig.currentLocation,
                              style: TextStyle(
                                color: Color(0xFF1F2937),
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.near_me_rounded,
                        color: Color(0xFF880E14),
                        size: 20,
                      ),
                    ],
                  ),
                ),

                // Dotted connector line
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 2,
                      height: 16,
                      color: const Color(0xFFD1D5DB),
                    ),
                  ),
                ),

                // Where to row
                InkWell(
                  onTap: onWhereToTapped,
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB71C1C),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          HomeConfig.whereToPlaceholder,
                          style: TextStyle(
                            color: Color(0xFF4B5563),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF880E14),
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Add stop action link
          InkWell(
            onTap: onAddStopTapped,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.add_circle_outline_rounded, size: 16, color: Color(0xFF880E14)),
                SizedBox(width: 6),
                Text(
                  HomeConfig.addStop,
                  style: TextStyle(
                    color: Color(0xFF880E14),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Quick Category Chips
          RideCategoryChips(
            categories: RideCategory.homeCategories,
            selectedId: selectedCategory,
            onSelected: onCategorySelected,
          ),
          const SizedBox(height: 18),

          // Disabled Continue Button (since destination is not yet chosen)
          ElevatedButton(
            onPressed: onContinueTapped,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE5E7EB),
              foregroundColor: const Color(0xFF9CA3AF),
              elevation: 0,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
