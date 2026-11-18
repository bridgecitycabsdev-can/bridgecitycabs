import 'package:flutter/material.dart';
import '../../data/models/user_profile_model.dart';

class PreferencesSecuritySection extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onPaymentMethods;
  final VoidCallback onNotifications;
  final VoidCallback onPrivacyAndData;

  const PreferencesSecuritySection({
    super.key,
    required this.user,
    required this.onPaymentMethods,
    required this.onNotifications,
    required this.onPrivacyAndData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Text(
            'PREFERENCES & SECURITY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              _SettingTile(
                icon: Icons.credit_card,
                iconBgColor: const Color(0xFFFFE4E6),
                iconColor: const Color(0xFF9F1239),
                title: 'Payment methods',
                subtitle: user.defaultPaymentMethod,
                onTap: onPaymentMethods,
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFE5E7EB)),
              _SettingTile(
                icon: Icons.notifications_none,
                iconBgColor: const Color(0xFFFFE4E6),
                iconColor: const Color(0xFF9F1239),
                title: 'Notifications',
                subtitle: user.notificationsSummary,
                onTap: onNotifications,
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFE5E7EB)),
              _SettingTile(
                icon: Icons.shield_outlined,
                iconBgColor: const Color(0xFFFFE4E6),
                iconColor: const Color(0xFF9F1239),
                title: 'Privacy and data',
                subtitle: user.privacySummary,
                onTap: onPrivacyAndData,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}
