import 'package:flutter/material.dart';
import '../../data/models/driver_review_item.dart';

class DriverReviewDetailModal extends StatelessWidget {
  final DriverReviewItem review;
  final VoidCallback onReport;
  final VoidCallback onClose;

  const DriverReviewDetailModal({
    super.key,
    required this.review,
    required this.onReport,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Trip quick specs strip
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.alt_route_rounded,
                size: 14,
                color: Color(0xFFC62828),
              ),
              const SizedBox(width: 4),
              const Text(
                '4.52 km',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(width: 10),
              const Text('•', style: TextStyle(color: Color(0xFFBDBDBD))),
              const SizedBox(width: 10),
              const Icon(
                Icons.access_time_rounded,
                size: 14,
                color: Color(0xFF424242),
              ),
              const SizedBox(width: 4),
              const Text(
                '14 mins',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(width: 10),
              const Text('•', style: TextStyle(color: Color(0xFFBDBDBD))),
              const SizedBox(width: 10),
              const Icon(
                Icons.directions_car_rounded,
                size: 14,
                color: Color(0xFF424242),
              ),
              const SizedBox(width: 4),
              const Text(
                'Sedan Medium',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Passenger Comment Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 16,
                      color: Color(0xFFC62828),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'PASSENGER COMMENT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC62828),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '“${review.comment}”',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF212121),
                    height: 1.45,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Audit & Regulatory Disclaimer Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'TRIP ID: ${review.tripId}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.copy_rounded,
                          size: 14,
                          color: Color(0xFF757575),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'REVIEW: ${review.id}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF424242),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: Color(0xFF757575),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Driver reviews are published in accordance with Lethbridge Taxi Commission guidelines. Drivers cannot reply to or delete passenger reviews.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF757575),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Report Review Button
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onReport,
              icon: const Icon(
                Icons.flag_outlined,
                color: Color(0xFFC62828),
                size: 18,
              ),
              label: const Text(
                'Report this review',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC62828),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEEEEEE),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Close Button
          TextButton(
            onPressed: onClose,
            child: const Text(
              'Close',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF616161),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
