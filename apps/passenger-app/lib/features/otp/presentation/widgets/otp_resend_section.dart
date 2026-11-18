import 'package:flutter/material.dart';
import '../bloc/otp_state.dart';
import '../../data/models/otp_config.dart';

/// Handles the resend countdown, resend CTA, and "OTP sent successfully" toast.
class OtpResendSection extends StatelessWidget {
  final OtpState state;
  final VoidCallback onResend;

  const OtpResendSection({
    super.key,
    required this.state,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isExpired) {
      return const SizedBox.shrink();
    }

    final canResend = state.resendTimer.canResend;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (canResend) ...[
          // Resend Code link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Haven't got the code yet? ",
                style: TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: onResend,
                child: const Text(
                  OtpConfig.resendButton,
                  style: TextStyle(
                    color: Color(0xFFB71C1C),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          // Countdown pill (Screen 3) or Subtext countdown (Screen 4)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  color: Color(0xFF4B5563),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'Resend code in ${state.resendTimer.formattedTime}',
                  style: const TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Screen 3: "OTP sent successfully" green toast notification
        if (state is OtpInitialState &&
            (state as OtpInitialState).showSuccessToast) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF10B981),
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  OtpConfig.otpSentSuccess,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
