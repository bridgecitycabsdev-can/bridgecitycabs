import 'package:flutter/material.dart';
import '../../data/models/ride_option_tier.dart';

class RideTierSelectionList extends StatelessWidget {
  final List<RideOptionTier> tiers;
  final String selectedTierId;
  final bool isPromoApplied;
  final String? promoCode;
  final ValueChanged<String> onSelectTier;

  const RideTierSelectionList({
    super.key,
    required this.tiers,
    required this.selectedTierId,
    this.isPromoApplied = false,
    this.promoCode,
    required this.onSelectTier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Available Rides',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                'Lethbridge Metrowide',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...tiers.map((tier) => _buildTierCard(context, tier)),
        ],
      ),
    );
  }

  Widget _buildTierCard(BuildContext context, RideOptionTier tier) {
    final bool isSelected = tier.id == selectedTierId;
    final bool hasDiscount = tier.hasDiscount || (isPromoApplied && tier.promoDiscountCad > 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFEF2F2) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF991B1B)
              : const Color(0xFFE5E7EB),
          width: isSelected ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => onSelectTier(tier.id),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Main Tier Row
              Row(
                children: [
                  // Vehicle Thumbnail / Icon
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        tier.icon,
                        size: 28,
                        color: isSelected
                            ? const Color(0xFF991B1B)
                            : const Color(0xFF374151),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title, Seats, ETA & Features
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              tier.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                              ),
                            ),
                            if (tier.badgeLabel != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: tier.badgeLabel == 'RECOMMENDED'
                                      ? const Color(0xFF991B1B)
                                      : const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  tier.badgeLabel!,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    color: tier.badgeLabel == 'RECOMMENDED'
                                        ? Colors.white
                                        : const Color(0xFF374151),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '${tier.etaMinutes} min away',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                            const Text(' · ',
                                style: TextStyle(color: Color(0xFF9CA3AF))),
                            Expanded(
                              child: Text(
                                tier.features,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Pricing Column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (hasDiscount && tier.formattedOriginal != null)
                        Text(
                          tier.formattedOriginal!,
                          style: const TextStyle(
                            fontSize: 11.5,
                            decoration: TextDecoration.lineThrough,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      Text(
                        tier.formattedPriceBare,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: hasDiscount
                              ? const Color(0xFF991B1B)
                              : const Color(0xFF111827),
                        ),
                      ),
                      if (hasDiscount)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '-\$3.00',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        )
                      else
                        const Text(
                          'CAD',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // Expanded In-Card Fare Breakdown (Shown on selected Sedan with discount, Screen 1)
              if (isSelected && hasDiscount) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Column(
                    children: [
                      _buildBreakdownRow('Subtotal', '\$${tier.baseFareCad.toStringAsFixed(2)} CAD'),
                      _buildBreakdownRow(
                        'Promo discount (${promoCode ?? 'WELCOME5'})',
                        '-\$${tier.promoDiscountCad.toStringAsFixed(2)} CAD',
                        textColor: const Color(0xFF059669),
                      ),
                      _buildBreakdownRow('GST (5% Alberta)', '\$${tier.gstCad.toStringAsFixed(2)} CAD'),
                      const Divider(height: 12, color: Color(0xFFF3F4F6)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Fare',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                          Text(
                            tier.formattedTotal,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: textColor ?? const Color(0xFF4B5563),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: textColor ?? const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}
