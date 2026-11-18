import 'package:flutter/material.dart';

class SideMenuGridView extends StatelessWidget {
  final int unreadNotificationsCount;
  final bool isTripActive;
  final ValueChanged<String> onMenuTapped;

  const SideMenuGridView({
    super.key,
    required this.unreadNotificationsCount,
    required this.isTripActive,
    required this.onMenuTapped,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _GridItemData(
        id: 'profile',
        title: 'Profile',
        icon: Icons.person_outline,
      ),
      _GridItemData(
        id: 'trips',
        title: 'Trips',
        icon: Icons.directions_car_outlined,
        badgeText: isTripActive ? 'Active' : null,
        showRedDot: isTripActive,
      ),
      _GridItemData(
        id: 'payments',
        title: 'Payment methods',
        icon: Icons.credit_card_outlined,
      ),
      _GridItemData(
        id: 'notifications',
        title: 'Notifications',
        icon: Icons.notifications_none,
        countBadge: unreadNotificationsCount > 0 ? unreadNotificationsCount : null,
      ),
      _GridItemData(
        id: 'support',
        title: 'Support',
        icon: Icons.headset_mic_outlined,
      ),
      _GridItemData(
        id: 'safety',
        title: 'Safety',
        icon: Icons.shield_outlined,
      ),
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildGridTile(item);
      },
    );
  }

  Widget _buildGridTile(_GridItemData item) {
    return InkWell(
      onTap: () => onMenuTapped(item.id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEE2E2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.icon,
                        color: const Color(0xFF991B1B),
                        size: 20,
                      ),
                    ),
                    if (item.badgeText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.badgeText!,
                          style: const TextStyle(
                            color: Color(0xFFDC2626),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            if (item.showRedDot)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDC2626),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            if (item.countBadge != null)
              Positioned(
                top: -2,
                left: 26,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDC2626),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${item.countBadge}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GridItemData {
  final String id;
  final String title;
  final IconData icon;
  final String? badgeText;
  final int? countBadge;
  final bool showRedDot;

  const _GridItemData({
    required this.id,
    required this.title,
    required this.icon,
    this.badgeText,
    this.countBadge,
    this.showRedDot = false,
  });
}
