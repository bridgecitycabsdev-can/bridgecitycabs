import 'package:flutter/material.dart';

class PaymentAccountRow extends StatelessWidget {
  final String accountLabel;
  final String? subtitle;
  final VoidCallback? onChange;
  final bool showCityRegulatedNotice;

  const PaymentAccountRow({
    super.key,
    required this.accountLabel,
    this.subtitle,
    this.onChange,
    this.showCityRegulatedNotice = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.credit_card,
              size: 18,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accountLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showCityRegulatedNotice)
            Row(
              children: const [
                Icon(Icons.verified_outlined, size: 14, color: Color(0xFF059669)),
                SizedBox(width: 4),
                Text(
                  'Lethbridge City Regulated',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF059669),
                  ),
                ),
              ],
            )
          else if (onChange != null)
            TextButton(
              onPressed: onChange,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF991B1B),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Change',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}
