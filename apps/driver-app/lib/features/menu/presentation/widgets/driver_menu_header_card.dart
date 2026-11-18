import 'package:flutter/material.dart';
import '../../data/models/driver_menu_profile.dart';
import '../../data/models/driver_menu_status.dart';

class DriverMenuHeaderCard extends StatelessWidget {
  final DriverMenuProfile profile;
  final DriverMenuStatus status;
  final VoidCallback? onClose;
  final VoidCallback? onProfileTap;

  const DriverMenuHeaderCard({
    super.key,
    required this.profile,
    required this.status,
    this.onClose,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOffline = status == DriverMenuStatus.offline;
    final isActiveTrip = status == DriverMenuStatus.activeTrip;
    final isUnderReview = status == DriverMenuStatus.underReview;

    Color badgeColor;
    Color badgeBg;
    String badgeText;

    if (isOffline) {
      badgeColor = Colors.black54;
      badgeBg = const Color(0xFFEEEEEE);
      badgeText = 'Offline';
    } else if (isActiveTrip) {
      badgeColor = const Color(0xFF1B5E20);
      badgeBg = const Color(0xFFE8F5E9);
      badgeText = 'ACTIVE TRIP';
    } else if (isUnderReview) {
      badgeColor = const Color(0xFFE65100);
      badgeBg = const Color(0xFFFFF3E0);
      badgeText = 'PENDING REVIEW';
    } else {
      badgeColor = const Color(0xFF2E7D32);
      badgeBg = const Color(0xFFE8F5E9);
      badgeText = 'ONLINE';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Driver Avatar
          GestureDetector(
            onTap: onProfileTap,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActiveTrip
                          ? const Color(0xFF2E7D32)
                          : isUnderReview
                              ? const Color(0xFFFFA000)
                              : Colors.white,
                      width: 2.5,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFFE0E0E0),
                    child: Text(
                      profile.name.isNotEmpty ? profile.name[0] : 'D',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                // Status indicator badge on avatar
                if (isUnderReview)
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFA000),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.access_time, size: 12, color: Colors.white),
                  )
                else
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isOffline
                          ? Colors.grey
                          : const Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Name, Rating & Status Pill
          Expanded(
            child: GestureDetector(
              onTap: onProfileTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 13, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text(
                        '${profile.rating.toStringAsFixed(1)} • ${profile.totalRides} rides',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isUnderReview) ...[
                          Icon(Icons.circle, size: 6, color: badgeColor),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: badgeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action: Chevron or Close Button
          if (isOffline && onClose != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black54),
              onPressed: onClose,
            )
          else
            const Icon(Icons.chevron_right, color: Colors.black45),
        ],
      ),
    );
  }
}
