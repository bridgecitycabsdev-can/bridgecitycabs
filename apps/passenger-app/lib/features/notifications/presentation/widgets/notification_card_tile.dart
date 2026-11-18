import 'package:flutter/material.dart';
import '../../data/models/notification_item_model.dart';

class NotificationCardTile extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const NotificationCardTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !item.isRead;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFFFEF2F2) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(item.iconType, isUnread),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isUnread ? FontWeight.w800 : FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.timestamp,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF475569),
                      height: 1.35,
                    ),
                  ),
                  if (item.metaText != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.metaText!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (isUnread) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: Color(0xFFB91C1C),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(NotificationIconType iconType, bool isUnread) {
    IconData icon;
    Color iconColor = isUnread ? const Color(0xFF991B1B) : const Color(0xFF64748B);
    Color bgColor = isUnread ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9);

    switch (iconType) {
      case NotificationIconType.car:
        icon = Icons.local_taxi_rounded;
        break;
      case NotificationIconType.checkmark:
        icon = Icons.check_circle_outline_rounded;
        break;
      case NotificationIconType.support:
        icon = Icons.chat_bubble_outline_rounded;
        break;
      case NotificationIconType.info:
        icon = Icons.info_outline_rounded;
        break;
      case NotificationIconType.driver:
        icon = Icons.person_outline_rounded;
        break;
      case NotificationIconType.receipt:
        icon = Icons.receipt_long_outlined;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 20,
      ),
    );
  }
}
