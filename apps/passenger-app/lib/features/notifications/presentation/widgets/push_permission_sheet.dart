import 'package:flutter/material.dart';

class PushPermissionSheet extends StatelessWidget {
  final VoidCallback onEnable;
  final VoidCallback onDismiss;

  const PushPermissionSheet({
    super.key,
    required this.onEnable,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Feature Rows
          _featureRow(
            icon: Icons.navigation_outlined,
            title: 'Live distance tracking',
            subtitle: 'Real-time vehicle distance (e.g., 3 min away)',
          ),
          const SizedBox(height: 12),

          _featureRow(
            icon: Icons.location_on_outlined,
            title: 'Driver arrival ping',
            subtitle: 'Prompt notification right at your pickup curb',
          ),
          const SizedBox(height: 12),

          _featureRow(
            icon: Icons.receipt_long_outlined,
            title: 'Instant fare receipts',
            subtitle: 'Detailed CAD trip summaries upon drop-off',
          ),
          const SizedBox(height: 12),

          _featureRow(
            icon: Icons.notifications_active_outlined,
            title: 'In-app activity center',
            subtitle: 'Never miss gate codes or driver chat updates',
            trailingBadge: 'Preview',
          ),
          const SizedBox(height: 24),

          // Turn on notifications CTA
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onEnable,
              icon: const Icon(Icons.notifications_active, size: 20),
              label: const Text(
                'Turn on notifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB91C1C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Not now button
          TextButton(
            onPressed: onDismiss,
            child: const Text(
              'Not now',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Disclaimer
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, size: 13, color: Color(0xFF94A3B8)),
              SizedBox(width: 6),
              Text(
                'You can turn these off anytime in your device Settings.',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _featureRow({
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailingBadge,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF991B1B), size: 18),
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
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          if (trailingBadge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                trailingBadge,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF991B1B),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
