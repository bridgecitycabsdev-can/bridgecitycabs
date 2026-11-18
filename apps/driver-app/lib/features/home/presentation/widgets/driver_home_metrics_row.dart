import 'package:flutter/material.dart';
import '../../data/models/driver_home_metrics.dart';

class DriverHomeMetricsRow extends StatelessWidget {
  final DriverHomeMetrics metrics;

  const DriverHomeMetricsRow({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Card 1: Rides Today
        Expanded(
          child: _buildCard(
            label: 'Rides today',
            value: '${metrics.ridesToday}',
            icon: Icons.directions_car_outlined,
          ),
        ),
        const SizedBox(width: 10),

        // Card 2: Acceptance
        Expanded(
          child: _buildCard(
            label: 'Acceptance',
            value: '${metrics.acceptanceRate}%',
            icon: Icons.thumb_up_alt_outlined,
            isAcceptance: true,
          ),
        ),
        const SizedBox(width: 10),

        // Card 3: Online Time
        Expanded(
          child: _buildCard(
            label: 'Online time',
            value: metrics.onlineTime,
            icon: Icons.access_time,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String label,
    required String value,
    required IconData icon,
    bool isAcceptance = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: const Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isAcceptance) ...[
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFC62828), width: 2),
                  ),
                ),
              ],
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
