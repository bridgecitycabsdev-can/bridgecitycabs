import 'package:flutter/material.dart';
import '../../data/models/sos_alert_config.dart';

class SosAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isActive;
  final VoidCallback? onBack;
  final VoidCallback? onCallSafetyLine;

  const SosAppBar({
    super.key,
    required this.isActive,
    this.onBack,
    this.onCallSafetyLine,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        isActive ? SosAlertConfig.activeTitle : SosAlertConfig.screenTitle,
        style: const TextStyle(
          color: Color(0xFF111827),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFFFE4E6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.phone,
              color: Color(0xFF9F1239),
              size: 18,
            ),
          ),
          onPressed: onCallSafetyLine,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF881337),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}

class SosStatusRibbon extends StatelessWidget {
  final bool isActive;
  final String routeStatus;

  const SosStatusRibbon({
    super.key,
    required this.isActive,
    required this.routeStatus,
  });

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: const Color(0xFFB91C1C),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'BRIDGE CITY SAFETY ACTIVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            Row(
              children: const [
                Icon(Icons.lock, color: Colors.white, size: 12),
                SizedBox(width: 4),
                Text(
                  'Live Link',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF2F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_car,
              size: 14,
              color: Color(0xFFB91C1C),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              routeStatus,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFB91C1C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.shield, color: Colors.white, size: 11),
                SizedBox(width: 3),
                Text(
                  'Emergency SOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
