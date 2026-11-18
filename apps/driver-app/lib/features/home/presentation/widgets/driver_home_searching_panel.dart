import 'package:flutter/material.dart';
import '../../data/models/driver_home_config.dart';
import '../../data/models/driver_home_metrics.dart';
import '../../data/models/driver_shift_mode.dart';
import '../../data/models/driver_surge_zone.dart';
import 'driver_home_metrics_row.dart';
import 'driver_home_shift_toggle.dart';

class DriverHomeSearchingPanel extends StatelessWidget {
  final DriverHomeMetrics metrics;
  final DriverShiftMode shiftMode;
  final DriverSurgeZone surgeZone;
  final VoidCallback onSetAway;
  final VoidCallback onViewSurge;

  const DriverHomeSearchingPanel({
    super.key,
    required this.metrics,
    required this.shiftMode,
    required this.surgeZone,
    required this.onSetAway,
    required this.onViewSurge,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header Row: Shift started 07:45 AM & ONLINE pill
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Shift started ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  metrics.shiftStartTime ?? '07:45 AM',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.circle, size: 7, color: Color(0xFF16A34A)),
                  SizedBox(width: 5),
                  Text(
                    DriverHomeConfig.onlineTag,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF15803D),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Active / Away Segmented Toggle
        DriverHomeShiftToggle(
          shiftMode: shiftMode,
          onActiveTap: () {},
          onAwayTap: onSetAway,
        ),
        const SizedBox(height: 14),

        // Searching for Rides Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFEBEE),
                ),
                child: const Icon(Icons.local_taxi,
                    color: Color(0xFFC62828), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text(
                          DriverHomeConfig.searchingRidesTitle,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.circle, size: 6, color: Color(0xFFC62828)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      DriverHomeConfig.stayInBusyAreaDesc,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 3 Metrics Cards
        DriverHomeMetricsRow(metrics: metrics),
        const SizedBox(height: 14),

        // Surge Zone Callout Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5F5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFCDD2)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.whatshot,
                    color: Color(0xFFC62828), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surgeZone.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFCDD2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${surgeZone.multiplier}x',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB71C1C),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            surgeZone.subtitle,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                key: const ValueKey('driver_view_surge_button'),
                onPressed: onViewSurge,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFC62828),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFFFCDD2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  children: const [
                    Text('View', style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 13),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
