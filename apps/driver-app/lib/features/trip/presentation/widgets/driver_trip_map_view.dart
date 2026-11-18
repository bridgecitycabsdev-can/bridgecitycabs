import 'package:flutter/material.dart';
import '../../data/models/driver_trip_model.dart';
import '../../data/models/driver_trip_status.dart';

class DriverTripMapView extends StatelessWidget {
  final DriverTripStatus status;
  final DriverTripModel trip;

  const DriverTripMapView({
    super.key,
    required this.status,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    final isWaiting = status == DriverTripStatus.waitingForPassenger;

    return Stack(
      children: [
        // Map illustration canvas
        Positioned.fill(
          child: CustomPaint(
            painter: _TripMapPainter(isWaiting: isWaiting),
          ),
        ),

        // Coulee Crossing route corridor banner (Screenshot 1)
        if (status == DriverTripStatus.onTrip)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.landscape_outlined,
                      color: Color(0xFF047857),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      trip.corridorTitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Turn guidance pill (bottom left of map)
        if (!isWaiting && status != DriverTripStatus.onTrip)
          Positioned(
            left: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.turn_right_rounded,
                    color: Color(0xFF10B981),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    trip.nextTurnGuidance,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Speedometer pill (bottom right of map)
        if (!isWaiting && trip.currentSpeedKmh > 0)
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.speed,
                    color: Color(0xFFBA0C2F),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${trip.currentSpeedKmh} km/h',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _TripMapPainter extends CustomPainter {
  final bool isWaiting;

  _TripMapPainter({required this.isWaiting});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = const Color(0xFFE5EDE8);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // River (Oldman River)
    final riverPaint = Paint()
      ..color = const Color(0xFFBCE0EF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(size.width * 0.45, 0)
      ..cubicTo(
        size.width * 0.35,
        size.height * 0.25,
        size.width * 0.25,
        size.height * 0.45,
        size.width * 0.15,
        size.height,
      );
    canvas.drawPath(riverPath, riverPaint);

    // Minor streets grid
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 4;

    canvas.drawLine(
      Offset(0, size.height * 0.2),
      Offset(size.width, size.height * 0.2),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.6),
      Offset(size.width, size.height * 0.6),
      gridPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.25, 0),
      Offset(size.width * 0.25, size.height),
      gridPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.65, 0),
      Offset(size.width * 0.65, size.height),
      gridPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.85, 0),
      Offset(size.width * 0.85, size.height),
      gridPaint,
    );

    // Highway 3 / Whoop-Up Drive
    final highwayPaint = Paint()
      ..color = const Color(0xFFD6DBE1)
      ..strokeWidth = 14;
    canvas.drawLine(
      Offset(0, size.height * 0.45),
      Offset(size.width, size.height * 0.35),
      highwayPaint,
    );

    // Labels for streets
    _drawText(canvas, 'WHOOP-UP DR', Offset(size.width * 0.05, size.height * 0.46));
    _drawText(canvas, 'UNIVERSITY DR', Offset(size.width * 0.35, size.height * 0.12));
    _drawText(canvas, 'SCENIC DR S', Offset(size.width * 0.72, size.height * 0.38));
    _drawText(canvas, 'Lethbridge Viaduct', Offset(size.width * 0.18, size.height * 0.28));

    if (isWaiting) {
      // Arrived & Parked: Draw concentric green radar circles
      final center = Offset(size.width * 0.52, size.height * 0.42);

      // Radar rings
      final ringPaint1 = Paint()
        ..color = const Color(0xFF10B981).withValues(alpha: 0.15)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 90, ringPaint1);

      final ringPaint2 = Paint()
        ..color = const Color(0xFF10B981).withValues(alpha: 0.25)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 60, ringPaint2);

      final ringPaint3 = Paint()
        ..color = const Color(0xFF10B981).withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 35, ringPaint3);

      // Pickup Pin
      final pinPaint = Paint()..color = const Color(0xFF2E7D32);
      canvas.drawCircle(center, 12, pinPaint);
      final innerPin = Paint()..color = Colors.white;
      canvas.drawCircle(center, 5, innerPin);

      // Red Parked badge
      final parkedPaint = Paint()..color = const Color(0xFFBA0C2F);
      final parkedRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - 35),
          width: 60,
          height: 22,
        ),
        const Radius.circular(11),
      );
      canvas.drawRRect(parkedRect, parkedPaint);
      _drawCenteredText(
        canvas,
        'Parked',
        Offset(center.dx, center.dy - 35),
        Colors.white,
      );
    } else {
      // Heading to pickup: Red route line
      final routePath = Path()
        ..moveTo(size.width * 0.25, size.height * 0.44)
        ..cubicTo(
          size.width * 0.38,
          size.height * 0.40,
          size.width * 0.55,
          size.height * 0.28,
          size.width * 0.72,
          size.height * 0.22,
        );

      final routeOutline = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(routePath, routeOutline);

      final routeRed = Paint()
        ..color = const Color(0xFFBA0C2F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(routePath, routeRed);

      // Vehicle marker circle (Cab #42)
      final markerCenter = Offset(size.width * 0.25, size.height * 0.44);
      final pulsePaint = Paint()
        ..color = const Color(0xFFBA0C2F).withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(markerCenter, 22, pulsePaint);

      final vehiclePaint = Paint()..color = const Color(0xFFBA0C2F);
      canvas.drawCircle(markerCenter, 13, vehiclePaint);
      final innerWhite = Paint()..color = Colors.white;
      canvas.drawCircle(markerCenter, 10, innerWhite);
      final innerRed = Paint()..color = const Color(0xFFBA0C2F);
      canvas.drawCircle(markerCenter, 6, innerRed);

      // Destination pickup dot
      final destCenter = Offset(size.width * 0.72, size.height * 0.22);
      final destOuter = Paint()..color = const Color(0xFF10B981);
      canvas.drawCircle(destCenter, 9, destOuter);
      final destInner = Paint()..color = Colors.white;
      canvas.drawCircle(destCenter, 4, destInner);
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset) {
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 9,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, offset);
  }

  void _drawCenteredText(
    Canvas canvas,
    String text,
    Offset center,
    Color color,
  ) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - (textPainter.width / 2),
          center.dy - (textPainter.height / 2)),
    );
  }

  @override
  bool shouldRepaint(covariant _TripMapPainter oldDelegate) =>
      oldDelegate.isWaiting != isWaiting;
}
