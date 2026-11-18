import 'package:flutter/material.dart';
import '../../data/models/card_auth_model.dart';

class BankWaitingChallengeSheet extends StatelessWidget {
  final AuthPaymentMethod card;
  final double fareCad;

  const BankWaitingChallengeSheet({
    super.key,
    required this.card,
    required this.fareCad,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Pulsing Red Outline with Lock Icon
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFB91C1C),
                width: 2.5,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.lock_outline,
                size: 28,
                color: Color(0xFFB91C1C),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Title & Subtitle
          const Text(
            'Waiting for your bank...',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Authorizing \$${fareCad.toStringAsFixed(2)} CAD with ${card.brand} •••• ${card.last4}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 20),

          // Security Challenge Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.verified_user_outlined, size: 14, color: Color(0xFF991B1B)),
                        SizedBox(width: 6),
                        Text(
                          'Verified by Visa',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Secured by Stripe',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Authentication Challenge',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    Text(
                      'In progress',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB91C1C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    minHeight: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB91C1C)),
                    backgroundColor: Color(0xFFE5E7EB),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Fingerprint approval note
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.touch_app_outlined, size: 18, color: Color(0xFF6B7280)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Approve the challenge in your banking app if prompted',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF4B5563),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
