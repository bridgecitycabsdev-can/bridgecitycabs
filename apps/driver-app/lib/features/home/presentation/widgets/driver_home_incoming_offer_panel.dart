import 'package:flutter/material.dart';
import '../../data/models/driver_home_config.dart';
import '../../data/models/driver_home_metrics.dart';
import '../../data/models/driver_incoming_offer.dart';
import '../../data/models/driver_shift_mode.dart';
import 'driver_home_metrics_row.dart';
import 'driver_home_shift_toggle.dart';

class DriverHomeIncomingOfferPanel extends StatelessWidget {
  final DriverHomeMetrics metrics;
  final DriverIncomingOffer incomingOffer;
  final VoidCallback onViewOffer;

  const DriverHomeIncomingOfferPanel({
    super.key,
    required this.metrics,
    required this.incomingOffer,
    required this.onViewOffer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title & Alert Active Tag
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              DriverHomeConfig.incomingRideOfferTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.circle, size: 7, color: Color(0xFFC62828)),
                  SizedBox(width: 4),
                  Icon(Icons.notifications_active,
                      size: 11, color: Color(0xFFC62828)),
                  SizedBox(width: 4),
                  Text(
                    DriverHomeConfig.alertActiveTag,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFC62828),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Chime playing banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFCDD2)),
          ),
          child: Row(
            children: const [
              Icon(Icons.volume_up, size: 18, color: Color(0xFFC62828)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  DriverHomeConfig.incomingDispatchChime,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF4B5563),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Shift Toggle (Active selected)
        const DriverHomeShiftToggle(shiftMode: DriverShiftMode.active),
        const SizedBox(height: 14),

        // Solid Crimson Red Broadcast Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF991B1B),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22991B1B),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Broadcast header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.campaign, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        DriverHomeConfig.dispatchBroadcast,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'ılı',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // View incoming trip offer button
              InkWell(
                key: const ValueKey('driver_view_incoming_offer_button'),
                onTap: onViewOffer,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.touch_app,
                          size: 20, color: Color(0xFF991B1B)),
                      const SizedBox(width: 8),
                      Text(
                        'View incoming trip offer (${incomingOffer.remainingSeconds}s remaining)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF991B1B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 3 Metrics Cards
        DriverHomeMetricsRow(metrics: metrics),
      ],
    );
  }
}
