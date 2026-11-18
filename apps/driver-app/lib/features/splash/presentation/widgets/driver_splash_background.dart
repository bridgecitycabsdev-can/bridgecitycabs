import 'package:flutter/material.dart';

class DriverSplashBackground extends StatelessWidget {
  final Widget child;

  const DriverSplashBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFDC2626), // Lethbridge red
            Color(0xFFB91C1C), // Deep crimson
            Color(0xFF881337), // Dark burgundy base
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Checkerboard / Diamond Pattern in Upper Right
          Positioned(
            top: -40,
            right: -40,
            child: CustomPaint(
              size: const Size(260, 260),
              painter: _DiamondCheckerPainter(),
            ),
          ),

          // Dashed Road Line
          Positioned.fill(
            child: CustomPaint(
              painter: _DashedRoadPainter(),
            ),
          ),

          // Lethbridge High Level Bridge Arches at Bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 90,
            child: CustomPaint(
              size: const Size(double.infinity, 90),
              painter: _LethbridgeViaductPainter(),
            ),
          ),

          // Foreground Content
          child,
        ],
      ),
    );
  }
}

class _DiamondCheckerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    const tileSize = 38.0;
    for (double y = 0; y < size.height; y += tileSize) {
      for (double x = 0; x < size.width; x += tileSize) {
        if (((x / tileSize).toInt() + (y / tileSize).toInt()) % 2 == 0) {
          final path = Path()
            ..moveTo(x + tileSize / 2, y)
            ..lineTo(x + tileSize, y + tileSize / 2)
            ..lineTo(x + tileSize / 2, y + tileSize)
            ..lineTo(x, y + tileSize / 2)
            ..close();
          canvas.drawPath(path, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedRoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Diagonal dashed line
    const dashWidth = 14.0;
    const dashSpace = 10.0;
    double startX = 0;
    double startY = size.height * 0.85;
    final endX = size.width;
    final endY = size.height * 0.65;

    final dx = endX - startX;
    final dy = endY - startY;
    final totalDistance = (dx * dx + dy * dy);
    final distance = totalDistance > 0 ? (totalDistance / 2) : 0.0;

    double currentX = startX;
    double currentY = startY;

    final stepX = (dx / 30);
    final stepY = (dy / 30);

    for (int i = 0; i < 30; i += 2) {
      canvas.drawLine(
        Offset(currentX, currentY),
        Offset(currentX + stepX, currentY + stepY),
        paint,
      );
      currentX += stepX * 2;
      currentY += stepY * 2;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LethbridgeViaductPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Bridge deck horizontal line
    canvas.drawLine(
      Offset(0, size.height * 0.15),
      Offset(size.width, size.height * 0.15),
      linePaint,
    );

    // Trestle legs & pillars
    const pillarCount = 10;
    final spacing = size.width / pillarCount;

    for (int i = 0; i <= pillarCount; i++) {
      final x = i * spacing;
      canvas.drawLine(
        Offset(x, size.height * 0.15),
        Offset(x, size.height),
        linePaint,
      );

      // Diagonal cross-bracing
      if (i < pillarCount) {
        canvas.drawLine(
          Offset(x, size.height * 0.15),
          Offset(x + spacing, size.height * 0.8),
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
