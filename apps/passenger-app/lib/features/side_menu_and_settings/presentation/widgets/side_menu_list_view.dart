import 'package:flutter/material.dart';
import '../../data/models/side_menu_model.dart';

class SideMenuListView extends StatelessWidget {
  final ActiveTripBannerData? activeTrip;
  final int unreadNotificationsCount;
  final ValueChanged<String> onMenuTapped;
  final VoidCallback? onLiveTripTapped;

  const SideMenuListView({
    super.key,
    this.activeTrip,
    required this.unreadNotificationsCount,
    required this.onMenuTapped,
    this.onLiveTripTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activeTrip != null) ...[
          _buildLiveTripTile(),
          const SizedBox(height: 12),
        ],
        _buildListTile(
          id: 'trips',
          title: 'Your Trips',
          icon: Icons.directions_car_outlined,
        ),
        const SizedBox(height: 8),
        _buildListTile(
          id: 'saved_locations',
          title: 'Saved Locations',
          icon: Icons.bookmark_border_outlined,
        ),
        const SizedBox(height: 8),
        _buildListTile(
          id: 'notifications',
          title: 'Notifications',
          icon: Icons.notifications_none,
          badgeCount: unreadNotificationsCount > 0 ? unreadNotificationsCount : null,
        ),
        const SizedBox(height: 8),
        _buildListTile(
          id: 'safety',
          title: 'Safety & Dispatch',
          icon: Icons.shield_outlined,
        ),
        const SizedBox(height: 8),
        _buildListTile(
          id: 'support',
          title: 'Help & Lost Property',
          icon: Icons.help_outline,
        ),
        const SizedBox(height: 8),
        _buildListTile(
          id: 'settings',
          title: 'Settings',
          icon: Icons.settings_outlined,
        ),
      ],
    );
  }

  Widget _buildLiveTripTile() {
    return InkWell(
      onTap: onLiveTripTapped,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFDC2626),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_car,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Live Trip Tracking',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Arriving in ${activeTrip?.etaMinutes ?? 4} mins',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFDC2626),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String id,
    required String title,
    required IconData icon,
    int? badgeCount,
  }) {
    return InkWell(
      onTap: () => onMenuTapped(id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFB),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF4B5563),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            if (badgeCount != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: const BoxDecoration(
                  color: Color(0xFFDC2626),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
