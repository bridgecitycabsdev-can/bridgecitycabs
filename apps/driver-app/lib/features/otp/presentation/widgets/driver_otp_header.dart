import 'package:flutter/material.dart';
import '../../data/models/driver_otp_config.dart';
import '../../data/models/driver_otp_status.dart';

class DriverOtpHeader extends StatelessWidget {
  final DriverOtpStatus status;
  final String maskedPhone;
  final VoidCallback onBack;

  const DriverOtpHeader({
    super.key,
    required this.status,
    required this.maskedPhone,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isSubmitting = status == DriverOtpStatus.submitting;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // App Bar Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Button
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF111827),
                  size: 22,
                ),
              ),
            ),

            // Center Titles
            Column(
              children: const [
                Text(
                  DriverOtpConfig.appTitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: Color(0xFF991B1B),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  DriverOtpConfig.screenTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),

            // Profile Avatar in Red Circle
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF991B1B),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Cab Logo Card
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  isSubmitting
                      ? Icons.album_outlined
                      : Icons.directions_car_rounded,
                  color: const Color(0xFFC91A25),
                  size: 34,
                ),
              ),
            ),

            // Notification red dot for submitting state
            if (isSubmitting)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB91C1C),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

            // Bottom Badge Pill (DRIVER or DRIVER PORTAL)
            Positioned(
              bottom: -10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFB91C1C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isSubmitting
                      ? DriverOtpConfig.driverPortalBadge
                      : DriverOtpConfig.driverBadge,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Enter OTP Title
        const Text(
          DriverOtpConfig.heading,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111827),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),

        // Masked phone message
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
              height: 1.4,
            ),
            children: [
              const TextSpan(text: '${DriverOtpConfig.instructionPrefix} '),
              TextSpan(
                text: maskedPhone,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),
        const SizedBox(height: 2),

        const Text(
          DriverOtpConfig.instructionSuffix,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }
}
