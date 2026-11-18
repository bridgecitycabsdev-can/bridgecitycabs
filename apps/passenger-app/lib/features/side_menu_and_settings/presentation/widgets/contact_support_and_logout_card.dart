import 'package:flutter/material.dart';

class ContactSupportAndLogoutCard extends StatelessWidget {
  final bool isLogoutLocked;
  final VoidCallback onContactSupport;
  final VoidCallback onLogout;
  final String versionText;

  const ContactSupportAndLogoutCard({
    super.key,
    this.isLogoutLocked = false,
    required this.onContactSupport,
    required this.onLogout,
    this.versionText = 'Version 1.0.19 (Build 240) • Made in Alberta',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: onContactSupport,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.white,
            ),
            icon: const Icon(
              Icons.headset_mic_outlined,
              color: Color(0xFF991B1B),
              size: 18,
            ),
            label: const Text(
              'Contact support',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (isLogoutLocked)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
                SizedBox(width: 8),
                Text(
                  'Finish your trip before logging out.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton.icon(
              onPressed: onLogout,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: const Color(0xFFDC2626),
              ),
              icon: const Icon(
                Icons.logout,
                size: 18,
                color: Color(0xFFDC2626),
              ),
              label: const Text(
                'Log out',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFDC2626),
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          versionText,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
