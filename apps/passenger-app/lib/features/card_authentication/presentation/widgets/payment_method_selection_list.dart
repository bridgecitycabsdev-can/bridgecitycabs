import 'package:flutter/material.dart';
import '../../data/models/card_auth_model.dart';

class PaymentMethodSelectionList extends StatelessWidget {
  final List<AuthPaymentMethod> methods;
  final String selectedMethodId;
  final double fareCad;
  final bool isProcessing;
  final ValueChanged<String> onSelectMethod;
  final VoidCallback onAddNewCard;
  final VoidCallback onBookRide;
  final VoidCallback onCancel;

  const PaymentMethodSelectionList({
    super.key,
    required this.methods,
    required this.selectedMethodId,
    required this.fareCad,
    this.isProcessing = false,
    required this.onSelectMethod,
    required this.onAddNewCard,
    required this.onBookRide,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Choose another way to pay',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),

          // Methods List
          ...methods.map((method) => _buildMethodTile(context, method)),

          // Add New Card Tile
          InkWell(
            onTap: onAddNewCard,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.credit_card,
                      size: 20,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '+ Add a new card',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF991B1B),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
          ),

          // Cash Method if not in list
          if (!methods.any((m) => m.isCash))
            _buildMethodTile(
              context,
              const AuthPaymentMethod(
                id: 'pm_cash',
                brand: 'Cash',
                last4: '',
                expiry: '',
                isCash: true,
                subtitle: 'Pay driver directly upon drop-off',
              ),
            ),

          const SizedBox(height: 8),

          // Security footnote
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.lock_outline,
                size: 13,
                color: Color(0xFF9CA3AF),
              ),
              SizedBox(width: 6),
              Text(
                'Cards are processed securely by Stripe • 256-bit encryption',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Book Button
          ElevatedButton(
            onPressed: isProcessing ? null : onBookRide,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF991B1B),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFE5E7EB),
              minimumSize: const Size.fromHeight(50),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Book with selected method \$${fareCad.toStringAsFixed(2)} CAD',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
          ),

          const SizedBox(height: 8),

          // Cancel text button
          TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6B7280),
              minimumSize: const Size.fromHeight(40),
            ),
            child: const Text(
              'Cancel and return to ride options',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodTile(BuildContext context, AuthPaymentMethod method) {
    final bool isSelected = method.id == selectedMethodId;
    final bool isDisabled = method.isDeclined;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDisabled ? const Color(0xFFFAFAFA) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF991B1B)
              : (isDisabled ? const Color(0xFFF3F4F6) : const Color(0xFFE5E7EB)),
          width: isSelected ? 1.8 : 1,
        ),
      ),
      child: InkWell(
        onTap: isDisabled ? null : () => onSelectMethod(method.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDisabled
                      ? const Color(0xFFFEE2E2)
                      : (method.isCash ? const Color(0xFFECFDF5) : const Color(0xFFF3F4F6)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  method.isCash ? Icons.payments_outlined : Icons.credit_card,
                  size: 20,
                  color: isDisabled
                      ? const Color(0xFFDC2626)
                      : (method.isCash ? const Color(0xFF059669) : const Color(0xFF374151)),
                ),
              ),
              const SizedBox(width: 12),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          method.displayTitle,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDisabled
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF111827),
                          ),
                        ),
                        if (method.isBackup) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Backup',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isDisabled
                          ? 'Payment authorization failed'
                          : (method.subtitle ?? (method.isCash ? 'Pay driver directly' : 'Exp ${method.expiry}')),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isDisabled ? FontWeight.w600 : FontWeight.w500,
                        color: isDisabled
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              // Trailing indicator
              if (isDisabled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.cancel,
                        size: 13,
                        color: Color(0xFFDC2626),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Declined',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF991B1B)
                          : const Color(0xFFD1D5DB),
                      width: isSelected ? 6 : 2,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
