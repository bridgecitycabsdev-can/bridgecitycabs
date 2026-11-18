import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/past_trip_detail_model.dart';

class RouteSchematicCard extends StatelessWidget {
  final PastTripDetailModel trip;
  final VoidCallback onCopyTripId;

  const RouteSchematicCard({
    super.key,
    required this.trip,
    required this.onCopyTripId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Trip Meta Header (Date, ID pill with copy icon, Completed badge)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                trip.dateTimeLabel,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4B5563),
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: trip.tripId));
                      onCopyTripId();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            trip.formattedId,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.copy,
                            size: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: trip.isCompleted
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trip.isCompleted ? Icons.check : Icons.access_time,
                          size: 12,
                          color: trip.isCompleted
                              ? const Color(0xFF059669)
                              : const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trip.statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: trip.isCompleted
                                ? const Color(0xFF059669)
                                : const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Schematic Map & Route Box
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top Visual schematic canvas (River Crossing + Whoop-Up Dr Route)
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Stack(
                    children: [
                      // River graphic
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 130,
                        width: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFBFDBFE).withOpacity(0.4),
                                const Color(0xFF93C5FD).withOpacity(0.5),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      // Crossing label pill
                      Positioned(
                        right: 14,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Text(
                            trip.crossingLabel,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ),
                      ),
                      // Route tag pill
                      Positioned(
                        left: 12,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2937),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.navigation,
                                  size: 10, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                trip.routeTag,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Schematic trajectory line
                      Positioned(
                        left: 40,
                        bottom: 24,
                        right: 40,
                        top: 36,
                        child: CustomPaint(
                          painter: _SchematicRoutePainter(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Pickup & Dropoff Address Block
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      // Pickup
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 3),
                            child: Icon(Icons.circle,
                                size: 10, color: Color(0xFF059669)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        trip.pickupAddress,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      trip.pickupTime,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                                if (trip.pickupSubtext.isNotEmpty)
                                  Text(
                                    trip.pickupSubtext,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Connecting line
                      Padding(
                        padding: const EdgeInsets.only(left: 4.5),
                        child: Row(
                          children: [
                            Container(
                              width: 1.5,
                              height: 18,
                              color: const Color(0xFFD1D5DB),
                            ),
                          ],
                        ),
                      ),

                      // Dropoff
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 3),
                            child: Icon(Icons.square,
                                size: 10, color: Color(0xFFDC2626)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        trip.dropoffAddress,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      trip.dropoffTime,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                                if (trip.dropoffSubtext.isNotEmpty)
                                  Text(
                                    trip.dropoffSubtext,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Stats pill (distance, transit time, weather)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.straighten,
                                    size: 13, color: Color(0xFF6B7280)),
                                const SizedBox(width: 4),
                                Text(
                                  '${trip.distanceKm} km',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ],
                            ),
                            const Text('·',
                                style: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                const Icon(Icons.schedule,
                                    size: 13, color: Color(0xFF6B7280)),
                                const SizedBox(width: 4),
                                Text(
                                  '${trip.durationMinutes} min transit',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ],
                            ),
                            const Text('·',
                                style: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                const Icon(Icons.wb_sunny_outlined,
                                    size: 13, color: Color(0xFFD97706)),
                                const SizedBox(width: 4),
                                Text(
                                  trip.weather,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SchematicRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDC2626)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height);
    path.cubicTo(
      size.width * 0.35,
      size.height * 0.8,
      size.width * 0.65,
      size.height * 0.2,
      size.width,
      0,
    );

    canvas.drawPath(path, paint);

    // Green start node
    final greenPaint = Paint()..color = const Color(0xFF059669);
    canvas.drawCircle(Offset(0, size.height), 5, greenPaint);

    // Red end node
    final redPaint = Paint()..color = const Color(0xFFDC2626);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(size.width, 0), width: 9, height: 9),
      redPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
