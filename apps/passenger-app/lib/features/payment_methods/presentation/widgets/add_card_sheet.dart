import 'package:flutter/material.dart';
import '../../data/models/payment_card_model.dart';

class AddCardSheet extends StatefulWidget {
  final void Function(CardBrand brand, String last4, String expiry) onCardAdded;

  const AddCardSheet({
    super.key,
    required this.onCardAdded,
  });

  @override
  State<AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<AddCardSheet> {
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  CardBrand _detectedBrand = CardBrand.visa;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _onCardNumberChanged(String value) {
    setState(() {
      if (value.startsWith('5') || value.startsWith('2')) {
        _detectedBrand = CardBrand.mastercard;
      } else if (value.startsWith('3')) {
        _detectedBrand = CardBrand.amex;
      } else {
        _detectedBrand = CardBrand.visa;
      }
    });
  }

  void _submit() {
    final rawNumber = _cardNumberController.text.replaceAll(' ', '');
    final last4 = rawNumber.length >= 4
        ? rawNumber.substring(rawNumber.length - 4)
        : '4242';
    final expiry = _expiryController.text.isNotEmpty
        ? _expiryController.text
        : '12/28';

    widget.onCardAdded(_detectedBrand, last4, expiry);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add New Card',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              onChanged: _onCardNumberChanged,
              decoration: InputDecoration(
                labelText: 'Card Number',
                hintText: '4242 •••• •••• 4242',
                prefixIcon: const Icon(Icons.credit_card),
                suffixText: _detectedBrand.displayName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiryController,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      labelText: 'Expiry (MM/YY)',
                      hintText: '08/28',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      hintText: '•••',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF991B1B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Save Card with Stripe',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
