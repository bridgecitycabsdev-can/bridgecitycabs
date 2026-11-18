import 'package:flutter/material.dart';
import '../../data/models/home_config.dart';
import '../../data/models/ride_tier_estimate.dart';
import 'vehicle_estimate_card.dart';

class BookRidePanel extends StatelessWidget {
  final String pickupText;
  final String dropoffText;
  final bool isLocationOff;
  final VoidCallback onEnableLocation;
  final RideTierEstimate estimate;
  final VoidCallback onContinueTapped;

  const BookRidePanel({
    super.key,
    required this.pickupText,
    required this.dropoffText,
    required this.isLocationOff,
    required this.onEnableLocation,
    required this.estimate,
    required this.onContinueTapped,
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
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Route Input Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7F7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFCDD2), width: 1.2),
            ),
            child: Column(
              children: [
                // Pickup input row
                Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFB71C1C), width: 2),
                      ),
                      child: Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFB71C1C),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        pickupText,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.near_me_rounded,
                      color: Color(0xFF880E14),
                      size: 20,
                    ),
                  ],
                ),

                // Connector line
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 2,
                      height: 14,
                      color: const Color(0xFFD1D5DB),
                    ),
                  ),
                ),

                // Dropoff input row
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFFB71C1C),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        dropoffText,
                        style: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF6B7280),
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Location Disabled Warning Banner
          if (isLocationOff) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFCDD2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4E6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.location_off_rounded,
                      color: Color(0xFFB71C1C),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          HomeConfig.locationOffTitle,
                          style: TextStyle(
                            color: Color(0xFF880E14),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          HomeConfig.locationOffDesc,
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  TextButton(
                    onPressed: onEnableLocation,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFFFCDD2)),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          HomeConfig.enable,
                          style: TextStyle(
                            color: Color(0xFF880E14),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF880E14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Filter row (Now ∨, Standard Ride ∨, Saved Places)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _PreferenceChip(label: 'Now', icon: Icons.access_time_rounded, hasDropdown: true),
                const SizedBox(width: 8),
                _PreferenceChip(label: 'Standard Ride', icon: Icons.directions_car_rounded, hasDropdown: true),
                const SizedBox(width: 8),
                _PreferenceChip(label: 'Saved Places', icon: Icons.bookmark_border_rounded, hasDropdown: false),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // City Red Cruiser Estimate Card
          VehicleEstimateCard(estimate: estimate),
          const SizedBox(height: 16),

          // Continue Button
          ElevatedButton(
            onPressed: onContinueTapped,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD1D5DB),
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
                  'Continue',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18, color: Color(0xFF374151)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Lethbridge Transit Verified notice
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.shield_outlined, size: 14, color: Color(0xFFB71C1C)),
              SizedBox(width: 6),
              Text(
                HomeConfig.secureBookingNotice,
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreferenceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool hasDropdown;

  const _PreferenceChip({
    required this.label,
    required this.icon,
    required this.hasDropdown,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFB71C1C)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (hasDropdown) ...[
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF6B7280)),
          ],
        ],
      ),
    );
  }
}
