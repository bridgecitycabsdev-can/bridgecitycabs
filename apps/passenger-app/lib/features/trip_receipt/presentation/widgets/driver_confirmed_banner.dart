import 'package:flutter/material.dart';

class DriverConfirmedBanner extends StatelessWidget {
  final double amount;

  const DriverConfirmedBanner({
    super.key,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC7EBD8)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFC7EBD8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: Color(0xFF00A86B),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Driver confirmed cash received (\$${amount.toStringAsFixed(2)} CAD)',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E3A2F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
