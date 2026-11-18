import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Stylized Lethbridge map background showcasing the Oldman River coulees,
/// street grid, and active booking route lines.
class OnboardingMapBackground extends StatelessWidget {
  final int stepIndex;

  const OnboardingMapBackground({
    super.key,
    required this.stepIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: _MapPainter(stepIndex: stepIndex),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final int stepIndex;

  _MapPainter({required this.stepIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // 1. Base Map Color (Light warm grey)
    final bgPaint = Paint()..color = const Color(0xFFF4F6F2);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);

    // 2. Green Coulee / Park Areas on the west side of Oldman River
    final parkPaint = Paint()
      ..color = const Color(0xFFE2EFE0)
      ..style = PaintingStyle.fill;

    final parkPath = Path()
      ..moveTo(0, 0)
      ..lineTo(width * 0.42, 0)
      ..quadraticBezierTo(width * 0.38, height * 0.35, width * 0.28, height * 0.55)
      ..quadraticBezierTo(width * 0.22, height * 0.75, width * 0.35, height)
      ..lineTo(0, height)
      ..close();
    canvas.drawPath(parkPath, parkPaint);

    // 3. Street Grid Lines (White road arteries and subtle grey borders)
    final streetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Horizontal streets
    for (double y = 40; y < height * 0.65; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(width, y), streetPaint);
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // Vertical streets
    for (double x = 40; x < width; x += 65) {
      canvas.drawLine(Offset(x, 0), Offset(x, height * 0.65), streetPaint);
      canvas.drawLine(Offset(x, 0), Offset(x, height * 0.65), gridPaint);
    }

    // 4. Oldman River (Winding soft blue water channel)
    final riverPaint = Paint()
      ..color = const Color(0xFFD0E6F8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 36
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(width * 0.28, 0)
      ..cubicTo(
        width * 0.22, height * 0.25,
        width * 0.38, height * 0.45,
        width * 0.26, height * 0.70,
      );
    canvas.drawPath(riverPath, riverPaint);

    // 5. High Level Bridge deck over the river
    final bridgeDeck = Paint()
      ..color = const Color(0xFF9E9E9E).withOpacity(0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(width * 0.16, height * 0.21),
      Offset(width * 0.44, height * 0.21),
      bridgeDeck,
    );

    // 6. Step-specific route paths
    if (stepIndex == 0) {
      // Screen 1: Route from ULethbridge across river to Park Place
      _drawRouteStepOne(canvas, width, height);
    } else if (stepIndex == 1) {
      // Screen 2: Route turning along Highway with "In transit" marker
      _drawRouteStepTwo(canvas, width, height);
    } else {
      // Screen 3: Route crossing through security radar
      _drawRouteStepThree(canvas, width, height);
    }
  }

  void _drawRouteStepOne(Canvas canvas, double width, double height) {
    final routePaint = Paint()
      ..color = const Color(0xFFB71C1C)
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(width * 0.12, height * 0.34)
      ..cubicTo(
        width * 0.14, height * 0.22,
        width * 0.46, height * 0.23,
        width * 0.78, height * 0.13,
      );
    canvas.drawPath(path, routePaint);

    // Destination pin: Park Place
    final destGlow = Paint()..color = const Color(0xFF34D399).withOpacity(0.3);
    final destPin = Paint()..color = const Color(0xFF059669);
    final destCenter = Offset(width * 0.78, height * 0.13);

    canvas.drawCircle(destCenter, 13, destGlow);
    canvas.drawCircle(destCenter, 5, destPin);
  }

  void _drawRouteStepTwo(Canvas canvas, double width, double height) {
    final routePaint = Paint()
      ..color = const Color(0xFFB71C1C)
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(width * 0.18, height * 0.37)
      ..lineTo(width * 0.49, height * 0.37)
      ..lineTo(width * 0.49, height * 0.23)
      ..quadraticBezierTo(width * 0.50, height * 0.18, width * 0.64, height * 0.18);
    canvas.drawPath(path, routePaint);

    // Origin dot
    canvas.drawCircle(
      Offset(width * 0.18, height * 0.37),
      7,
      Paint()..color = const Color(0xFF10B981).withOpacity(0.3),
    );
    canvas.drawCircle(
      Offset(width * 0.18, height * 0.37),
      3.5,
      Paint()..color = const Color(0xFF059669),
    );
  }

  void _drawRouteStepThree(Canvas canvas, double width, double height) {
    // Red curved path
    final routePaint = Paint()
      ..color = const Color(0xFFB71C1C)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(width * 0.22, height * 0.42)
      ..quadraticBezierTo(width * 0.45, height * 0.28, width * 0.62, height * 0.15);
    canvas.drawPath(path, routePaint);

    // Subtle safety radar circle
    final radarPaint = Paint()
      ..color = const Color(0xFFE53935).withOpacity(0.08)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(width * 0.5, height * 0.27), 75, radarPaint);

    final radarStroke = Paint()
      ..color = const Color(0xFFE53935).withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(Offset(width * 0.5, height * 0.27), 75, radarStroke);
    canvas.drawCircle(Offset(width * 0.5, height * 0.27), 45, radarStroke);
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) =>
      oldDelegate.stepIndex != stepIndex;
}
