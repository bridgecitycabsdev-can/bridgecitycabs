import 'package:flutter/material.dart';
import '../../data/models/driver_splash_config.dart';

/// Modal card displayed in State 4 when an app update is required.
class DriverUpdateModal extends StatelessWidget {
  final VoidCallback onUpdateNow;

  const DriverUpdateModal({
    super.key,
    required this.onUpdateNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Update / Device Download Icon
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFCA5A5).withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.system_update_alt_rounded,
                color: Color(0xFFC91A25),
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Title
          const Text(
            DriverSplashConfig.updateAvailableTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle
          const Text(
            DriverSplashConfig.updateAvailableSubtitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),

          // Red Pill Button: Update now ➔
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onUpdateNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC91A25),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    DriverSplashConfig.updateNowButtonText,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
