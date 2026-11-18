import 'package:flutter/material.dart';
import '../../data/models/trip_history_config.dart';

class ComingSoonPastTripsCard extends StatelessWidget {
  final VoidCallback onOpenNotifications;
  final VoidCallback onContactSupport;

  const ComingSoonPastTripsCard({
    super.key,
    required this.onOpenNotifications,
    required this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          // Graphic Illustration (Calendar + Car + Pin)
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 140,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Column(
                children: [
                  Container(
                    width: 80,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Color(0xFFB91C1C),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            Icon(Icons.circle, size: 6, color: Color(0xFFD1D5DB)),
                            Icon(Icons.circle, size: 6, color: Color(0xFFB91C1C)),
                            Icon(Icons.circle, size: 6, color: Color(0xFFD1D5DB)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            Icon(Icons.circle, size: 6, color: Color(0xFF1F2937)),
                            Icon(Icons.circle, size: 6, color: Color(0xFFD1D5DB)),
                            Icon(Icons.circle, size: 6, color: Color(0xFFD1D5DB)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFB91C1C), width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.local_taxi, size: 16, color: Color(0xFFB91C1C)),
                        SizedBox(width: 4),
                        Icon(Icons.location_on, size: 14, color: Color(0xFFB91C1C)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Title & Subtitle
          const Text(
            TripHistoryConfig.comingSoonTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            TripHistoryConfig.comingSoonSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Primary Open Notifications Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onOpenNotifications,
              icon: const Icon(Icons.notifications_none, size: 18, color: Color(0xFF111827)),
              label: const Text(
                'Open notifications',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5E7EB),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Contact Support Text Button
          TextButton.icon(
            onPressed: onContactSupport,
            icon: const Icon(Icons.headphones_outlined, size: 16, color: Color(0xFF991B1B)),
            label: const Text(
              'Contact support',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF991B1B),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Email Receipt Automatic Notice
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.mail_outline, size: 16, color: Color(0xFF6B7280)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  TripHistoryConfig.emailReceiptNotice,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF6B7280),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
