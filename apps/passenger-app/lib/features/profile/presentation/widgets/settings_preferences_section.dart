import 'package:flutter/material.dart';

class SettingsPreferencesSection extends StatelessWidget {
  final bool notificationsEnabled;
  final ValueChanged<bool> onNotificationToggle;
  final VoidCallback onFaq;
  final VoidCallback onTerms;
  final VoidCallback onPrivacyPolicy;
  final VoidCallback onBecomeDriver;
  final VoidCallback onAbout;

  const SettingsPreferencesSection({
    super.key,
    required this.notificationsEnabled,
    required this.onNotificationToggle,
    required this.onFaq,
    required this.onTerms,
    required this.onPrivacyPolicy,
    required this.onBecomeDriver,
    required this.onAbout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            'PREFERENCES & POLICIES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              // Notifications Switch Tile
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    _IconBadge(icon: Icons.notifications_none),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Notifications',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Ride status, arriving alerts &...',
                            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: notificationsEnabled,
                      activeColor: Colors.white,
                      activeTrackColor: const Color(0xFF881337),
                      onChanged: onNotificationToggle,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFE5E7EB)),

              // FAQ
              _SettingItem(
                icon: Icons.help_outline,
                title: 'Frequently asked questions',
                subtitle: 'Trip fares, lost items, and bookin...',
                onTap: onFaq,
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFE5E7EB)),

              // Terms and conditions
              _SettingItem(
                icon: Icons.description_outlined,
                title: 'Terms and conditions',
                subtitle: 'Alberta vehicle-for-hire transit te...',
                onTap: onTerms,
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFE5E7EB)),

              // Privacy policy
              _SettingItem(
                icon: Icons.shield_outlined,
                title: 'Privacy policy',
                subtitle: 'GPS tracking and ride history en...',
                onTap: onPrivacyPolicy,
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFE5E7EB)),

              // Become a driver
              InkWell(
                onTap: onBecomeDriver,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      _IconBadge(icon: Icons.local_taxi_outlined),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Become a driver',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Drive with Bridge City Cab...',
                              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: const [
                          Text(
                            'Apply',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF881337),
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.open_in_new, size: 14, color: Color(0xFF881337)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFE5E7EB)),

              // About
              _SettingItem(
                icon: Icons.info_outline,
                title: 'About Bridge City Cabs',
                subtitle: 'Local Lethbridge transit & taxi di...',
                onTap: onAbout,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;

  const _IconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Color(0xFFFFE4E6),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: Color(0xFF9F1239)),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            _IconBadge(icon: icon),
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
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}
