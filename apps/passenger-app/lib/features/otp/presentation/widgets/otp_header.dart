import 'package:flutter/material.dart';
import '../../data/models/otp_config.dart';

/// Top App Bar and center emblem header for OTP verification.
class OtpHeader extends StatelessWidget {
  final String maskedPhone;
  final VoidCallback onBack;
  final VoidCallback onEditPhone;
  final bool showEditPhone;

  const OtpHeader({
    super.key,
    required this.maskedPhone,
    required this.onBack,
    required this.onEditPhone,
    this.showEditPhone = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top App Bar: Back arrow + "Bridge City Cabs"
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E1E1E)),
              onPressed: onBack,
            ),
            const Expanded(
              child: Center(
                child: Text(
                  OtpConfig.appTitle,
                  style: TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 48), // Balance back button
          ],
        ),
        const SizedBox(height: 12),

        // Center Brand Emblem
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFB71C1C),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB71C1C).withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.local_taxi_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 8),

        const Text(
          'BRIDGE CITY CABS',
          style: TextStyle(
            color: Color(0xFFB71C1C),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 14),

        // Headline
        const Text(
          OtpConfig.enterOtpTitle,
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 6),

        // Subtitle with masked phone and optional "Edit" link
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 14,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'We sent a code to '),
                TextSpan(
                  text: maskedPhone,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: '. '),
                if (showEditPhone) ...[
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: onEditPhone,
                      child: const Text(
                        OtpConfig.editPhoneText,
                        style: TextStyle(
                          color: Color(0xFFB71C1C),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  const TextSpan(text: 'Please enter the 6-digit code.'),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
