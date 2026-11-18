import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class NoDriverTipCard extends StatelessWidget {
  final VoidCallback? onBookDifferentVehicle;

  const NoDriverTipCard({
    super.key,
    this.onBookDifferentVehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFDADA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFFFFE0E0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              size: 16,
              color: Color(0xFFC62828),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF374151),
                  height: 1.35,
                ),
                children: [
                  const TextSpan(
                    text: 'Tip: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFC62828),
                    ),
                  ),
                  const TextSpan(
                    text: 'try again in a few minutes or ',
                  ),
                  TextSpan(
                    text: 'book a different vehicle type.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFC62828),
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = onBookDifferentVehicle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
