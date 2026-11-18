import 'package:flutter/material.dart';
import '../../data/models/driver_earnings_summary.dart';

class DriverEarningsChartCard extends StatelessWidget {
  final String dateRangeText;
  final String zoneLabel;
  final List<DayEarningPoint> dailyPoints;

  const DriverEarningsChartCard({
    super.key,
    required this.dateRangeText,
    required this.zoneLabel,
    required this.dailyPoints,
  });

  @override
  Widget build(BuildContext context) {
    // Find maximum amount for scaling
    final maxAmount = dailyPoints.fold<double>(
      25.0,
      (max, p) => p.amount > max ? p.amount : max,
    );

    final highlightedPoint = dailyPoints.firstWhere(
      (p) => p.isHighlighted,
      orElse: () => dailyPoints.first,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily earnings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateRangeText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  zoneLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB71C1C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tooltip on active point
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF222831),
                borderRadius: BorderRadius.circular(20),
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                  children: [
                    TextSpan(
                      text: '${highlightedPoint.dayName} • ',
                      style: const TextStyle(color: Color(0xFFB0BEC5)),
                    ),
                    TextSpan(
                      text: '\$${highlightedPoint.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    TextSpan(
                      text: ' • ${highlightedPoint.rideCount} ride',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 7-day bar chart
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: dailyPoints.map((point) {
                final barHeight = point.amount > 0
                    ? ((point.amount / maxAmount) * 80).clamp(16.0, 80.0)
                    : 12.0;

                final isHigh = point.isHighlighted;
                final barColor = isHigh
                    ? const Color(0xFFD32F2F)
                    : point.amount > 0
                        ? const Color(0xFFFFCDD2)
                        : const Color(0xFFE0E0E0);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 26,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      point.dayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isHigh ? FontWeight.bold : FontWeight.w500,
                        color: isHigh
                            ? const Color(0xFFD32F2F)
                            : const Color(0xFF757575),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
