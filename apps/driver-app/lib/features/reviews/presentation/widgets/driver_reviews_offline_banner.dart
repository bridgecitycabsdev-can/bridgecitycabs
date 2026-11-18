import 'package:flutter/material.dart';

class DriverReviewsOfflineBanner extends StatelessWidget {
  final VoidCallback onRetry;

  const DriverReviewsOfflineBanner({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF9C4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFF57F17),
            size: 18,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              "You're offline. Showing saved reviews from local cache...",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5D4037),
              ),
            ),
          ),
          InkWell(
            onTap: onRetry,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF176),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.sync,
                size: 14,
                color: Color(0xFF5D4037),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
