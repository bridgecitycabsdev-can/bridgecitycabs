import 'package:flutter/material.dart';
import '../../data/models/driver_splash_config.dart';

class DriverBrandLogo extends StatelessWidget {
  final bool showGlow;

  const DriverBrandLogo({
    super.key,
    this.showGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Driver Steering Wheel Logo
        Stack(
          alignment: Alignment.center,
          children: [
            if (showGlow)
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.15),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4.5),
                color: Colors.transparent,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Three spokes of the steering wheel
                  // Horizontal left spoke
                  Positioned(
                    left: 0,
                    right: 55,
                    child: Container(height: 4, color: Colors.white),
                  ),
                  // Horizontal right spoke
                  Positioned(
                    left: 55,
                    right: 0,
                    child: Container(height: 4, color: Colors.white),
                  ),
                  // Bottom vertical spoke
                  Positioned(
                    top: 55,
                    bottom: 0,
                    child: Container(width: 4, color: Colors.white),
                  ),
                  // Top arched support lines
                  Positioned(
                    top: 24,
                    child: Container(
                      width: 52,
                      height: 1.5,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  // Center Hub with Bridge Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFB91C1C),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: CustomPaint(
                            size: const Size(18, 12),
                            painter: _BridgeIconPainter(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Title: Bridge City Cabs
        const Text(
          DriverSplashConfig.appTitle,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),

        // DRIVER Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            DriverSplashConfig.driverBadgeText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Color(0xFFB91C1C),
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Tagline: Drive. Earn. On your schedule.
        const Text(
          DriverSplashConfig.driverTagline,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            letterSpacing: -0.1,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _BridgeIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Bridge deck line
    canvas.drawLine(
      Offset(0, size.height * 0.2),
      Offset(size.width, size.height * 0.2),
      paint,
    );

    // Arch struts
    final path = Path()
      ..moveTo(size.width * 0.1, size.height)
      ..lineTo(size.width * 0.35, size.height * 0.2)
      ..lineTo(size.width * 0.65, size.height * 0.2)
      ..lineTo(size.width * 0.9, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
