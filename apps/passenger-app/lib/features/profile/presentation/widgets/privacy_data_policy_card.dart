import 'package:flutter/material.dart';
import '../../data/models/profile_config.dart';

class PrivacyDataPolicyCard extends StatelessWidget {
  final VoidCallback onReadPrivacyPolicy;
  final VoidCallback onReadTerms;

  const PrivacyDataPolicyCard({
    super.key,
    required this.onReadPrivacyPolicy,
    required this.onReadTerms,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trust & Safety Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.shield_outlined, size: 13, color: Color(0xFF991B1B)),
                SizedBox(width: 5),
                Text(
                  'LETHBRIDGE TRUST & SAFETY',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF991B1B),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Main Header & Subtitle
          const Text(
            'How we protect and manage your data on Bridge City Cabs rides in Lethbridge.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We prioritize transparency and passenger safety across Southern Alberta with strict data retention boundaries.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),

          // Card 1: Your Location
          _DataPolicyCard(
            icon: Icons.my_location,
            title: 'Your location',
            description:
                "We use your location only to set your pickup point and for your safety during a trip. We don't track you in the background.",
            badgeText: 'Foreground only • GPS active during trips',
            hasGreenDot: true,
          ),
          const SizedBox(height: 12),

          // Card 2: Your Payments
          _DataPolicyCard(
            icon: Icons.lock_outline,
            title: 'Your payments',
            description:
                'Cards are processed securely by Stripe. Bridge City Cabs never sees or stores your full card number.',
            badgeText: 'Stripe 256-bit SSL • PCI-DSS Tier 1',
            badgeIcon: Icons.shield_outlined,
          ),
          const SizedBox(height: 12),

          // Card 3: Your Notifications
          _DataPolicyCard(
            icon: Icons.notifications_none,
            title: 'Your notifications',
            description:
                'We send ride updates and support replies. You can turn them off in your phone settings.',
            badgeText: 'Push & SMS notifications',
            badgeIcon: Icons.outlined_flag,
          ),
          const SizedBox(height: 24),

          // Legal & Policies Section
          const Text(
            'LEGAL & POLICIES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),

          // Policy Link 1: Privacy Policy
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: ListTile(
              onTap: onReadPrivacyPolicy,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE4E6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.description_outlined, size: 18, color: Color(0xFF9F1239)),
              ),
              title: const Text(
                'Read the Privacy Policy',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
              ),
              trailing: const Icon(Icons.open_in_new, size: 18, color: Color(0xFF6B7280)),
            ),
          ),

          // Policy Link 2: Terms and Conditions
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: ListTile(
              onTap: onReadTerms,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE4E6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.menu_book_outlined, size: 18, color: Color(0xFF9F1239)),
              ),
              title: const Text(
                'Read the Terms and Conditions',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
              ),
              trailing: const Icon(Icons.open_in_new, size: 18, color: Color(0xFF6B7280)),
            ),
          ),

          // PIPA Compliance Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.gavel, size: 18, color: Color(0xFF881337)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ProfileConfig.pipComplianceNotice,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF4B5563),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DataPolicyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String badgeText;
  final bool hasGreenDot;
  final IconData? badgeIcon;

  const _DataPolicyCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.badgeText,
    this.hasGreenDot = false,
    this.badgeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE4E6),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: Color(0xFF9F1239)),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasGreenDot) ...[
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                ] else if (badgeIcon != null) ...[
                  Icon(badgeIcon, size: 13, color: const Color(0xFF4B5563)),
                  const SizedBox(width: 5),
                ],
                Text(
                  badgeText,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
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
