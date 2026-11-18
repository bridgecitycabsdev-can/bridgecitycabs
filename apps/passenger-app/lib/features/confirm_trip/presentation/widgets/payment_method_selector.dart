import 'package:flutter/material.dart';
import '../../data/models/confirm_trip_config.dart';
import '../../data/models/payment_method_info.dart';

class PaymentMethodSelector extends StatelessWidget {
  final PaymentMethodInfo payment;
  final ValueChanged<PaymentType> onTypeChanged;
  final VoidCallback onAddCard;
  final VoidCallback onSelectCash;

  const PaymentMethodSelector({
    super.key,
    required this.payment,
    required this.onTypeChanged,
    required this.onAddCard,
    required this.onSelectCash,
  });

  @override
  Widget build(BuildContext context) {
    final isCash = payment.isCash;
    final isDeclined = payment.isDeclined;
    final isUnlinked = payment.isCard && !payment.isLinked;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              ConfirmTripConfig.paymentSectionTitle,
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              isUnlinked
                  ? 'Required before booking'
                  : ConfirmTripConfig.selectPaymentMethod,
              style: TextStyle(
                color: isUnlinked ? const Color(0xFFB71C1C) : const Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: isUnlinked ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Segmented Tabs: Cash / Card
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => onTypeChanged(PaymentType.cash),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: isCash ? const Color(0xFFB71C1C) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          size: 16,
                          color: isCash ? Colors.white : const Color(0xFF4B5563),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Cash',
                          style: TextStyle(
                            color: isCash ? Colors.white : const Color(0xFF4B5563),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => onTypeChanged(PaymentType.card),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: !isCash ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: !isCash
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.credit_card_outlined,
                          size: 16,
                          color: !isCash ? const Color(0xFFB71C1C) : const Color(0xFF4B5563),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Card',
                          style: TextStyle(
                            color: !isCash ? const Color(0xFF1E1E1E) : const Color(0xFF4B5563),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Tab Content
        if (isCash) ...[
          // Cash notice container
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7F7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFCDD2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.attach_money_rounded, color: Color(0xFFB71C1C), size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        ConfirmTripConfig.payDriverAtDestination,
                        style: TextStyle(
                          color: Color(0xFF1E1E1E),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        ConfirmTripConfig.cashNotice,
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ] else if (isDeclined) ...[
          // Card declined error container
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFB71C1C)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.credit_card_off_rounded, color: Color(0xFFB71C1C), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Visa ending in ${payment.cardLast4 ?? "4242"}',
                          style: const TextStyle(
                            color: Color(0xFF1E1E1E),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB71C1C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Declined by bank',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  payment.declinedReason ?? 'Card was declined.',
                  style: const TextStyle(
                    color: Color(0xFFB71C1C),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ActionChip(
                      label: const Text('Google Pay'),
                      avatar: const Icon(Icons.account_balance_wallet_outlined, size: 14),
                      onPressed: onAddCard,
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      label: const Text('Cash on arrival'),
                      avatar: const Icon(Icons.payments_outlined, size: 14),
                      onPressed: onSelectCash,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else if (isUnlinked) ...[
          // Missing card placeholder
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7F7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFCDD2), style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                const Icon(Icons.credit_card_outlined, color: Color(0xFFB71C1C), size: 28),
                const SizedBox(height: 8),
                const Text(
                  '+ Add a card',
                  style: TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Add a credit or debit card to continue',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onAddCard,
                  icon: const Icon(Icons.add_rounded, size: 16, color: Color(0xFFB71C1C)),
                  label: const Text(
                    '+ Link Visa / Mastercard',
                    style: TextStyle(
                      color: Color(0xFFB71C1C),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFFCDD2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Linked Card Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Row(
              children: [
                const Icon(Icons.credit_card_rounded, color: Color(0xFFB71C1C), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '•••• ${payment.cardLast4 ?? "4242"}',
                            style: const TextStyle(
                              color: Color(0xFF1E1E1E),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Default',
                              style: TextStyle(
                                color: Color(0xFF4B5563),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (payment.expiry != null)
                        Text(
                          'Expires ${payment.expiry!}',
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: onAddCard,
                  child: const Text(
                    'Change',
                    style: TextStyle(
                      color: Color(0xFFB71C1C),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
