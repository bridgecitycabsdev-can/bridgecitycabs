import 'package:flutter/material.dart';
import '../../data/models/promo_code.dart';
import '../../data/models/ride_option_tier.dart';
import 'selected_fare_breakdown.dart';

class RideTierCard extends StatelessWidget {
  final RideOptionTier tier;
  final bool isSelected;
  final PromoCode? promo;
  final VoidCallback onTap;

  const RideTierCard({
    super.key,
    required this.tier,
    required this.isSelected,
    this.promo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = tier.isAvailable;
    final hasDiscount = promo != null && promo!.isValid;
    final finalPrice = hasDiscount
        ? (tier.totalFareCad - promo!.discountAmountCad).clamp(5.0, 999.0)
        : tier.totalFareCad;

    return Opacity(
      opacity: isAvailable ? 1.0 : 0.45,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFFB71C1C) : const Color(0xFFF3F4F6),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.06 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: isAvailable ? onTap : null,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Vehicle Icon container
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFFEBEE)
                            : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        tier.icon,
                        color: isSelected
                            ? const Color(0xFFB71C1C)
                            : const Color(0xFF4B5563),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Tier Title, Category Tag, Features, & ETA
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                tier.name,
                                style: const TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  tier.categoryTag,
                                  style: const TextStyle(
                                    color: Color(0xFF4B5563),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          if (isAvailable) ...[
                            Row(
                              children: [
                                if (tier.isFastest) ...[
                                  const Icon(
                                    Icons.near_me_rounded,
                                    size: 11,
                                    color: Color(0xFFB71C1C),
                                  ),
                                  const SizedBox(width: 3),
                                ],
                                Text(
                                  '${tier.etaMinutes} min away • ${tier.features}',
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Text(
                              tier.unavailableReason ?? 'Not available right now',
                              style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Price & GST
                    if (isAvailable) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (hasDiscount || tier.originalFareCad != null) ...[
                            Text(
                              '\$${(tier.originalFareCad ?? tier.totalFareCad).toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 11.5,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                          Text(
                            '\$${finalPrice.toStringAsFixed(2)} CAD',
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF880E14)
                                  : const Color(0xFF111827),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'incl. ${tier.formattedGst} GST',
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const Text(
                        'No cabs near',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Expanded Breakdown if selected
              if (isSelected && isAvailable)
                SelectedFareBreakdown(tier: tier, promo: promo),
            ],
          ),
        ),
      ),
    );
  }
}
