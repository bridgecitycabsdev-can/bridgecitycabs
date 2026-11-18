import 'package:flutter/material.dart';
import '../../data/models/driver_auth_config.dart';
import '../../data/models/driver_auth_status.dart';

class DriverAuthHeader extends StatelessWidget {
  final DriverAuthStatus status;

  const DriverAuthHeader({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Pill for Invalid State (Image 3: ● DRIVER)
        if (status == DriverAuthStatus.invalid) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFC91A25),
              borderRadius: BorderRadius.circular(16),
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
                  'DRIVER',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Circular Logo Icon with soft circular background
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFCA5A5).withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      status == DriverAuthStatus.locked
                          ? Icons.local_taxi_rounded
                          : Icons.album_outlined,
                      color: const Color(0xFFC91A25),
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),

            // Verified checkmark badge for Invalid & Locked states
            if (status == DriverAuthStatus.invalid ||
                status == DriverAuthStatus.locked)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFF059669),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),

        // Brand Title
        if (status == DriverAuthStatus.submitting) ...[
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
              children: [
                TextSpan(
                  text: 'BRIDGE CITY ',
                  style: TextStyle(color: Color(0xFF111827)),
                ),
                TextSpan(
                  text: 'CABS',
                  style: TextStyle(color: Color(0xFFC91A25)),
                ),
              ],
            ),
          ),
        ] else ...[
          const Text(
            DriverAuthConfig.appTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
              letterSpacing: -0.5,
            ),
          ),
        ],
        const SizedBox(height: 6),

        // Badge Pill (DRIVER)
        if (status == DriverAuthStatus.submitting) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFC91A25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.directions_car_rounded,
                  color: Colors.white,
                  size: 13,
                ),
                SizedBox(width: 5),
                Text(
                  DriverAuthConfig.driverBadgeText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ] else if (status == DriverAuthStatus.unregistered) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              DriverAuthConfig.driverBadgeText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFF991B1B),
                letterSpacing: 0.8,
              ),
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFC91A25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              DriverAuthConfig.driverBadgeText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],

        // Subtitle (Lethbridge Fleet Dispatch / Operations Portal)
        if (status == DriverAuthStatus.invalid) ...[
          const SizedBox(height: 6),
          const Text(
            DriverAuthConfig.lethbridgeFleetDispatch,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
              letterSpacing: 0.8,
            ),
          ),
        ] else if (status == DriverAuthStatus.locked) ...[
          const SizedBox(height: 6),
          const Text(
            DriverAuthConfig.operationsPortalSubtitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
        const SizedBox(height: 22),

        // Heading: Welcome back, driver
        const Text(
          DriverAuthConfig.welcomeTitle,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111827),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),

        // Subheading
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            DriverAuthConfig.welcomeSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF4B5563),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
