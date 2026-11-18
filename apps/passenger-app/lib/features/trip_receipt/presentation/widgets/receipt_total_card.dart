import 'package:flutter/material.dart';
import '../../data/models/receipt_fare_breakdown.dart';

class ReceiptTotalCard extends StatelessWidget {
  final ReceiptFareBreakdown fare;
  final bool isCashPending;

  const ReceiptTotalCard({
    super.key,
    required this.fare,
    this.isCashPending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isCashPending ? 'TOTAL DUE' : 'TOTAL PAID',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$${fare.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1F1F1F),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'CAD',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: isCashPending
                  ? const Color(0xFFFEF3C7)
                  : const Color(0xFFE8F8F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCashPending ? Icons.refresh : Icons.check,
                  size: 13,
                  color: isCashPending
                      ? const Color(0xFFB45309)
                      : const Color(0xFF00A86B),
                ),
                const SizedBox(width: 6),
                Text(
                  isCashPending ? 'Payment pending' : 'Payment completed',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isCashPending
                        ? const Color(0xFFB45309)
                        : const Color(0xFF00A86B),
                  ),
                ),
              ],
            ),
          ),

          // Promo Discount Pill (Image 4)
          if (fare.hasDiscount && fare.discountCode != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${fare.discountCode} • \$${fare.discountAmount!.toStringAsFixed(2)} CAD saved',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFC62828),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
