import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated road curve with a moving taxi cab and forward headlight glow.
class RoadTaxiAnimation extends StatefulWidget {
  final double height;

  const RoadTaxiAnimation({
    super.key,
    this.height = 140,
  });

  @override
  State<RoadTaxiAnimation> createState() => _RoadTaxiAnimationState();
}

class _RoadTaxiAnimationState extends State<RoadTaxiAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: double.infinity,
          height: widget.height,
          child: CustomPaint(
            painter: _RoadTaxiPainter(progress: _controller.value),
          ),
        );
      },
    );
  }
}

class _RoadTaxiPainter extends CustomPainter {
  final double progress;

  _RoadTaxiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Road track 1: Upper wavy dotted line
    final roadPaint1 = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final dashLength = 12.0;
    final dashGap = 10.0;

    // Evaluate road curve Y at given X
    double getRoadY(double x) {
      return (height * 0.35) +
          math.sin((x / width) * math.pi * 1.6 + 0.4) * (height * 0.18);
    }

    // Lower subtle dashed line
    final roadPaint2 = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    // Draw upper dashed track
    double currentX = -20;
    while (currentX < width + 40) {
      final y1 = getRoadY(currentX);
      final y2 = getRoadY(currentX + dashLength);
      canvas.drawLine(
        Offset(currentX, y1),
        Offset(currentX + dashLength, y2),
        roadPaint1,
      );
      currentX += dashLength + dashGap;
    }

    // Draw lower faint track
    double currentX2 = -20;
    while (currentX2 < width + 40) {
      final y1 = getRoadY(currentX2) + 26;
      final y2 = getRoadY(currentX2 + dashLength) + 26;
      canvas.drawLine(
        Offset(currentX2, y1),
        Offset(currentX2 + dashLength, y2),
        roadPaint2,
      );
      currentX2 += dashLength + dashGap;
    }

    // Calculate Cab Position based on animated progress
    final cabX = -30 + progress * (width + 60);
    final cabY = getRoadY(cabX);

    // Calculate slope/tangent angle of road curve at cabX
    final nextX = cabX + 5;
    final nextY = getRoadY(nextX);
    final angle = math.atan2(nextY - cabY, nextX - cabX);

    canvas.save();
    canvas.translate(cabX, cabY);
    canvas.rotate(angle);

    // Draw Headlight Beam Cone
    final beamPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.28),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(const Rect.fromLTWH(18, -14, 55, 28));

    final beamPath = Path()
      ..moveTo(18, -3)
      ..lineTo(70, -18)
      ..lineTo(70, 18)
      ..lineTo(18, 3)
      ..close();
    canvas.drawPath(beamPath, beamPaint);

    // Draw Taxi Cab Body
    final carPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Main cab chassis
    final chassisRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-16, -9, 32, 18),
      const Radius.circular(5),
    );
    canvas.drawRRect(chassisRect, carPaint);

    // Cab windshield / windows
    final windowPaint = Paint()
      ..color = const Color(0xFF6B0E14)
      ..style = PaintingStyle.fill;

    final windowRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-5, -6, 12, 12),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(windowRect, windowPaint);

    // Roof Taxi Sign
    final signPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final signRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-6, -13, 12, 4.5),
      const Radius.circular(1.5),
    );
    canvas.drawRRect(signRect, signPaint);

    // Tiny wheels
    final wheelPaint = Paint()
      ..color = const Color(0xFF2E0306)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(const Offset(-10, 9), 3, wheelPaint);
    canvas.drawCircle(const Offset(10, 9), 3, wheelPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RoadTaxiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
