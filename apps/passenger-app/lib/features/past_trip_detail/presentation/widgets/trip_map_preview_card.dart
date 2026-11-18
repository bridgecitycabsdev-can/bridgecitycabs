import 'package:flutter/material.dart';
import '../../data/models/past_trip_detail_model.dart';

class TripMapPreviewCard extends StatelessWidget {
  final PastTripDetailModel trip;

  const TripMapPreviewCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Map Graphic Preview with Overlays
          Container(
            height: 140,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE5F3E9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                // Simulated map roads & river canvas
                CustomPaint(
                  size: const Size(double.infinity, 140),
                  painter: _MapTerrainPainter(),
                ),

                // Area tags
                const Positioned(
                  left: 20,
                  top: 30,
                  child: Text(
                    'Coalhurst',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
                const Positioned(
                  right: 40,
                  top: 25,
                  child: Text(
                    'Pavan Park',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
                const Positioned(
                  right: 30,
                  bottom: 30,
                  child: Text(
                    'Hardieville',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),

                // Gradient Vignette
                Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                // Overlay Chip on Map: Trip ID
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      trip.formattedId,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Overlay Chip on Map: Date & Time
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Text(
                    trip.dateTimeLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Route card below map
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Pickup
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFDC2626), width: 3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pickup · ${trip.pickupTime}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            trip.pickupAddress,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Connecting line
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 1.5,
                        height: 18,
                        color: const Color(0xFFE5E7EB),
                      ),
                    ],
                  ),
                ),

                // Dropoff
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Color(0xFF111827),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dropoff · ${trip.dropoffTime}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            trip.dropoffAddress,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapTerrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Soft River Curve
    final riverPaint = Paint()
      ..color = const Color(0xFF93C5FD).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(size.width * 0.45, 0)
      ..cubicTo(
        size.width * 0.40,
        size.height * 0.4,
        size.width * 0.55,
        size.height * 0.7,
        size.width * 0.50,
        size.height,
      );
    canvas.drawPath(riverPath, riverPaint);

    // Highway Line
    final highwayPaint = Paint()
      ..color = const Color(0xFFFBBF24).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final roadPath = Path()
      ..moveTo(0, size.height * 0.55)
      ..lineTo(size.width, size.height * 0.52);
    canvas.drawPath(roadPath, highwayPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
