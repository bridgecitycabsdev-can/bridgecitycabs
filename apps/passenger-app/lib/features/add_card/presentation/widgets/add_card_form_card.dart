import 'package:flutter/material.dart';
import '../../data/models/add_card_config.dart';
import '../../data/models/add_card_models.dart';

class AddCardFormCard extends StatelessWidget {
  final CardFormData form;
  final bool isValidating;
  final bool isDeclined;
  final bool isVerificationPending;
  final ValueChanged<String> onCardNumberChanged;
  final ValueChanged<String> onExpiryChanged;
  final ValueChanged<String> onCvcChanged;
  final ValueChanged<String> onPostalCodeChanged;
  final ValueChanged<String> onNameChanged;

  const AddCardFormCard({
    super.key,
    required this.form,
    this.isValidating = false,
    this.isDeclined = false,
    this.isVerificationPending = false,
    required this.onCardNumberChanged,
    required this.onExpiryChanged,
    required this.onCvcChanged,
    required this.onPostalCodeChanged,
    required this.onNameChanged,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = const Color(0xFFE2E8F0);
    if (isValidating) {
      borderColor = const Color(0xFFFECACA);
    } else if (isDeclined) {
      borderColor = const Color(0xFFFCA5A5);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: isValidating ? 1.5 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header Badge
          _buildHeaderBadge(),
          const SizedBox(height: 16),

          // Card Number Field
          const Text(
            'Card number',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDeclined ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.credit_card, size: 20, color: Color(0xFF64748B)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: TextEditingController.fromValue(
                      TextEditingValue(
                        text: form.cardNumber,
                        selection: TextSelection.collapsed(offset: form.cardNumber.length),
                      ),
                    ),
                    onChanged: onCardNumberChanged,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '•••• •••• •••• ••••',
                      hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                if (isVerificationPending)
                  const Icon(Icons.refresh, size: 18, color: Color(0xFFB91C1C))
                else if (form.detectedBrand == CardBrand.visa && form.cardNumber.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'VISA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  )
                else
                  const Icon(Icons.lock_outline, size: 16, color: Color(0xFF94A3B8)),
              ],
            ),
          ),

          if (isDeclined) ...[
            const SizedBox(height: 6),
            const Row(
              children: [
                Icon(Icons.error_outline, size: 14, color: Color(0xFFDC2626)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    AddCardConfig.inFormFieldDeclinedError,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),

          // Expiry and CVC Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Expiry',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: TextEditingController.fromValue(
                          TextEditingValue(
                            text: form.expiry,
                            selection: TextSelection.collapsed(offset: form.expiry.length),
                          ),
                        ),
                        onChanged: onExpiryChanged,
                        keyboardType: TextInputType.datetime,
                        decoration: const InputDecoration(
                          hintText: 'MM / YY',
                          hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CVC / CVV',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: TextEditingController.fromValue(
                                TextEditingValue(
                                  text: form.cvc,
                                  selection: TextSelection.collapsed(offset: form.cvc.length),
                                ),
                              ),
                              onChanged: onCvcChanged,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              decoration: const InputDecoration(
                                hintText: 'CVC',
                                hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const Icon(Icons.help_outline, size: 16, color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Postal Code Field
          const Text(
            'Postal code',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController.fromValue(
                      TextEditingValue(
                        text: form.postalCode,
                        selection: TextSelection.collapsed(offset: form.postalCode.length),
                      ),
                    ),
                    onChanged: onPostalCodeChanged,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      hintText: 'T1K 4A8',
                      hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF94A3B8)),
              ],
            ),
          ),

          // Optional Name on Card Field
          if (isDeclined) ...[
            const SizedBox(height: 14),
            const Text(
              'NAME ON CARD',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: TextEditingController.fromValue(
                  TextEditingValue(
                    text: form.nameOnCard,
                    selection: TextSelection.collapsed(offset: form.nameOnCard.length),
                  ),
                ),
                onChanged: onNameChanged,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderBadge() {
    if (isValidating) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Row(
            children: [
              Icon(Icons.lock, size: 14, color: Color(0xFF991B1B)),
              SizedBox(width: 6),
              Text(
                AddCardConfig.secureCardEntry,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.circle, size: 6, color: Color(0xFFB91C1C)),
              SizedBox(width: 4),
              Text(
                'Validating',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB91C1C),
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (isVerificationPending) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.circle, size: 6, color: Color(0xFFB91C1C)),
              SizedBox(width: 6),
              Text(
                'Verification pending with issuer...',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '3DSecure',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.shield_outlined, size: 16, color: Color(0xFF991B1B)),
            SizedBox(width: 6),
            Text(
              AddCardConfig.stripeElementsSecured,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'stripe',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }
}
