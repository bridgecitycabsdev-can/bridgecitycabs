import 'package:flutter/material.dart';
import '../../data/models/driver_onboarding_step.dart';

class DriverOnboardingMapBackground extends StatelessWidget {
  final DriverOnboardingStep step;

  const DriverOnboardingMapBackground({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _MapGridPainter(step: step),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  final DriverOnboardingStep step;

  _MapGridPainter({required this.step});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Background soft terrain
    final bgPaint = Paint()..color = const Color(0xFFF9FAFB);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Light green park zones
    final parkPaint = Paint()
      ..color = const Color(0xFFE8F5E9).withOpacity(0.55)
      ..style = PaintingStyle.fill;

    final parkPath = Path()
      ..moveTo(size.width * 0.7, 0)
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.15,
        size.width,
        size.height * 0.1,
      )
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(parkPath, parkPaint);

    // Bottom left park curve
    final parkPath2 = Path()
      ..moveTo(0, size.height * 0.3)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.45,
        0,
        size.height * 0.6,
      )
      ..close();
    canvas.drawPath(parkPath2, parkPaint);

    // 3. Oldman River blue curve
    final riverPaint = Paint()
      ..color = const Color(0xFFE0F2FE).withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 36
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(size.width * 0.3, 0)
      ..cubicTo(
        size.width * 0.32,
        size.height * 0.25,
        size.width * 0.25,
        size.height * 0.45,
        size.width * 0.42,
        size.height * 0.8,
      );
    canvas.drawPath(riverPath, riverPaint);

    // 4. City grid street lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const spacing = 58.0;
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 5. Step specific routes
    if (step == DriverOnboardingStep.getRides) {
      // Dashed red route towards car on upper right
      final dashedPaint = Paint()
        ..color = const Color(0xFFDC2626)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;

      const dashWidth = 8.0;
      const dashSpace = 4.0;
      double startX = size.width * 0.62;
      final targetX = size.width * 0.82;
      final y = size.height * 0.145;

      while (startX < targetX) {
        canvas.drawLine(
          Offset(startX, y),
          Offset(startX + dashWidth, y),
          dashedPaint,
        );
        startX += dashWidth + dashSpace;
      }
    } else if (step == DriverOnboardingStep.driveWithConfidence) {
      // Curved red dispatch line
      final routePaint = Paint()
        ..color = const Color(0xFFDC2626)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;

      final routePath = Path()
        ..moveTo(size.width * 0.12, size.height * 0.4)
        ..quadraticBezierTo(
          size.width * 0.35,
          size.height * 0.32,
          size.width * 0.65,
          size.height * 0.23,
        );
      canvas.drawPath(routePath, routePaint);

      // Start circle dot
      final dotPaint = Paint()..color = const Color(0xFFDC2626);
      canvas.drawCircle(
        Offset(size.width * 0.12, size.height * 0.4),
        4.5,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) =>
      oldDelegate.step != step;
}
