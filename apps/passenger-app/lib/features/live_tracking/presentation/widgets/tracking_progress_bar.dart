import 'package:flutter/material.dart';

class TrackingProgressBar extends StatelessWidget {
  final double progress;
  final String pickupLabel;
  final String dropoffLabel;
  final bool isSyncing;

  const TrackingProgressBar({
    super.key,
    required this.progress,
    required this.pickupLabel,
    required this.dropoffLabel,
    this.isSyncing = false,
  });

  @override
  Widget build(BuildContext context) {
    final percentInt = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isSyncing) ...[
          Row(
            children: const [
              Icon(
                Icons.sync,
                size: 13,
                color: Color(0xFFC62828),
              ),
              SizedBox(width: 6),
              Text(
                'Real-time position syncing...',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFC62828),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],

        // Bar track
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 6,
            width: double.infinity,
            color: const Color(0xFFEEEEEE),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress.clamp(0.05, 1.0),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFC62828),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Sub labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              pickupLabel,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
              ),
            ),
            if (!isSyncing && percentInt > 0)
              Text(
                '$percentInt% completed',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFC62828),
                ),
              ),
            Text(
              dropoffLabel,
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
