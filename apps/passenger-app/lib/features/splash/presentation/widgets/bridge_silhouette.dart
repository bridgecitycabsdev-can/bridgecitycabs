import 'package:flutter/material.dart';

/// Renders the iconic Lethbridge Viaduct (High Level Bridge) silhouette
/// spanning across the bottom of the splash screen.
class BridgeSilhouette extends StatelessWidget {
  final double height;
  final Color? color;

  const BridgeSilhouette({
    super.key,
    this.height = 70,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _BridgeSilhouettePainter(
          color: color ?? const Color(0xFF2E0306).withOpacity(0.55),
        ),
      ),
    );
  }
}

class _BridgeSilhouettePainter extends CustomPainter {
  final Color color;

  _BridgeSilhouettePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw horizontal bridge top deck
    const deckThickness = 4.0;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, deckThickness),
      paint,
    );

    // Number of trestle towers to span across screen
    const towerCount = 10;
    final towerSpacing = size.width / towerCount;

    for (int i = 0; i < towerCount; i++) {
      final startX = i * towerSpacing;
      final towerWidth = towerSpacing * 0.7;

      // Draw tapered trestle pier/tower (narrow at top deck, wider at base)
      final path = Path()
        ..moveTo(startX + (towerSpacing - towerWidth) / 2 + (towerWidth * 0.15), deckThickness)
        ..lineTo(startX + (towerSpacing - towerWidth) / 2 + (towerWidth * 0.85), deckThickness)
        ..lineTo(startX + towerSpacing - ((towerSpacing - towerWidth) / 2), size.height)
        ..lineTo(startX + (towerSpacing - towerWidth) / 2, size.height)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BridgeSilhouettePainter oldDelegate) =>
      oldDelegate.color != color;
}
