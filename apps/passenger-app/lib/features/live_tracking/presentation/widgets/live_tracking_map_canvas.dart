import 'package:flutter/material.dart';
import '../../data/models/tracking_models.dart';

class LiveTrackingMapCanvas extends StatefulWidget {
  final LiveTrackingStatus status;
  final TrackingTripDetails trip;
  final bool isTelemetrySyncing;

  const LiveTrackingMapCanvas({
    super.key,
    required this.status,
    required this.trip,
    this.isTelemetrySyncing = false,
  });

  @override
  State<LiveTrackingMapCanvas> createState() => _LiveTrackingMapCanvasState();
}

class _LiveTrackingMapCanvasState extends State<LiveTrackingMapCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _LiveTrackingMapPainter(
            pulseFraction: _animController.value,
            status: widget.status,
            trip: widget.trip,
            isTelemetrySyncing: widget.isTelemetrySyncing,
          ),
        );
      },
    );
  }
}

class _LiveTrackingMapPainter extends CustomPainter {
  final double pulseFraction;
  final LiveTrackingStatus status;
  final TrackingTripDetails trip;
  final bool isTelemetrySyncing;

  _LiveTrackingMapPainter({
    required this.pulseFraction,
    required this.status,
    required this.trip,
    required this.isTelemetrySyncing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Base Map Background
    final bgPaint = Paint()..color = const Color(0xFFF3F5F7);
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
      Offset(size.width * 0.38, 0),
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
      ..moveTo(size.width * 0.12, 0)
      ..cubicTo(
        size.width * 0.06,
        size.height * 0.22,
        size.width * 0.24,
        size.height * 0.45,
        size.width * 0.16,
        size.height * 0.80,
      );
    canvas.drawPath(riverPath, riverPaint);

    // 4. Pickup & Dropoff Positions
    final pickup = Offset(size.width * 0.45, size.height * 0.24);
    final dropoff = Offset(size.width * 0.75, size.height * 0.12);

    // 5. Route Polyline
    final routePaint = Paint()
      ..color = const Color(0xFFC62828)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routePath = Path()
      ..moveTo(pickup.dx, pickup.dy)
      ..lineTo(pickup.dx + 40, pickup.dy - 35)
      ..lineTo(dropoff.dx, dropoff.dy);

    canvas.drawPath(routePath, routePaint);

    // 6. Draw Pickup marker
    final isTripOngoing = status == LiveTrackingStatus.tripInProgress ||
        status == LiveTrackingStatus.telemetrySyncing ||
        status == LiveTrackingStatus.sosTriggered;

    final pickupPaint = Paint()
      ..color = isTripOngoing ? const Color(0xFF6B7280) : const Color(0xFF00A86B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pickup, 8, pickupPaint);

    final whiteCenter = Paint()..color = Colors.white;
    canvas.drawCircle(pickup, 3, whiteCenter);

    _drawPill(
      canvas: canvas,
      center: Offset(pickup.dx, pickup.dy - 24),
      text: '515 5th Ave S',
      bgColor: Colors.white,
      textColor: const Color(0xFF1F1F1F),
      hasDot: true,
      dotColor: const Color(0xFF00A86B),
      hasShadow: true,
    );

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
      bgColor: Colors.black,
      textColor: Colors.white,
      hasShadow: true,
    );

    // 8. Vehicle Position & Pin
    Offset carPos;
    if (status == LiveTrackingStatus.driverAssigned) {
      carPos = Offset(pickup.dx - 25, pickup.dy + 35);
    } else if (status == LiveTrackingStatus.driverArriving) {
      carPos = Offset(pickup.dx - 10, pickup.dy + 15);
    } else if (status == LiveTrackingStatus.driverArrived) {
      carPos = pickup;
    } else {
      // In progress: position moves along route according to tripProgress
      final prog = trip.tripProgress.clamp(0.1, 0.9);
      carPos = Offset(
        pickup.dx + (dropoff.dx - pickup.dx) * prog,
        pickup.dy + (dropoff.dy - pickup.dy) * prog,
      );
    }

    // Telemetry Syncing pulse ring (Screen 6)
    if (isTelemetrySyncing) {
      final pulsePaint = Paint()
        ..color = const Color(0xFFC62828).withOpacity(0.15)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(carPos, 25 + (pulseFraction * 15), pulsePaint);
    }

    // Car icon circle pin
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(carPos.translate(0, 2), 16, shadowPaint);

    final carCircle = Paint()..color = Colors.black;
    canvas.drawCircle(carPos, 16, carCircle);

    final carIconPaint = Paint()..color = Colors.white;
    // Small roof / body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: carPos, width: 12, height: 8),
        const Radius.circular(2),
      ),
      carIconPaint,
    );

    // Directional or red light beacon
    final beaconPaint = Paint()..color = const Color(0xFFC62828);
    canvas.drawCircle(carPos.translate(0, -5), 2, beaconPaint);
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

    final pillWidth = textPainter.width + (hasDot ? 24 : 16);
    const pillHeight = 22.0;
    final rect = Rect.fromCenter(
      center: center,
      width: pillWidth,
      height: pillHeight,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(11));

    if (hasShadow) {
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawRRect(rrect.shift(const Offset(0, 1.5)), shadowPaint);
    }

    final bgPaint = Paint()..color = bgColor;
    canvas.drawRRect(rrect, bgPaint);

    double textStartX = rect.left + 8;
    if (hasDot) {
      final dotPaint = Paint()..color = dotColor;
      canvas.drawCircle(Offset(rect.left + 8, center.dy), 3, dotPaint);
      textStartX += 8;
    }

    textPainter.paint(
        canvas, Offset(textStartX, center.dy - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _LiveTrackingMapPainter oldDelegate) {
    return oldDelegate.pulseFraction != pulseFraction ||
        oldDelegate.status != status ||
        oldDelegate.trip != trip ||
        oldDelegate.isTelemetrySyncing != isTelemetrySyncing;
  }
}
