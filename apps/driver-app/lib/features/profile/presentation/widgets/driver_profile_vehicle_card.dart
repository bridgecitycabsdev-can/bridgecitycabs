import 'package:flutter/material.dart';
import '../../data/models/driver_assigned_vehicle.dart';

class DriverProfileVehicleCard extends StatelessWidget {
  final DriverAssignedVehicle vehicle;
  final bool isFleetAssignmentStyle;

  const DriverProfileVehicleCard({
    super.key,
    required this.vehicle,
    this.isFleetAssignmentStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_taxi, size: 18, color: Color(0xFFC62828)),
                    const SizedBox(width: 8),
                    Text(
                      isFleetAssignmentStyle ? 'FLEET ASSIGNMENT' : 'Assigned Vehicle',
                      style: TextStyle(
                        fontSize: isFleetAssignmentStyle ? 11 : 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                        letterSpacing: isFleetAssignmentStyle ? 0.5 : 0.0,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isFleetAssignmentStyle
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFC62828),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isFleetAssignmentStyle ? 'INSPECTED' : vehicle.unitNumber,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: isFleetAssignmentStyle
                          ? const Color(0xFF2E7D32)
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Taxi Vehicle Graphic Container
          Container(
            height: 140,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFEF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                CustomPaint(
                  size: const Size(double.infinity, 140),
                  painter: _VehiclePreviewPainter(),
                ),
                Positioned(
                  left: 12,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        if (vehicle.isGpsLinked) ...[
                          const Icon(Icons.circle, size: 8, color: Colors.greenAccent),
                          const SizedBox(width: 5),
                          const Text(
                            'GPS Linked',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ] else ...[
                          Text(
                            vehicle.unitNumber,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Vehicle Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.makeModel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  vehicle.inspectionLabel,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
                const SizedBox(height: 12),

                // License Plate & Class Pills
                Row(
                  children: [
                    // Plate pill
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9FB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'AB ',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFC62828),
                              ),
                            ),
                            Text(
                              vehicle.plateNumber,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFB71C1C),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Class pill
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9FB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.directions_car, size: 14, color: Colors.black87),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                vehicle.vehicleClass,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VehiclePreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFF0F4F8);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = const Color(0xFFB0BEC5)
      ..strokeWidth = 24;
    canvas.drawLine(
      Offset(0, size.height * 0.75),
      Offset(size.width, size.height * 0.75),
      roadPaint,
    );

    // Car silhouette
    final carPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final carBorder = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.6),
        width: size.width * 0.65,
        height: 48,
      ),
      const Radius.circular(14),
    );
    canvas.drawRRect(rrect, carPaint);
    canvas.drawRRect(rrect, carBorder);

    // Taxi Roof sign
    final roofSign = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.38),
      width: 44,
      height: 14,
    );
    canvas.drawRect(roofSign, Paint()..color = const Color(0xFFFFA000));
    canvas.drawRect(roofSign, carBorder);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
