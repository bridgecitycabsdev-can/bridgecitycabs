import 'package:flutter/material.dart';
import '../../data/models/splash_config.dart';
import 'urgent_contact_box.dart';

/// The white floating card modal shown in Screenshot 3 when network fails.
class ConnectionInterruptedCard extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onCallHotline;
  final String title;
  final String message;

  const ConnectionInterruptedCard({
    super.key,
    required this.onRetry,
    required this.onCallHotline,
    this.title = SplashConfig.errorTitle,
    this.message = SplashConfig.errorSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular Red Wi-Fi Off Icon
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Color(0xFFFDE8E8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              color: Color(0xFFDC2626),
              size: 28,
            ),
          ),
          const SizedBox(height: 18),

          // Title
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1E1E1E),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Primary "Try again" Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                SplashConfig.tryAgainButton,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E1E1E),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Secondary Urgent Cab Hotline Box
          UrgentContactBox(onTap: onCallHotline),
        ],
      ),
    );
  }
}
