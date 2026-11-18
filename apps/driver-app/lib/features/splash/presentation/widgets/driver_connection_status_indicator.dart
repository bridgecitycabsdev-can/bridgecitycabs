import 'package:flutter/material.dart';
import '../../data/models/driver_splash_config.dart';

class DriverConnectionStatusIndicator extends StatelessWidget {
  final bool isRetrying;

  const DriverConnectionStatusIndicator({
    super.key,
    this.isRetrying = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Thin white circular progress spinner
        const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: 14),

        if (isRetrying) ...[
          // Primary text: Still connecting...
          const Text(
            DriverSplashConfig.stillConnectingText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),

          // Translucent Pill: ● RETRYING LETHBRIDGE HUB
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.28),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '●',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  'RETRYING LETHBRIDGE HUB',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Subtext: Lethbridge, Alberta
        const Text(
          DriverSplashConfig.locationText,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
