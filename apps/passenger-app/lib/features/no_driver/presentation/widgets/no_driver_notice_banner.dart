import 'package:flutter/material.dart';

class NoDriverNoticeBanner extends StatelessWidget {
  final bool isCancellation;
  final String? customMessage;

  const NoDriverNoticeBanner({
    super.key,
    this.isCancellation = false,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isCancellation) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFCDD2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2, right: 10),
              child: Icon(
                Icons.shield_outlined,
                color: Color(0xFFC62828),
                size: 20,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'No cancellation fee applies',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFC62828),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Your payment method was not charged for this request.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4B5563),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Default error/retry failure banner (Screen 2)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFC62828),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              customMessage ??
                  'Still no drivers available. Please try again shortly.',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFC62828),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
