import 'package:flutter/material.dart';
import '../../data/models/home_mode.dart';
import '../../data/models/waypoint.dart';

/// Interactive vector map canvas displaying Lethbridge street grid,
/// user location beacon, multi-stop route polylines, and waypoint markers.
class HomeMapView extends StatelessWidget {
  final HomeMode mode;
  final List<Waypoint> waypoints;
  final VoidCallback onRecenterTapped;

  const HomeMapView({
    super.key,
    required this.mode,
    required this.waypoints,
    required this.onRecenterTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Custom Painted Map Canvas
        Positioned.fill(
          child: CustomPaint(
            painter: _LethbridgeMapPainter(mode: mode, waypoints: waypoints),
          ),
        ),

        // Plan Ride Route stats pill: "🚗 11.4 km • 16 min"
        if (mode == HomeMode.planRide)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.directions_car_rounded, size: 14, color: Color(0xFFB71C1C)),
                  SizedBox(width: 6),
                  Text(
                    '11.4 km • 16 min',
                    style: TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Screen 2 Map Pin: "🔴 Lethbridge Central"
        if (mode == HomeMode.bookRide)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFB71C1C), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB71C1C),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Lethbridge Central',
                    style: TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Floating Recenter / GPS crosshairs button (on bottom right)
        Positioned(
          bottom: mode == HomeMode.planRide ? 60 : 16,
          right: 16,
          child: Material(
            color: Colors.white,
            elevation: 4,
            shadowColor: Colors.black26,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onRecenterTapped,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.my_location_rounded,
                  color: Color(0xFFB71C1C),
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LethbridgeMapPainter extends CustomPainter {
  final HomeMode mode;
  final List<Waypoint> waypoints;

  _LethbridgeMapPainter({
    required this.mode,
    required this.waypoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final isDark = mode == HomeMode.whereTo || mode == HomeMode.readyToRide;

    // Background Map Fill
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF2C3036) : const Color(0xFFF3F4F6);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Oldman River / Coulee Curves
    final riverPaint = Paint()
      ..color = isDark ? const Color(0xFF1F2328) : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(size.width * 0.42, 0)
      ..cubicTo(
        size.width * 0.48, size.height * 0.35,
        size.width * 0.38, size.height * 0.65,
        size.width * 0.45, size.height,
      );
    canvas.drawPath(riverPath, riverPaint);

    // Street Grid lines
    final streetPaint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.08) : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = isDark ? 2.5 : 3.5;

    // Grid coordinates
    for (double y = 40; y < size.height; y += 70) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), streetPaint);
    }
    for (double x = 40; x < size.width; x += 80) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), streetPaint);
    }

    // Specific mode drawings
    if (mode == HomeMode.whereTo) {
      _drawCenterLocationBeacon(canvas, size);
    } else if (mode == HomeMode.readyToRide) {
      _drawTwoPointRoute(canvas, size);
    } else if (mode == HomeMode.planRide) {
      _drawMultiStopRoute(canvas, size);
    }
  }

  void _drawCenterLocationBeacon(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.45);

    // Outer glow aura
    final glowPaint = Paint()
      ..color = const Color(0xFFB71C1C).withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 24, glowPaint);

    // Inner red circle
    final innerPaint = Paint()
      ..color = const Color(0xFFB71C1C)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 12, innerPaint);

    // White dot
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5, dotPaint);
  }

  void _drawTwoPointRoute(Canvas canvas, Size size) {
    final start = Offset(size.width * 0.32, size.height * 0.55);
    final end = Offset(size.width * 0.70, size.height * 0.22);

    // Route curve
    final routePaint = Paint()
      ..color = const Color(0xFFB71C1C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final routePath = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        size.width * 0.55, size.height * 0.45,
        size.width * 0.48, size.height * 0.28,
        end.dx, end.dy,
      );
    canvas.drawPath(routePath, routePaint);

    // Pickup Marker (Downtown Pickup)
    _drawMarkerBadge(canvas, start, 'Downtown Pickup', isPickup: true);

    // Dropoff Marker (Park Place)
    _drawMarkerBadge(canvas, end, 'Park Place', isPickup: false);
  }

  void _drawMultiStopRoute(Canvas canvas, Size size) {
    final p1 = Offset(size.width * 0.18, size.height * 0.55); // U of L
    final p2 = Offset(size.width * 0.48, size.height * 0.42); // Safeway West
    final p3 = Offset(size.width * 0.78, size.height * 0.26); // 4th Ave S

    final routePaint = Paint()
      ..color = const Color(0xFFB71C1C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final routePath = Path()
      ..moveTo(p1.dx, p1.dy)
      ..quadraticBezierTo(size.width * 0.30, size.height * 0.46, p2.dx, p2.dy)
      ..quadraticBezierTo(size.width * 0.62, size.height * 0.35, p3.dx, p3.dy);
    canvas.drawPath(routePath, routePaint);

    // Draw waypoints
    _drawMultiStopPin(canvas, p1, 'U of L', Icons.near_me_rounded);
    _drawMultiStopPin(canvas, p2, 'Safeway West', Icons.storefront_rounded);
    _drawMultiStopPin(canvas, p3, '4th Ave S', Icons.flag_rounded);
  }

  void _drawMarkerBadge(Canvas canvas, Offset offset, String label, {required bool isPickup}) {
    final paint = Paint()..color = const Color(0xFFB71C1C);
    canvas.drawCircle(offset, 10, paint);
    canvas.drawCircle(offset, 5, Paint()..color = Colors.white);
  }

  void _drawMultiStopPin(Canvas canvas, Offset offset, String label, IconData icon) {
    final pinPaint = Paint()..color = const Color(0xFFB71C1C);
    canvas.drawCircle(offset, 11, pinPaint);
    canvas.drawCircle(offset, 6, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _LethbridgeMapPainter oldDelegate) {
    return oldDelegate.mode != mode || oldDelegate.waypoints != waypoints;
  }
}
