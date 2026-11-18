import 'package:flutter/material.dart';

class DriverMenuSupportCard extends StatelessWidget {
  final bool isActiveTrip;
  final bool hasArrow;
  final VoidCallback onSupportTap;
  final VoidCallback? onCallHubTap;

  const DriverMenuSupportCard({
    super.key,
    this.isActiveTrip = false,
    this.hasArrow = false,
    required this.onSupportTap,
    this.onCallHubTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFEBEE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFFEBEE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent,
              size: 20,
              color: Color(0xFFC62828),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isActiveTrip
                      ? 'Need support?'
                      : 'Need help? Contact Bridge City Cabs support.',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                    height: 1.25,
                  ),
                ),
                if (isActiveTrip)
                  const Text(
                    'Bridge City Dispatch line',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  )
                else
                  GestureDetector(
                    onTap: onSupportTap,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        hasArrow ? 'Contact support ➔' : 'Contact support',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB71C1C),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isActiveTrip)
            ElevatedButton(
              onPressed: onCallHubTap ?? onSupportTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFCDD2),
                foregroundColor: const Color(0xFFB71C1C),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Call Hub',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
