import 'package:flutter/material.dart';
import '../../data/models/home_config.dart';
import '../../data/models/ride_category.dart';
import '../../data/models/ride_tier_estimate.dart';
import '../../data/models/waypoint.dart';
import 'ride_category_chips.dart';
import 'vehicle_estimate_card.dart';

class PlanRidePanel extends StatelessWidget {
  final List<Waypoint> waypoints;
  final VoidCallback onAddAnotherStop;
  final ValueChanged<String> onRemoveStop;
  final VoidCallback onReorderStops;
  final String? selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final RideTierEstimate estimate;
  final String paymentMethod;
  final VoidCallback onChangePayment;
  final VoidCallback onContinueToOptions;

  const PlanRidePanel({
    super.key,
    required this.waypoints,
    required this.onAddAnotherStop,
    required this.onRemoveStop,
    required this.onReorderStops,
    this.selectedCategory,
    required this.onCategorySelected,
    required this.estimate,
    required this.paymentMethod,
    required this.onChangePayment,
    required this.onContinueToOptions,
  });

  @override
  Widget build(BuildContext context) {
    final pickup = waypoints.firstWhere((w) => w.isPickup, orElse: () => waypoints.first);
    final stops = waypoints.where((w) => w.isStop).toList();
    final dropoff = waypoints.firstWhere((w) => w.isDropoff, orElse: () => waypoints.last);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hub Shortcut Chips: Campus Express, Park Place Mall, Regional...
          RideCategoryChips(
            categories: RideCategory.hubShortcuts,
            selectedId: selectedCategory,
            onSelected: onCategorySelected,
          ),
          const SizedBox(height: 14),

          // Trip Itinerary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7F7),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFFFCDD2), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header: TRIP ITINERARY + 3 Waypoints badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.alt_route_rounded, color: Color(0xFF880E14), size: 18),
                        SizedBox(width: 8),
                        Text(
                          HomeConfig.tripItinerary,
                          style: TextStyle(
                            color: Color(0xFF880E14),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFCDD2)),
                      ),
                      child: Text(
                        '${waypoints.length} Waypoints',
                        style: const TextStyle(
                          color: Color(0xFF880E14),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Pickup Row
                _WaypointRow(
                  iconWidget: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFB71C1C), width: 2),
                    ),
                    child: Center(
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFB71C1C),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  label: 'PICKUP',
                  tag: pickup.tag ?? 'Now',
                  title: pickup.title,
                  subtitle: pickup.subtitle,
                  trailingIcon: Icons.swap_vert_rounded,
                  onTrailingTap: onReorderStops,
                ),

                // Stops
                for (int i = 0; i < stops.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 4, bottom: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(width: 2, height: 14, color: const Color(0xFFFFCDD2)),
                    ),
                  ),
                  _WaypointRow(
                    iconWidget: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: Color(0xFFB71C1C),
                        size: 14,
                      ),
                    ),
                    label: 'STOP ${i + 1}',
                    tag: stops[i].tag ?? '+5 min wait',
                    title: stops[i].title,
                    subtitle: stops[i].subtitle,
                    trailingIcon: Icons.close_rounded,
                    onTrailingTap: () => onRemoveStop(stops[i].id),
                  ),
                ],

                // Dropoff Row
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 4, bottom: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(width: 2, height: 14, color: const Color(0xFFFFCDD2)),
                  ),
                ),
                _WaypointRow(
                  iconWidget: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  label: 'DROPOFF',
                  tag: dropoff.tag ?? 'Est. 16m',
                  title: dropoff.title,
                  subtitle: dropoff.subtitle,
                  trailingIcon: Icons.edit_outlined,
                  onTrailingTap: () {},
                ),
                const SizedBox(height: 14),

                // Add another stop button
                OutlinedButton.icon(
                  onPressed: onAddAnotherStop,
                  icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF880E14), size: 17),
                  label: const Text(
                    HomeConfig.addAnotherStop,
                    style: TextStyle(
                      color: Color(0xFF880E14),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFFFCDD2)),
                    minimumSize: const Size(double.infinity, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Vehicle Tier Card: Crimson Standard
          VehicleEstimateCard(estimate: estimate),
          const SizedBox(height: 12),

          // Payment Selector Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.credit_card_outlined, color: Color(0xFF1E1E1E), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    paymentMethod,
                    style: const TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onChangePayment,
                child: const Text(
                  'Change option',
                  style: TextStyle(
                    color: Color(0xFFB71C1C),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Continue to Ride Options Primary Button
          ElevatedButton(
            onPressed: onContinueToOptions,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF880E14),
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  HomeConfig.continueToRideOptions,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WaypointRow extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final String tag;
  final String title;
  final String subtitle;
  final IconData trailingIcon;
  final VoidCallback onTrailingTap;

  const _WaypointRow({
    required this.iconWidget,
    required this.label,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.trailingIcon,
    required this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        iconWidget,
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF880E14),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: Color(0xFF880E14),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(trailingIcon, color: const Color(0xFF6B7280), size: 18),
          onPressed: onTrailingTap,
        ),
      ],
    );
  }
}
