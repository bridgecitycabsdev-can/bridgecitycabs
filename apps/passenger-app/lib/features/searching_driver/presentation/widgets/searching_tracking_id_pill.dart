import 'package:flutter/material.dart';
import '../../data/models/driver_search_models.dart';
import '../../data/models/searching_driver_config.dart';

class SearchingTrackingIdPill extends StatelessWidget {
  final String trackingId;
  final SearchingDriverStatus status;
  final bool isReconnecting;
  final int connectingSecondsRemaining;
  final VoidCallback onCopy;

  const SearchingTrackingIdPill({
    super.key,
    required this.trackingId,
    required this.status,
    this.isReconnecting = false,
    this.connectingSecondsRemaining = 2,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    if (status == SearchingDriverStatus.driverFound) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Color(0xFF00A86B)),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${SearchingDriverConfig.connectingText} ${connectingSecondsRemaining}s',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F1F1F),
                ),
              ),
            ],
          ),
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    trackingId,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.copy, size: 13, color: Color(0xFF4B5563)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: onCopy,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC62828),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Tracking ID • $trackingId',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.copy, size: 13, color: Color(0xFF6B7280)),
              ],
            ),
          ),
        ),
        if (status == SearchingDriverStatus.searching && !isReconnecting) ...[
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF00A86B),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                SearchingDriverConfig.liveRadarActive,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00A86B),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
