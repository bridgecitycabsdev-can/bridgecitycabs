import 'package:flutter/material.dart';
import '../../data/models/home_config.dart';
import '../../data/models/user_profile_summary.dart';

class HomeDrawer extends StatelessWidget {
  final UserProfileSummary profile;
  final VoidCallback onClose;
  final VoidCallback onLogout;
  final ValueChanged<String>? onMenuItemTapped;

  const HomeDrawer({
    super.key,
    required this.profile,
    required this.onClose,
    required this.onLogout,
    this.onMenuItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with Logo, Title, and Close Button
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB71C1C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_taxi_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        HomeConfig.appName,
                        style: TextStyle(
                          color: Color(0xFF1E1E1E),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        HomeConfig.appSub,
                        style: TextStyle(
                          color: Color(0xFFB71C1C),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF1E1E1E), size: 22),
                    onPressed: onClose,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // User Profile Summary Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7F7),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFFCDD2), width: 1),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFFFEBEE),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Color(0xFFB71C1C),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            style: const TextStyle(
                              color: Color(0xFF1E1E1E),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 15, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 4),
                              Text(
                                '${profile.rating} • ${profile.riderStatus}',
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Drawer Navigation Items
              _DrawerMenuItem(
                icon: Icons.person_outline_rounded,
                title: 'Profile',
                onTap: () => onMenuItemTapped?.call('profile'),
              ),
              _DrawerMenuItem(
                icon: Icons.history_rounded,
                title: 'Trips',
                badgeText: 'Soon',
                onTap: () => onMenuItemTapped?.call('trips'),
              ),
              _DrawerMenuItem(
                icon: Icons.credit_card_outlined,
                title: 'Payment Methods',
                onTap: () => onMenuItemTapped?.call('payment'),
              ),
              _DrawerMenuItem(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                countBadge: profile.unreadNotifications,
                onTap: () => onMenuItemTapped?.call('notifications'),
              ),
              _DrawerMenuItem(
                icon: Icons.support_agent_rounded,
                title: 'Support',
                onTap: () => onMenuItemTapped?.call('support'),
              ),
              _DrawerMenuItem(
                icon: Icons.shield_outlined,
                title: 'Safety & Emergency',
                onTap: () => onMenuItemTapped?.call('safety'),
              ),
              _DrawerMenuItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () => onMenuItemTapped?.call('settings'),
              ),
              const SizedBox(height: 24),

              // Logout Button
              ElevatedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 19),
                label: const Text(
                  'Log out',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Social Links
              const Center(
                child: Text(
                  'Follow Bridge City Cabs',
                  style: TextStyle(
                    color: Color(0xFF880E14),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialIcon(icon: Icons.facebook, onTap: () {}),
                  const SizedBox(width: 12),
                  _SocialIcon(icon: Icons.camera_alt_outlined, onTap: () {}),
                  const SizedBox(width: 12),
                  _SocialIcon(icon: Icons.alternate_email_rounded, onTap: () {}),
                  const SizedBox(width: 12),
                  _SocialIcon(icon: Icons.work_outline_rounded, onTap: () {}),
                ],
              ),
              const SizedBox(height: 14),

              // Version string
              const Center(
                child: Text(
                  HomeConfig.version,
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? badgeText;
  final int? countBadge;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    this.badgeText,
    this.countBadge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFB71C1C), size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (badgeText != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF880E14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (countBadge != null && countBadge! > 0) ...[
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFFB71C1C),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  countBadge.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
          ],
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFFCDD2)),
        ),
        child: Icon(icon, color: const Color(0xFF880E14), size: 16),
      ),
    );
  }
}
