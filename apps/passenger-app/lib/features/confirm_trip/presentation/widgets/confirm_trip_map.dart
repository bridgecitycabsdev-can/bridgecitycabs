import 'package:flutter/material.dart';

class ConfirmTripMap extends StatelessWidget {
  final String routeBadge;
  final String statsText;

  const ConfirmTripMap({
    super.key,
    this.routeBadge = 'Route across Oldman River',
    this.statsText = '4.8 km • 7 min trip',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFE8ECEF),
      ),
      child: Stack(
        children: [
          // Canvas Map Painter
          Positioned.fill(
            child: CustomPaint(
              painter: _ConfirmTripMapPainter(),
            ),
          ),

          // Route badge (top)
          Positioned(
            top: 10,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB71C1C),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    routeBadge,
                    style: const TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stats pill (bottom left)
          Positioned(
            bottom: 10,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_outlined, size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    statsText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmTripMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Map Fill
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFE9EDF0),
    );

    // River
    final riverPaint = Paint()
      ..color = const Color(0xFFD6E4EE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26
      ..strokeCap = StrokeCap.round;

    final river = Path()
      ..moveTo(size.width * 0.22, 0)
      ..cubicTo(
        size.width * 0.35, size.height * 0.4,
        size.width * 0.18, size.height * 0.7,
        size.width * 0.25, size.height,
      );
    canvas.drawPath(river, riverPaint);

    // Street lines
    final streetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;

    for (double y = 20; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), streetPaint);
    }
    for (double x = 30; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), streetPaint);
    }

    // Route Red Polyline
    final p1 = Offset(size.width * 0.18, size.height * 0.80); // Pickup
    final p2 = Offset(size.width * 0.78, size.height * 0.25); // Park Place

    final routePaint = Paint()
      ..color = const Color(0xFFB71C1C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final route = Path()
      ..moveTo(p1.dx, p1.dy)
      ..cubicTo(
        size.width * 0.40, size.height * 0.65,
        size.width * 0.55, size.height * 0.35,
        p2.dx, p2.dy,
      );
    canvas.drawPath(route, routePaint);

    // Markers
    canvas.drawCircle(p1, 7, Paint()..color = const Color(0xFF10B981));
    canvas.drawCircle(p1, 3.5, Paint()..color = Colors.white);

    canvas.drawRect(
      Rect.fromCenter(center: p2, width: 12, height: 12),
      Paint()..color = const Color(0xFFB71C1C),
    );
    canvas.drawRect(
      Rect.fromCenter(center: p2, width: 5, height: 5),
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
