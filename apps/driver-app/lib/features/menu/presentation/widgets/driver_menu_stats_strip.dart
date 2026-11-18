import 'package:flutter/material.dart';
import '../../data/models/driver_menu_stats.dart';

class DriverMenuStatsStrip extends StatelessWidget {
  final DriverMenuStats stats;
  final bool isOffline;
  final bool isUppercase;

  const DriverMenuStatsStrip({
    super.key,
    required this.stats,
    this.isOffline = false,
    this.isUppercase = false,
  });

  @override
  Widget build(BuildContext context) {
    final todayLabel = isUppercase ? 'TODAY' : 'Today';
    final faresLabel = isUppercase
        ? 'FARES'
        : (stats.ridesCompleted == 1 ? '1 Ride' : '${stats.ridesCompleted} Rides');
    final distanceLabel = isUppercase
        ? 'DISTANCE'
        : '${stats.distanceKm.toInt()} km';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Earnings
              Row(
                children: [
                  const Icon(
                    Icons.trending_up,
                    size: 16,
                    color: Color(0xFFC62828),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$todayLabel ',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    '\$${stats.todayEarnings.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: stats.todayEarnings > 0
                          ? const Color(0xFFC62828)
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(width: 1, height: 16, color: Colors.black12),
              // Rides
              Text(
                isUppercase
                    ? '$faresLabel ${stats.ridesCompleted}'
                    : faresLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Container(width: 1, height: 16, color: Colors.black12),
              // Distance
              Text(
                isUppercase
                    ? '$distanceLabel ${stats.distanceKm.toInt()} km'
                    : distanceLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          if (isOffline && stats.shiftPrompt != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.circle, size: 6, color: Colors.brown),
                const SizedBox(width: 4),
                Text(
                  stats.shiftPrompt!.replaceFirst('● ', ''),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
