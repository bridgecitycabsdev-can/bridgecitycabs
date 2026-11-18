import 'package:flutter/material.dart';

class CallDriverMapBackground extends StatelessWidget {
  final String? statusPillText;
  final String? vehicleMarkerText;

  const CallDriverMapBackground({
    super.key,
    this.statusPillText = 'Lethbridge Transit Zone',
    this.vehicleMarkerText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFE5E7EB),
      child: Stack(
        children: [
          // Simulated stylized road map
          CustomPaint(
            size: Size.infinite,
            painter: _LethbridgeMapPainter(),
          ),

          // Top Status Pill
          if (statusPillText != null)
            Positioned(
              top: 16,
              left: 16,
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDC2626),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusPillText!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Floating Navigation Compass Button
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.near_me_outlined,
                color: Color(0xFF1F2937),
                size: 20,
              ),
            ),
          ),

          // Vehicle marker
          if (vehicleMarkerText != null)
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 60),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_taxi,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      vehicleMarkerText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
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

class _LethbridgeMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Waterway (Oldman river)
    final riverPaint = Paint()
      ..color = const Color(0xFFD1E8F7)
      ..strokeWidth = 36
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(size.width * 0.45, 0)
      ..cubicTo(
        size.width * 0.55,
        size.height * 0.35,
        size.width * 0.35,
        size.height * 0.65,
        size.width * 0.5,
        size.height,
      );
    canvas.drawPath(riverPath, riverPaint);

    // Major Arterial Road (Whoop-Up Dr & Crowsnest Hwy)
    final roadPaint = Paint()
      ..color = const Color(0xFFF3F4F6)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final roadPath = Path()
      ..moveTo(0, size.height * 0.45)
      ..lineTo(size.width, size.height * 0.35);
    canvas.drawPath(roadPath, roadPaint);

    // Red Route Line
    final routePaint = Paint()
      ..color = const Color(0xFFDC2626)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routePath = Path()
      ..moveTo(size.width * 0.15, size.height * 0.65)
      ..lineTo(size.width * 0.85, size.height * 0.15);
    canvas.drawPath(routePath, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
