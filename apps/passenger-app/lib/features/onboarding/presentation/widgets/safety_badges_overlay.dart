import 'package:flutter/material.dart';

/// Floating safety and dispatch badges for Onboarding Screen 3 ("We've got your back, 24/7"):
/// - Central "SECURE" shield badge
/// - "SOS Signal • Lethbridge 911 Link" badge
/// - "24/7 Dispatch • Instant Local Team" badge
/// - "Share Trip Live • Sent to emergency contacts" badge
class SafetyBadgesOverlay extends StatelessWidget {
  const SafetyBadgesOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background layout column to position the badges
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge 1 (Top Right): SOS Signal
              Align(
                alignment: const Alignment(0.85, 0),
                child: _buildBadge(
                  iconBgColor: const Color(0xFFFFEBEE),
                  icon: const Icon(
                    Icons.emergency_rounded,
                    color: Color(0xFFB71C1C),
                    size: 15,
                  ),
                  title: 'SOS Signal',
                  titleDotColor: const Color(0xFFB71C1C),
                  subtitle: 'Lethbridge 911 Link',
                ),
              ),
              const SizedBox(height: 18),

              // Badge 2 (Middle Left): 24/7 Dispatch
              Align(
                alignment: const Alignment(-0.85, 0),
                child: _buildBadge(
                  iconBgColor: const Color(0xFFF3F4F6),
                  icon: const Icon(
                    Icons.support_agent_rounded,
                    color: Color(0xFF980F1B),
                    size: 16,
                  ),
                  title: '24/7 Dispatch',
                  titleDotColor: const Color(0xFF10B981),
                  subtitle: 'Instant Local Team',
                ),
              ),
              const SizedBox(height: 52),

              // Badge 3 (Bottom Right): Share Trip Live
              Align(
                alignment: const Alignment(0.7, 0),
                child: _buildBadge(
                  iconBgColor: const Color(0xFFFFEBEE),
                  icon: const Icon(
                    Icons.share_location_rounded,
                    color: Color(0xFFB71C1C),
                    size: 15,
                  ),
                  title: 'Share Trip Live',
                  subtitle: 'Sent to emergency contacts',
                ),
              ),
            ],
          ),

          // Central SECURE Shield Emblem
          Positioned(
            top: 45,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFB71C1C),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB71C1C).withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'SECURE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required Color iconBgColor,
    required Widget icon,
    required String title,
    required String subtitle,
    Color? titleDotColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Center(child: icon),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (titleDotColor != null) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: titleDotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
