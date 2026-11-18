import 'package:flutter/material.dart';
import '../../data/models/driver_home_config.dart';
import '../../data/models/driver_home_metrics.dart';
import '../../data/models/driver_shift_mode.dart';
import 'driver_home_metrics_row.dart';
import 'driver_home_shift_toggle.dart';

class DriverHomeLocationPanel extends StatelessWidget {
  final DriverHomeMetrics metrics;
  final VoidCallback onEnableLocation;

  const DriverHomeLocationPanel({
    super.key,
    required this.metrics,
    required this.onEnableLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Red Location Off Alert Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFCDD2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFC62828),
                ),
                child: const Icon(Icons.location_disabled,
                    size: 18, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      DriverHomeConfig.locationOffBannerTitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      DriverHomeConfig.locationOffBannerDesc,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF4B5563),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                onPressed: onEnableLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: const Size(0, 32),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Open',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Title & Offline (GPS) Tag
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  DriverHomeConfig.locationRequiredTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  metrics.currentLocationName,
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
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.circle, size: 7, color: Color(0xFFC62828)),
                  SizedBox(width: 5),
                  Text(
                    DriverHomeConfig.locationOffTag,
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
        const SizedBox(height: 14),

        // Locked Shift Toggle
        const DriverHomeShiftToggle(
          shiftMode: DriverShiftMode.locked,
          isLocked: true,
        ),
        const SizedBox(height: 14),

        // Regulatory Dispatch Notice
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.info_outline, size: 16, color: Color(0xFF6B7280)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                DriverHomeConfig.gpsNotice,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF4B5563),
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Large Enable Location Button
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            key: const ValueKey('driver_enable_location_button'),
            onPressed: onEnableLocation,
            icon: const Icon(Icons.settings, size: 18, color: Colors.white),
            label: const Text(
              DriverHomeConfig.enableLocationSettings,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
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
