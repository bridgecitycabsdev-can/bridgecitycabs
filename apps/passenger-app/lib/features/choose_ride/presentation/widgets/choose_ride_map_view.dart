import 'package:flutter/material.dart';

class ChooseRideMapView extends StatelessWidget {
  final String routeText;
  final String? routeAreaLabel;
  final String? distanceText;
  final bool isInspectorMode;

  const ChooseRideMapView({
    super.key,
    required this.routeText,
    this.routeAreaLabel,
    this.distanceText,
    this.isInspectorMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      color: const Color(0xFFE8F0FE),
      child: Stack(
        children: [
          // Simulated Map Terrain Painter
          CustomPaint(
            size: const Size(double.infinity, 180),
            painter: _LethbridgeMapPainter(),
          ),

          // Area names
          const Positioned(
            left: 20,
            top: 24,
            child: Text(
              'McDermott',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
          const Positioned(
            right: 40,
            top: 20,
            child: Text(
              'Hardieville · Legacy Ridge',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),

          // Route Area Warning or Label Pill
          if (routeAreaLabel != null)
            Positioned(
              left: 14,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 11, color: Color(0xFFB45309)),
                    const SizedBox(width: 4),
                    Text(
                      routeAreaLabel!,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Route Pill
          Positioned(
            right: 14,
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD1D5DB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.circle, size: 7, color: Color(0xFFDC2626)),
                  const SizedBox(width: 6),
                  Text(
                    routeText,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  if (distanceText != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      '· $distanceText',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Right floating action buttons (Compass / Shield)
          Positioned(
            right: 14,
            bottom: 12,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.my_location,
                      size: 16, color: Color(0xFF374151)),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_outlined,
                    size: 16, color: Color(0xFF991B1B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LethbridgeMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Oldman River curve
    final riverPaint = Paint()
      ..color = const Color(0xFF93C5FD).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(size.width * 0.42, 0)
      ..cubicTo(
        size.width * 0.38,
        size.height * 0.45,
        size.width * 0.48,
        size.height * 0.65,
        size.width * 0.45,
        size.height,
      );
    canvas.drawPath(riverPath, riverPaint);

    // Lethbridge Viaduct trestle bridges
    final trestlePaint = Paint()
      ..color = const Color(0xFF9CA3AF).withOpacity(0.5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final yCenter = size.height * 0.48;
    for (double x = size.width * 0.2; x <= size.width * 0.7; x += 16) {
      canvas.drawLine(Offset(x, yCenter - 10), Offset(x, yCenter + 14), trestlePaint);
    }
    canvas.drawLine(
      Offset(size.width * 0.2, yCenter - 10),
      Offset(size.width * 0.7, yCenter - 10),
      trestlePaint,
    );

    // Red Route Line
    final routePaint = Paint()
      ..color = const Color(0xFFDC2626)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final routePath = Path()
      ..moveTo(size.width * 0.14, size.height * 0.62)
      ..cubicTo(
        size.width * 0.4,
        size.height * 0.52,
        size.width * 0.65,
        size.height * 0.58,
        size.width * 0.88,
        size.height * 0.46,
      );
    canvas.drawPath(routePath, routePaint);

    // Pickup & Destination Nodes
    final nodePaint = Paint()..color = const Color(0xFFDC2626);
    canvas.drawCircle(Offset(size.width * 0.14, size.height * 0.62), 6, nodePaint);

    final destPaint = Paint()..color = const Color(0xFF111827);
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.46), 6, destPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
