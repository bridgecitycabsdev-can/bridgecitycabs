import 'package:flutter/material.dart';
import '../../data/models/ride_tier.dart';

/// Interactive ride tier cards and guaranteed upfront fare badge for Onboarding Screen 1.
class RideTierCardsSection extends StatelessWidget {
  final RideTier selectedTier;
  final ValueChanged<RideTier> onTierSelected;

  const RideTierCardsSection({
    super.key,
    required this.selectedTier,
    required this.onTierSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Horizontal list of vehicle tier preview cards
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: RideTier.sampleTiers.map((tier) {
              final isSelected = tier.id == selectedTier.id;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _RideTierItemCard(
                  tier: tier,
                  isSelected: isSelected,
                  onTap: () => onTierSelected(tier),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // Floating Guarantee Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFFB71C1C),
                size: 14,
              ),
              const SizedBox(width: 6),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    const TextSpan(text: 'Guaranteed Upfront Fare • '),
                    TextSpan(
                      text: '${selectedTier.fareText} CAD',
                      style: const TextStyle(
                        color: Color(0xFFB71C1C),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RideTierItemCard extends StatelessWidget {
  final RideTier tier;
  final bool isSelected;
  final VoidCallback onTap;

  const _RideTierItemCard({
    required this.tier,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = 118.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: width,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFF1F2) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFB71C1C)
                    : const Color(0xFFE5E7EB),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isSelected ? 0.08 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tier.name,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF980F1B)
                            : const Color(0xFF1E1E1E),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(
                      _iconForTier(tier.id),
                      color: isSelected
                          ? const Color(0xFFB71C1C)
                          : const Color(0xFF6B7280),
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  tier.seatsText,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (isSelected) ...[
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFB71C1C),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                    Text(
                      tier.etaText,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF980F1B)
                            : const Color(0xFF6B7280),
                        fontSize: 10.5,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      tier.fareText,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF980F1B)
                            : const Color(0xFF1E1E1E),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Text(
                      'CAD',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Optional badge (e.g. "FASTEST")
        if (tier.badge != null)
          Positioned(
            top: -9,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF980F1B),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                tier.badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
    );
  }

  IconData _iconForTier(String id) {
    switch (id) {
      case 'medium':
        return Icons.directions_car_rounded;
      case 'big':
        return Icons.airport_shuttle_rounded;
      case 'premium':
        return Icons.star_rounded;
      default:
        return Icons.local_taxi_rounded;
    }
  }
}
