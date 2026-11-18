import 'package:flutter/material.dart';
import '../../data/models/driver_home_config.dart';
import '../../data/models/driver_home_metrics.dart';
import 'driver_home_metrics_row.dart';

class DriverHomeOfflinePanel extends StatelessWidget {
  final DriverHomeMetrics metrics;
  final VoidCallback onGoOnline;

  const DriverHomeOfflinePanel({
    super.key,
    required this.metrics,
    required this.onGoOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title & Status Tag
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  DriverHomeConfig.offlineTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  DriverHomeConfig.offlineSubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.circle, size: 7, color: Color(0xFFB91C1C)),
                  SizedBox(width: 5),
                  Text(
                    DriverHomeConfig.offlineTag,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4B5563),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Description
        const Text(
          DriverHomeConfig.offlineDesc,
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF4B5563),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 18),

        // Red Go Online Action Button
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            key: const ValueKey('driver_go_online_button'),
            onPressed: onGoOnline,
            icon: const Icon(Icons.power_settings_new,
                size: 20, color: Colors.white),
            label: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  DriverHomeConfig.goOnlineButton,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward, size: 18, color: Colors.white),
              ],
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // 3 Metrics Cards
        DriverHomeMetricsRow(metrics: metrics),
        const SizedBox(height: 14),

        // Dispatch Server Active Footer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.hub_outlined, size: 16, color: Color(0xFF16A34A)),
                SizedBox(width: 6),
                Text(
                  DriverHomeConfig.dispatchServerActive,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
            Text(
              'Ping ${metrics.pingMs}ms',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
