import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../data/models/splash_config.dart';

/// Top header containing the Bridge City Cabs steering wheel emblem,
/// brand name, and tagline.
class SplashHeader extends StatelessWidget {
  const SplashHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Small white dot above the emblem
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),

        // Custom Steering Wheel Logo with Bridge emblem
        const _SteeringWheelLogo(size: 92),
        const SizedBox(height: 24),

        // Brand Title
        const Text(
          SplashConfig.appName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Subtitle / Tagline
        Text(
          SplashConfig.appTagline,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Custom painter for the Bridge City Cabs emblem:
/// Steering wheel with circular rim, three spokes, center hub,
/// and stylized Lethbridge truss bridge silhouette inside.
class _SteeringWheelLogo extends StatelessWidget {
  final double size;

  const _SteeringWheelLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SteeringWheelPainter(),
      ),
    );
  }
}

class _SteeringWheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer rim stroke
    final rimPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.085;
    canvas.drawCircle(center, radius - (rimPaint.strokeWidth / 2), rimPaint);

    // Inner hub stroke
    final hubRadius = size.width * 0.22;
    final hubPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.045;
    canvas.drawCircle(center, hubRadius, hubPaint);

    // Three spokes (Left, Right, Down)
    final spokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.07
      ..strokeCap = StrokeCap.round;

    final spokeInnerRadius = hubRadius + (hubPaint.strokeWidth / 2);
    final spokeOuterRadius = radius - rimPaint.strokeWidth;

    // Horizontal left spoke
    canvas.drawLine(
      Offset(center.dx - spokeInnerRadius, center.dy),
      Offset(center.dx - spokeOuterRadius, center.dy),
      spokePaint,
    );

    // Horizontal right spoke
    canvas.drawLine(
      Offset(center.dx + spokeInnerRadius, center.dy),
      Offset(center.dx + spokeOuterRadius, center.dy),
      spokePaint,
    );

    // Vertical downward spoke
    canvas.drawLine(
      Offset(center.dx, center.dy + spokeInnerRadius),
      Offset(center.dx, center.dy + spokeOuterRadius),
      spokePaint,
    );

    // Stylized Bridge inside the center hub
    final bridgePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.035
      ..strokeCap = StrokeCap.round;

    final bridgeFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Bridge deck line
    final deckY = center.dy - (size.height * 0.02);
    final deckWidth = hubRadius * 1.1;
    canvas.drawLine(
      Offset(center.dx - deckWidth / 2, deckY),
      Offset(center.dx + deckWidth / 2, deckY),
      bridgePaint,
    );

    // Bridge truss arch
    final trussPath = Path()
      ..moveTo(center.dx - deckWidth / 2, deckY)
      ..lineTo(center.dx, center.dy - (hubRadius * 0.65))
      ..lineTo(center.dx + deckWidth / 2, deckY);
    canvas.drawPath(trussPath, bridgePaint);

    // Small bridge vertical support pillars
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx - (deckWidth * 0.3), deckY + 4),
        width: 2.5,
        height: 6,
      ),
      bridgeFill,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx + (deckWidth * 0.3), deckY + 4),
        width: 2.5,
        height: 6,
      ),
      bridgeFill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
