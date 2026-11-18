import 'package:flutter/material.dart';
import '../../data/models/payment_card_model.dart';

class PaymentCardTile extends StatelessWidget {
  final PaymentCard card;
  final bool isUpdating;
  final VoidCallback onSelectCard;
  final VoidCallback onRemoveCard;
  final bool showCheckmarkInsteadOfMenu;

  const PaymentCardTile({
    super.key,
    required this.card,
    this.isUpdating = false,
    required this.onSelectCard,
    required this.onRemoveCard,
    this.showCheckmarkInsteadOfMenu = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isUpdating ? null : onSelectCard,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: card.isDefault
                ? const Color(0xFFE2E8F0)
                : const Color(0xFFF1F5F9),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                if (card.isDefault)
                  Container(
                    width: 4,
                    color: const Color(0xFFB91C1C),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        _buildBrandBadge(card.brand),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '•••• ${card.last4}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  if (card.isDefault) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFB91C1C),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Default',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 3),
                              if (isUpdating)
                                const Text(
                                  'Updating default card...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFB91C1C),
                                  ),
                                )
                              else
                                Text(
                                  card.formattedExpiry,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (isUpdating) ...[
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Color(0xFFB91C1C)),
                            ),
                          ),
                        ] else if (showCheckmarkInsteadOfMenu && card.isDefault) ...[
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFB91C1C),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 15,
                              color: Color(0xFFB91C1C),
                            ),
                          ),
                        ] else ...[
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Color(0xFF94A3B8),
                              size: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onSelected: (value) {
                              if (value == 'remove') onRemoveCard();
                              if (value == 'set_default') onSelectCard();
                            },
                            itemBuilder: (context) => [
                              if (!card.isDefault)
                                const PopupMenuItem(
                                  value: 'set_default',
                                  child: Row(
                                    children: [
                                      Icon(Icons.check, size: 18),
                                      SizedBox(width: 8),
                                      Text('Set as default'),
                                    ],
                                  ),
                                ),
                              const PopupMenuItem(
                                value: 'remove',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline,
                                        size: 18, color: Color(0xFFB91C1C)),
                                    SizedBox(width: 8),
                                    Text(
                                      'Remove card',
                                      style: TextStyle(color: Color(0xFFB91C1C)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandBadge(CardBrand brand) {
    return Container(
      width: 48,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      alignment: Alignment.center,
      child: brand == CardBrand.visa
          ? const Text(
              'VISA',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: Color(0xFF1E3A8A),
                letterSpacing: 1,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEA580C),
                    shape: BoxShape.circle,
                  ),
                ),
                Transform.translate(
                  offset: const Offset(-4, 0),
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAB308).withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
