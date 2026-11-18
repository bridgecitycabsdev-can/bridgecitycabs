import 'package:flutter/material.dart';
import '../../data/models/promo_code.dart';
import '../../data/models/ride_option_tier.dart';

class SelectedFareBreakdown extends StatelessWidget {
  final RideOptionTier tier;
  final PromoCode? promo;

  const SelectedFareBreakdown({
    super.key,
    required this.tier,
    this.promo,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = promo != null && promo!.isValid;
    final discountAmount = hasDiscount ? promo!.discountAmountCad : 0.0;
    final total = (tier.totalFareCad - discountAmount).clamp(5.0, 999.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFF3F4F6)),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Base Fare & Distance (3.4 km)',
                style: TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                tier.formattedBase,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (hasDiscount) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_offer_outlined, size: 12, color: Color(0xFF10B981)),
                    const SizedBox(width: 4),
                    Text(
                      '${promo!.code} discount',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  '-\$${discountAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'GST (5%)',
                style: TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                tier.formattedGst,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Guaranteed Fare',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)} CAD',
                style: const TextStyle(
                  color: Color(0xFF880E14),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
