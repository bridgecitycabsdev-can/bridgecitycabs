import 'package:flutter/material.dart';
import '../../data/models/driver_home_config.dart';
import '../../data/models/driver_home_metrics.dart';
import '../../data/models/driver_shift_mode.dart';
import 'driver_home_metrics_row.dart';
import 'driver_home_shift_toggle.dart';

class DriverHomeConnectionLostPanel extends StatelessWidget {
  final DriverHomeMetrics metrics;
  final VoidCallback onRetryConnection;

  const DriverHomeConnectionLostPanel({
    super.key,
    required this.metrics,
    required this.onRetryConnection,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Reconnecting Alert Box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFCDD2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFC62828),
                ),
                child: const Icon(Icons.wifi_off, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      DriverHomeConfig.offlineReconnectingBanner,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      DriverHomeConfig.checkingConnectionServer,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Title & Offline (Network) Tag
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              DriverHomeConfig.connectionLostTitle,
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
                  SizedBox(width: 5),
                  Text(
                    DriverHomeConfig.offlineNetworkTag,
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

        // Cellular Data Fallback & Helpline Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFEBEE),
                    ),
                    child: const Icon(Icons.sync,
                        size: 16, color: Color(0xFFC62828)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          DriverHomeConfig.attemptingRestoreTitle,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Text(
                          DriverHomeConfig.cellularFallbackDesc,
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Helpline Container
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.phone_outlined,
                            size: 14, color: Color(0xFFC62828)),
                        SizedBox(width: 6),
                        Text(
                          DriverHomeConfig.dispatchHelpline,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      DriverHomeConfig.dispatchPhone,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFC62828),
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
        const SizedBox(height: 16),

        // Retry Connection Large Button
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            key: const ValueKey('driver_retry_connection_button'),
            onPressed: onRetryConnection,
            icon: const Icon(Icons.sync, size: 20, color: Colors.white),
            label: const Text(
              DriverHomeConfig.retryConnectionNow,
              style: TextStyle(
                fontSize: 16,
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
      ],
    );
  }
}
