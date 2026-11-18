import 'package:flutter/material.dart';
import '../../data/models/driver_payment_split.dart';

class DriverEarningsSplitCard extends StatelessWidget {
  final DriverPaymentSplit split;

  const DriverEarningsSplitCard({
    super.key,
    required this.split,
  });

  @override
  Widget build(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Payment Split',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              Text(
                '${split.totalTrips} Trips',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF757575),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Dual segmented bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(
                    flex: split.cashPercent,
                    child: Container(
                      color: const Color(0xFF2B2D2F),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: split.cardPercent,
                    child: Container(
                      color: const Color(0xFFD32F2F),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Legend
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF2B2D2F),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Cash: \$${split.cashAmount.toStringAsFixed(2)} (${split.cashPercent}%)',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFD32F2F),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Card: \$${split.cardAmount.toStringAsFixed(2)} (${split.cardPercent}%)',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD32F2F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Advisory box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F7F7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF0EBEB),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Color(0xFF8C2020),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    split.advisoryText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6E5555),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
