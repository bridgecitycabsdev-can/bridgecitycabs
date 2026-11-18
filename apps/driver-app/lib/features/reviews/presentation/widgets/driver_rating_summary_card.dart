import 'package:flutter/material.dart';
import '../../data/models/driver_rating_distribution.dart';

class DriverRatingSummaryCard extends StatelessWidget {
  final DriverRatingDistribution distribution;

  const DriverRatingSummaryCard({
    super.key,
    required this.distribution,
  });

  @override
  Widget build(BuildContext context) {
    final maxCount = distribution.totalReviews > 0
        ? distribution.totalReviews.toDouble()
        : 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Rating & Stars
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  distribution.overallRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFBC02D),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${distribution.totalReviews} reviews',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 80,
            width: 1,
            color: const Color(0xFFEEEEEE),
          ),
          const SizedBox(width: 16),

          // Right: 5 Distribution Bars
          Expanded(
            flex: 6,
            child: Column(
              children: [
                _buildBar(5, distribution.star5Count, maxCount),
                const SizedBox(height: 4),
                _buildBar(4, distribution.star4Count, maxCount),
                const SizedBox(height: 4),
                _buildBar(3, distribution.star3Count, maxCount),
                const SizedBox(height: 4),
                _buildBar(2, distribution.star2Count, maxCount),
                const SizedBox(height: 4),
                _buildBar(1, distribution.star1Count, maxCount),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(int star, int count, double max) {
    final ratio = (count / max).clamp(0.0, 1.0);

    return Row(
      children: [
        Text(
          '$star',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF616161),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: const Color(0xFFF0F0F0),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFBC02D),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 20,
          child: Text(
            '$count',
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF757575),
            ),
          ),
        ),
      ],
    );
  }
}
