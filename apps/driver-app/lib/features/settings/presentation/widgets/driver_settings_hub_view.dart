import 'package:flutter/material.dart';
import '../../data/models/driver_navigation_settings.dart';
import '../../data/models/driver_settings_config.dart';
import '../../data/models/driver_settings_status.dart';
import '../../data/models/driver_theme_settings.dart';
import 'driver_settings_driver_card.dart';

class DriverSettingsHubView extends StatelessWidget {
  final DriverIdentityData driver;
  final DriverNavProvider navProvider;
  final DriverThemeMode themeMode;
  final ValueChanged<DriverSettingsStatus> onNavigate;
  final VoidCallback onLogOut;

  const DriverSettingsHubView({
    super.key,
    required this.driver,
    required this.navProvider,
    required this.themeMode,
    required this.onNavigate,
    required this.onLogOut,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Driver Identity
          DriverSettingsDriverCard(driver: driver),
          const SizedBox(height: 14),

          // Preview State Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Text(
                  'PREVIEW\nSTATE:',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF757575),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Text(
                    'Ready',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Trip\nActive',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF757575),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.exit_to_app_rounded,
                        size: 14,
                        color: Color(0xFFC62828),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Modal',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC62828),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // PREFERENCES Section
          _buildSectionHeader('PREFERENCES', 'System config'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildMenuTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  hasRedBadge: true,
                  onTap: () => onNavigate(DriverSettingsStatus.notifications),
                ),
                const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                _buildMenuTile(
                  icon: Icons.explore_outlined,
                  title: 'Navigation app',
                  subtitle: navProvider.name,
                  onTap: () => onNavigate(DriverSettingsStatus.navigation),
                ),
                const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                _buildMenuTile(
                  icon: Icons.palette_outlined,
                  title: 'Theme',
                  subtitle: '${themeMode.title} (High Contrast)',
                  onTap: () => onNavigate(DriverSettingsStatus.theme),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // SUPPORT & LEGAL Section
          _buildSectionHeader('SUPPORT & LEGAL', 'Compliance'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildMenuTile(
                  icon: Icons.help_outline_rounded,
                  title: 'FAQs',
                  onTap: () => onNavigate(DriverSettingsStatus.faqs),
                ),
                const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                _buildMenuTile(
                  icon: Icons.shield_outlined,
                  title: 'Insurance & Cover...',
                  badgeText: 'ACTIVE',
                  onTap: () => onNavigate(DriverSettingsStatus.insurance),
                ),
                const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                _buildMenuTile(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  onTap: () => onNavigate(DriverSettingsStatus.terms),
                ),
                const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                _buildMenuTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Privacy Policy',
                  onTap: () => onNavigate(DriverSettingsStatus.terms),
                ),
                const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
                _buildMenuTile(
                  icon: Icons.headset_mic_outlined,
                  title: 'Contact Support',
                  subtitle: '24/7 Lethbridge Central Dispatch',
                  onTap: () => onNavigate(DriverSettingsStatus.faqs),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Fleet Operations Banner
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF2B2D2F), Color(0xFF4A4E51)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'BRIDGE CITY FLEET OPERATIONS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Oldman River Valley District',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Log out Button
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: onLogOut,
              icon: const Icon(
                Icons.exit_to_app_rounded,
                color: Color(0xFFC62828),
                size: 18,
              ),
              label: const Text(
                'Log out',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC62828),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFFCDD2)),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // App Version Footer
          const Center(
            child: Column(
              children: [
                Text(
                  DriverSettingsConfig.appVersion,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF757575),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  DriverSettingsConfig.regulationNotice,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String rightSubtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E1E),
            letterSpacing: 0.5,
          ),
        ),
        Text(
          rightSubtitle,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF757575),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    String? subtitle,
    String? badgeText,
    bool hasRedBadge = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFC62828),
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ),
              if (subtitle != null) ...[
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              if (badgeText != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              if (hasRedBadge) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC62828),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFBDBDBD),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
