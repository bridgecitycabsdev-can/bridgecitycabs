import 'package:flutter/material.dart';
import '../../data/models/no_driver_models.dart';

class NoDriverMapCanvas extends StatefulWidget {
  final NoDriverStatus status;
  final NoDriverBookingDetails booking;

  const NoDriverMapCanvas({
    super.key,
    required this.status,
    required this.booking,
  });

  @override
  State<NoDriverMapCanvas> createState() => _NoDriverMapCanvasState();
}

class _NoDriverMapCanvasState extends State<NoDriverMapCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _NoDriverMapPainter(
            pulseFraction: _pulseController.value,
            status: widget.status,
            booking: widget.booking,
          ),
        );
      },
    );
  }
}

class _NoDriverMapPainter extends CustomPainter {
  final double pulseFraction;
  final NoDriverStatus status;
  final NoDriverBookingDetails booking;

  _NoDriverMapPainter({
    required this.pulseFraction,
    required this.status,
    required this.booking,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Base Map Background
    final bgPaint = Paint()..color = const Color(0xFFF1F5F8);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. City Grid Streets
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final thinRoadPaint = Paint()
      ..color = const Color(0xFFE2E7ED)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (double y = 40; y < size.height; y += 45) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), thinRoadPaint);
    }
    for (double x = 30; x < size.width; x += 55) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), thinRoadPaint);
    }

    // Main arteries
    canvas.drawLine(
      Offset(0, size.height * 0.28),
      Offset(size.width, size.height * 0.28),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.40, 0),
      Offset(size.width * 0.65, size.height),
      roadPaint,
    );

    // 3. Oldman River curve
    final riverPaint = Paint()
      ..color = const Color(0xFFC7E2F0)
      ..strokeWidth = 24
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(size.width * 0.15, 0)
      ..cubicTo(
        size.width * 0.08,
        size.height * 0.22,
        size.width * 0.25,
        size.height * 0.45,
        size.width * 0.18,
        size.height * 0.80,
      );
    canvas.drawPath(riverPath, riverPaint);

    // 4. Pickup Spot Position
    final pickup = Offset(size.width * 0.48, size.height * 0.25);
    final centerPin = Offset(size.width * 0.50, size.height * 0.22);

    // 5. Radar pulse (When retry searching)
    if (status == NoDriverStatus.retrySearching) {
      final pulsePaint = Paint()
        ..color = const Color(0xFFC62828).withOpacity(0.15)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(centerPin, 35 + (pulseFraction * 20), pulsePaint);
      canvas.drawCircle(centerPin, 65 + (pulseFraction * 30), pulsePaint);
    } else if (status == NoDriverStatus.stillNoDriver) {
      // Faint red zone
      final faintPaint = Paint()
        ..color = const Color(0xFFC62828).withOpacity(0.08)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(centerPin, 55, faintPaint);
    }

    // 6. Draw Pickup Pill
    _drawPill(
      canvas: canvas,
      center: Offset(pickup.dx, pickup.dy - 44),
      text: '515 5th Ave S',
      bgColor: Colors.white,
      textColor: const Color(0xFF1F1F1F),
      hasDot: true,
      dotColor: const Color(0xFF00A86B),
      hasShadow: true,
    );

    // 7. Center Car with Question Mark Badge Pin
    _drawNoDriverCarPin(canvas, centerPin);

    // 8. Downtown Core Pill (for Screen 2)
    if (status == NoDriverStatus.stillNoDriver) {
      _drawPill(
        canvas: canvas,
        center: Offset(centerPin.dx, centerPin.dy + 48),
        text: 'Lethbridge Downtown Core',
        bgColor: Colors.white,
        textColor: const Color(0xFF1F1F1F),
        hasDot: true,
        dotColor: const Color(0xFFC62828),
        hasShadow: true,
      );
    }
  }

  void _drawNoDriverCarPin(Canvas canvas, Offset center) {
    // Outer white circular disc with shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center.translate(0, 3), 32, shadowPaint);

    final whiteCircle = Paint()..color = Colors.white;
    canvas.drawCircle(center, 32, whiteCircle);

    final borderPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, 32, borderPaint);

    // Car silhouette / icon
    final carPaint = Paint()
      ..color = status == NoDriverStatus.stillNoDriver ||
              status == NoDriverStatus.retrySearching
          ? const Color(0xFFC62828)
          : const Color(0xFF1F1F1F)
      ..style = PaintingStyle.fill;

    // Body
    final carBody = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, 2), width: 24, height: 14),
      const Radius.circular(3),
    );
    canvas.drawRRect(carBody, carPaint);

    // Roof
    final carRoof = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, -5), width: 15, height: 8),
      const Radius.circular(2),
    );
    canvas.drawRRect(carRoof, carPaint);

    // Red taxi roof light
    final taxiLight = Paint()..color = const Color(0xFFC62828);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center.translate(0, -10), width: 7, height: 3),
        const Radius.circular(1),
      ),
      taxiLight,
    );

    // Headlights
    final lightPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center.translate(-8, 3), 2, lightPaint);
    canvas.drawCircle(center.translate(8, 3), 2, lightPaint);

    // Red Underline bar (Screen 4 Cancelling)
    if (status == NoDriverStatus.cancelling) {
      final barPaint = Paint()
        ..color = const Color(0xFFC62828)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        center.translate(-14, 15),
        center.translate(14, 15),
        barPaint,
      );
    }

    // Red Question Mark Badge attached on top right
    final badgeCenter = center.translate(18, -18);
    final badgeBg = Paint()..color = const Color(0xFFC62828);
    canvas.drawCircle(badgeCenter, 10, badgeBg);

    final textSpan = const TextSpan(
      text: '?',
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w900,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(badgeCenter.dx - textPainter.width / 2,
          badgeCenter.dy - textPainter.height / 2),
    );
  }

  void _drawPill({
    required Canvas canvas,
    required Offset center,
    required String text,
    required Color bgColor,
    required Color textColor,
    bool hasDot = false,
    Color dotColor = Colors.green,
    bool hasShadow = false,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: textColor,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final pillWidth = textPainter.width + (hasDot ? 26 : 18);
    const pillHeight = 24.0;
    final rect = Rect.fromCenter(
      center: center,
      width: pillWidth,
      height: pillHeight,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    if (hasShadow) {
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.09)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawRRect(rrect.shift(const Offset(0, 2)), shadowPaint);
    }

    final bgPaint = Paint()..color = bgColor;
    canvas.drawRRect(rrect, bgPaint);

    double textStartX = rect.left + 9;
    if (hasDot) {
      final dotPaint = Paint()..color = dotColor;
      canvas.drawCircle(Offset(rect.left + 9, center.dy), 3.5, dotPaint);
      textStartX += 9;
    }

    textPainter.paint(
        canvas, Offset(textStartX, center.dy - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _NoDriverMapPainter oldDelegate) {
    return oldDelegate.pulseFraction != pulseFraction ||
        oldDelegate.status != status ||
        oldDelegate.booking != booking;
  }
}
