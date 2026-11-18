import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../data/models/driver_search_models.dart';

class SearchingMapCanvas extends StatefulWidget {
  final SearchingDriverStatus status;
  final bool isReconnecting;
  final SearchBookingDetails booking;

  const SearchingMapCanvas({
    super.key,
    required this.status,
    this.isReconnecting = false,
    required this.booking,
  });

  @override
  State<SearchingMapCanvas> createState() => _SearchingMapCanvasState();
}

class _SearchingMapCanvasState extends State<SearchingMapCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
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
          painter: _SearchingMapPainter(
            pulseFraction: _pulseController.value,
            status: widget.status,
            isReconnecting: widget.isReconnecting,
            booking: widget.booking,
          ),
        );
      },
    );
  }
}

class _SearchingMapPainter extends CustomPainter {
  final double pulseFraction;
  final SearchingDriverStatus status;
  final bool isReconnecting;
  final SearchBookingDetails booking;

  _SearchingMapPainter({
    required this.pulseFraction,
    required this.status,
    required this.isReconnecting,
    required this.booking,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Map base background
    final bgPaint = Paint()..color = const Color(0xFFF3F5F7);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. City street grid lines
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final thinRoadPaint = Paint()
      ..color = const Color(0xFFE5E9EE)
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
      Offset(size.width * 0.42, 0),
      Offset(size.width * 0.65, size.height),
      roadPaint,
    );

    // 3. Oldman River curve
    final riverPaint = Paint()
      ..color = const Color(0xFFC7E2F0)
      ..strokeWidth = 26
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(size.width * 0.12, 0)
      ..cubicTo(
        size.width * 0.05,
        size.height * 0.2,
        size.width * 0.22,
        size.height * 0.45,
        size.width * 0.15,
        size.height * 0.75,
      );
    canvas.drawPath(riverPath, riverPaint);

    // 4. Pickup & Dropoff positions
    final pickup = Offset(size.width * 0.50, size.height * 0.24);
    final dropoff = Offset(size.width * 0.70, size.height * 0.12);

    // 5. Route Polyline
    final routePaint = Paint()
      ..color = const Color(0xFFC62828)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routePath = Path()
      ..moveTo(pickup.dx, pickup.dy)
      ..lineTo(pickup.dx + 40, pickup.dy - 30)
      ..lineTo(dropoff.dx, dropoff.dy);

    canvas.drawPath(routePath, routePaint);

    // 6. Draw Radar Pulse on Pickup
    if (status == SearchingDriverStatus.driverFound) {
      // Green radar / pulse
      final greenPaint = Paint()
        ..color = const Color(0xFF00A86B).withOpacity(0.18)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pickup, 45 + (pulseFraction * 20), greenPaint);

      final greenTarget = Paint()
        ..color = const Color(0xFF00A86B)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pickup, 18, greenTarget);

      final innerWhite = Paint()..color = Colors.white;
      canvas.drawCircle(pickup, 5, innerWhite);

      _drawPill(
        canvas: canvas,
        center: Offset(pickup.dx, pickup.dy + 34),
        text: '• Pickup Confirmed',
        bgColor: const Color(0xFF1F1F1F),
        textColor: Colors.white,
      );
    } else if (isReconnecting) {
      // Reconnecting red disconnected pin
      final pulsePaint = Paint()
        ..color = const Color(0xFFC62828).withOpacity(0.12)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pickup, 35 + (pulseFraction * 18), pulsePaint);
      canvas.drawCircle(pickup, 65 + (pulseFraction * 25), pulsePaint);

      final redPin = Paint()
        ..color = const Color(0xFFC62828)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pickup, 16, redPin);

      _drawPill(
        canvas: canvas,
        center: Offset(pickup.dx, pickup.dy - 32),
        text: 'Downtown Lethbridge',
        bgColor: Colors.white,
        textColor: const Color(0xFF1F1F1F),
        hasShadow: true,
      );
    } else {
      // Default searching concentric radar rings
      final ringPaint = Paint()
        ..color = const Color(0xFFC62828).withOpacity(0.14)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(pickup, 24 + (pulseFraction * 20), ringPaint);
      canvas.drawCircle(pickup, 48 + (pulseFraction * 25), ringPaint);
      canvas.drawCircle(pickup, 76 + (pulseFraction * 30), ringPaint);

      // Center red dot
      final centerPin = Paint()
        ..color = const Color(0xFFC62828)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pickup, 9, centerPin);

      _drawPill(
        canvas: canvas,
        center: Offset(pickup.dx, pickup.dy - 28),
        text: '515 5th Ave S, Downtown',
        bgColor: Colors.white,
        textColor: const Color(0xFF1F1F1F),
        hasDot: true,
        dotColor: const Color(0xFF00A86B),
        hasShadow: true,
      );
    }

    // 7. Dropoff marker
    final dropoffBg = Paint()..color = const Color(0xFFC62828);
    canvas.drawRect(
      Rect.fromCenter(center: dropoff, width: 14, height: 14),
      dropoffBg,
    );

    _drawPill(
      canvas: canvas,
      center: Offset(dropoff.dx, dropoff.dy - 22),
      text: 'Park Place Mall',
      bgColor: Colors.white,
      textColor: const Color(0xFF1F1F1F),
      hasDot: true,
      dotColor: const Color(0xFFC62828),
      hasShadow: true,
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
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final pillWidth = textPainter.width + (hasDot ? 26 : 18);
    final pillHeight = 22.0;
    final rect = Rect.fromCenter(
      center: center,
      width: pillWidth,
      height: pillHeight,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    if (hasShadow) {
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawRRect(rrect.shift(const Offset(0, 1.5)), shadowPaint);
    }

    final bgPaint = Paint()..color = bgColor;
    canvas.drawRRect(rrect, bgPaint);

    double textStartX = rect.left + 9;
    if (hasDot) {
      final dotPaint = Paint()..color = dotColor;
      canvas.drawCircle(Offset(rect.left + 9, center.dy), 3, dotPaint);
      textStartX += 8;
    }

    textPainter.paint(canvas, Offset(textStartX, center.dy - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _SearchingMapPainter oldDelegate) {
    return oldDelegate.pulseFraction != pulseFraction ||
        oldDelegate.status != status ||
        oldDelegate.isReconnecting != isReconnecting ||
        oldDelegate.booking != booking;
  }
}
