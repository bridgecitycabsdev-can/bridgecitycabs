import 'package:flutter/material.dart';
import '../../data/models/notifications_config.dart';

class NotificationsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;
  final VoidCallback onMarkAllAsRead;
  final bool hasUnread;

  const NotificationsAppBar({
    super.key,
    required this.onBack,
    required this.onMarkAllAsRead,
    this.hasUnread = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
        onPressed: onBack,
        tooltip: 'Back',
      ),
      centerTitle: true,
      title: const Text(
        NotificationsConfig.screenTitle,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
        ),
      ),
      actions: [
        TextButton(
          onPressed: hasUnread ? onMarkAllAsRead : null,
          child: Text(
            NotificationsConfig.markAllAsRead,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: hasUnread
                  ? const Color(0xFF991B1B)
                  : const Color(0xFFCBD5E1),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 4),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF991B1B),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
