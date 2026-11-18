import 'package:flutter/material.dart';
import '../../data/models/confirm_trip_config.dart';

class CardDeclinedBanner extends StatelessWidget {
  final VoidCallback onTryAnotherCard;
  final VoidCallback onPayWithCash;

  const CardDeclinedBanner({
    super.key,
    required this.onTryAnotherCard,
    required this.onPayWithCash,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFB71C1C),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.credit_card_off_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      ConfirmTripConfig.cardDeclinedTitle,
                      style: TextStyle(
                        color: Color(0xFF880E14),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      ConfirmTripConfig.cardDeclinedSub,
                      style: TextStyle(
                        color: Color(0xFF4B5563),
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
          const SizedBox(height: 12),

          // Two Action Buttons: Try another card & Pay with cash
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onTryAnotherCard,
                  icon: const Icon(Icons.credit_card_outlined, size: 14),
                  label: const Text(
                    ConfirmTripConfig.tryAnotherCard,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF880E14),
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFFFCDD2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onPayWithCash,
                  icon: const Icon(Icons.payments_outlined, size: 14),
                  label: const Text(
                    ConfirmTripConfig.payWithCash,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF262626),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
