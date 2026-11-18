import 'package:flutter/material.dart';

/// Error banner displayed when an incorrect OTP code is entered (Screen 1).
class OtpErrorBanner extends StatelessWidget {
  final String errorMessage;

  const OtpErrorBanner({
    super.key,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFCA5A5),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFB71C1C),
            size: 16,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              errorMessage,
              style: const TextStyle(
                color: Color(0xFF991B1B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
