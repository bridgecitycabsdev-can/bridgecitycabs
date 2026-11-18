import 'package:flutter/material.dart';
import '../../data/models/driver_otp_config.dart';

/// Banner shown when user enters an incorrect OTP code (Image 2).
class DriverIncorrectBanner extends StatelessWidget {
  const DriverIncorrectBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 14,
            color: Color(0xFFDC2626),
          ),
          SizedBox(width: 6),
          Text(
            DriverOtpConfig.incorrectCodeError,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }
}

/// Expired banner and action card shown when code expires (Image 3).
class DriverExpiredCard extends StatelessWidget {
  final VoidCallback onRequestNewCode;

  const DriverExpiredCard({
    super.key,
    required this.onRequestNewCode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Expired notice pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_off_outlined,
                size: 14,
                color: Color(0xFF991B1B),
              ),
              SizedBox(width: 6),
              Text(
                DriverOtpConfig.codeExpiredMessage,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF991B1B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Action card: Request a new code
        GestureDetector(
          onTap: onRequestNewCode,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2).withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFF991B1B),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        DriverOtpConfig.requestNewCodeTitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        DriverOtpConfig.requestNewCodeSubtitle,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF7F1D1D),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF991B1B),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Success Pill: "OTP sent successfully" (Image 4).
class DriverOtpSentSuccessPill extends StatelessWidget {
  const DriverOtpSentSuccessPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 15,
            color: Color(0xFF10B981),
          ),
          SizedBox(width: 6),
          Text(
            DriverOtpConfig.otpSentSuccess,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Submitting notice: "Authenticating with Lethbridge Dispatch..." (Image 5).
class DriverAuthenticatingNotice extends StatelessWidget {
  const DriverAuthenticatingNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 13,
          color: Color(0xFF991B1B),
        ),
        SizedBox(width: 6),
        Text(
          DriverOtpConfig.authenticatingDispatch,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }
}
