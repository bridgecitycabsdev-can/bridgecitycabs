import 'package:flutter/material.dart';
import '../../data/models/driver_home_config.dart';
import '../../data/models/driver_home_metrics.dart';
import '../../data/models/driver_shift_mode.dart';
import 'driver_home_metrics_row.dart';
import 'driver_home_shift_toggle.dart';

class DriverHomeAwayPanel extends StatelessWidget {
  final DriverHomeMetrics metrics;
  final VoidCallback onResumeActive;

  const DriverHomeAwayPanel({
    super.key,
    required this.metrics,
    required this.onResumeActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title & AWAY pill
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  DriverHomeConfig.shiftOnPauseTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DriverHomeConfig.shiftOnPauseSubtitle,
                  style: const TextStyle(
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
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.circle, size: 7, color: Color(0xFFFBBF24)),
                  SizedBox(width: 5),
                  Text(
                    DriverHomeConfig.awayTag,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Shift Toggle (Away active)
        DriverHomeShiftToggle(
          shiftMode: DriverShiftMode.away,
          onActiveTap: onResumeActive,
          onAwayTap: () {},
        ),
        const SizedBox(height: 14),

        // Coffee Break Away Status Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.coffee_outlined,
                    color: Color(0xFF4B5563), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      DriverHomeConfig.currentlyAwayTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      DriverHomeConfig.currentlyAwayDesc,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4B5563),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Back to Active Large Button
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            key: const ValueKey('driver_back_to_active_button'),
            onPressed: onResumeActive,
            icon: const Icon(Icons.bolt, size: 20, color: Colors.white),
            label: const Text(
              DriverHomeConfig.backToActiveButton,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 3 Metrics Cards
        DriverHomeMetricsRow(metrics: metrics),
      ],
    );
  }
}
