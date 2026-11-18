import 'package:flutter/material.dart';

class ChooseRideMap extends StatelessWidget {
  final String statusBadge;
  final VoidCallback? onGpsTap;

  const ChooseRideMap({
    super.key,
    this.statusBadge = 'High Availability',
    this.onGpsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Custom Painted Canvas
        Positioned.fill(
          child: CustomPaint(
            painter: _ChooseRideMapPainter(),
          ),
        ),

        // Route status badge (bottom left of map)
        Positioned(
          bottom: 12,
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
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  statusBadge,
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

        // Floating GPS Reticle (bottom right of map)
        Positioned(
          bottom: 12,
          right: 16,
          child: Material(
            color: Colors.white,
            elevation: 3,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onGpsTap ?? () {},
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.my_location_rounded,
                  color: Color(0xFFB71C1C),
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChooseRideMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Light Map Base
    final bg = Paint()..color = const Color(0xFFE8ECEF);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    // River
    final riverPaint = Paint()
      ..color = const Color(0xFFD4E3ED)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    final river = Path()
      ..moveTo(size.width * 0.15, 0)
      ..cubicTo(
        size.width * 0.28, size.height * 0.35,
        size.width * 0.12, size.height * 0.65,
        size.width * 0.22, size.height,
      );
    canvas.drawPath(river, riverPaint);

    // Grid lines
    final grid = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;

    for (double y = 30; y < size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    for (double x = 30; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }

    // Red Route Line
    final p1 = Offset(size.width * 0.38, size.height * 0.70); // Pickup
    final p2 = Offset(size.width * 0.68, size.height * 0.22); // Park Place

    final routePaint = Paint()
      ..color = const Color(0xFFB71C1C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final route = Path()
      ..moveTo(p1.dx, p1.dy)
      ..cubicTo(
        size.width * 0.40, size.height * 0.45,
        size.width * 0.60, size.height * 0.45,
        p2.dx, p2.dy,
      );
    canvas.drawPath(route, routePaint);

    // Pickup circle
    canvas.drawCircle(p1, 8, Paint()..color = const Color(0xFF10B981));
    canvas.drawCircle(p1, 4, Paint()..color = Colors.white);

    // Dropoff square
    canvas.drawRect(
      Rect.fromCenter(center: p2, width: 14, height: 14),
      Paint()..color = const Color(0xFFB71C1C),
    );
    canvas.drawRect(
      Rect.fromCenter(center: p2, width: 6, height: 6),
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
