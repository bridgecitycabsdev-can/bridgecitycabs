import 'package:flutter/material.dart';
import '../bloc/location_permission_state.dart';
import '../../data/models/location_permission_config.dart';

/// Interactive map preview showing accuracy radar (Prompt) or disabled state (Unavailable).
class LocationMapPreview extends StatelessWidget {
  final LocationPermissionStatus status;

  const LocationMapPreview({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isPrompt = status == LocationPermissionStatus.prompt;

    return Container(
      width: double.infinity,
      height: 230,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Custom Map Canvas (Streets and river)
            CustomPaint(
              size: const Size(double.infinity, 230),
              painter: _MapPreviewPainter(isDimmed: !isPrompt),
            ),

            // Center Radar and Pin
            if (isPrompt) ...[
              // Concentric radar accuracy rings
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCDD2).withOpacity(0.35),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF9A9A).withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
              ),
              // Floating accuracy pill above pin
              Positioned(
                top: 45,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
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
                      Icon(Icons.circle, color: Color(0xFFB71C1C), size: 6),
                      SizedBox(width: 5),
                      Text(
                        LocationPermissionConfig.accurate5m,
                        style: TextStyle(
                          color: Color(0xFF1E1E1E),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Solid red bullseye pin
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF880E14),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF880E14).withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.gps_fixed_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              // Bottom-left floating card overlay: Downtown / Scenic Dr
              Positioned(
                left: 14,
                bottom: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_taxi_rounded,
                        color: Color(0xFFB71C1C),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            LocationPermissionConfig.scenicPickupCardTitle,
                            style: TextStyle(
                              color: Color(0xFF1E1E1E),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            LocationPermissionConfig.scenicPickupCardSub,
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Screen 1: Location Disabled Radar
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCDD2).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF9A9A).withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
              ),
              // White circular badge with crossed out location pin
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_off_rounded,
                      color: Color(0xFFB71C1C),
                      size: 28,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB71C1C),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.block_rounded,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Bottom pill overlay on map: Awaiting coordinates • Coulee Corridor
              Positioned(
                bottom: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
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
                      Icon(
                        Icons.gps_not_fixed_rounded,
                        color: Color(0xFFB71C1C),
                        size: 13,
                      ),
                      SizedBox(width: 6),
                      Text(
                        LocationPermissionConfig.awaitingCoords,
                        style: TextStyle(
                          color: Color(0xFF374151),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MapPreviewPainter extends CustomPainter {
  final bool isDimmed;

  _MapPreviewPainter({required this.isDimmed});

  @override
  void paint(Canvas canvas, Size size) {
    // Street lines
    final streetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;

    final borderPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw grid
    for (double y = 30; y < size.height; y += 45) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), streetPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), borderPaint);
    }
    for (double x = 40; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), streetPaint);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), borderPaint);
    }

    // Diagonal arterial road
    final diagonalPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.2),
      diagonalPaint,
    );

    // Dim overlay if disabled
    if (isDimmed) {
      final dimPaint = Paint()..color = Colors.white.withOpacity(0.65);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), dimPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapPreviewPainter oldDelegate) =>
      oldDelegate.isDimmed != isDimmed;
}
