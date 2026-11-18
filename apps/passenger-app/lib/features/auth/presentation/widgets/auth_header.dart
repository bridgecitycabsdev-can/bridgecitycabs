import 'package:flutter/material.dart';
import '../../data/models/auth_config.dart';

/// Top branding header with the steering wheel / bridge emblem,
/// brand name, and "Login" headline.
class AuthHeader extends StatelessWidget {
  final String? subtitleOverride;
  final Widget? trailingBadge;

  const AuthHeader({
    super.key,
    this.subtitleOverride,
    this.trailingBadge,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Custom Emblem: Steering wheel circle with bridge silhouette
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _AuthLogoPainter(),
              ),
            ),
            if (trailingBadge != null)
              Positioned(
                right: 0,
                bottom: 0,
                child: trailingBadge!,
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Brand Title
        const Text(
          AuthConfig.appBrand,
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),

        // Sub-brand: — CABS • ALBERTA —
        Text(
          subtitleOverride ?? '— ${AuthConfig.appSubtitle} —',
          style: const TextStyle(
            color: Color(0xFFB71C1C),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 24),

        // Headline
        const Text(
          AuthConfig.screenTitle,
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 6),

        // Subtitle
        const Text(
          AuthConfig.screenSubtitle,
          style: TextStyle(
            color: Color(0xFF4B5563),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _AuthLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;

    // Steering wheel outer rim
    final rimPaint = Paint()
      ..color = const Color(0xFF1E1E1E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5;
    canvas.drawCircle(center, radius, rimPaint);

    // Inner hub
    final hubRadius = size.width * 0.12;
    final hubPaint = Paint()
      ..color = const Color(0xFF1E1E1E)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, hubRadius, hubPaint);

    // Spokes
    final spokePaint = Paint()
      ..color = const Color(0xFF1E1E1E)
      ..strokeWidth = 3.5;
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      spokePaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(center.dx, center.dy + radius),
      spokePaint,
    );

    // Red bridge silhouette inside upper hemisphere
    final bridgePaint = Paint()
      ..color = const Color(0xFFB71C1C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    final bridgeDeckY = center.dy - 3;
    canvas.drawLine(
      Offset(center.dx - radius * 0.75, bridgeDeckY),
      Offset(center.dx + radius * 0.75, bridgeDeckY),
      bridgePaint,
    );

    // Arch
    final archPath = Path()
      ..moveTo(center.dx - radius * 0.7, bridgeDeckY)
      ..quadraticBezierTo(center.dx, center.dy - radius * 0.65, center.dx + radius * 0.7, bridgeDeckY);
    canvas.drawPath(archPath, bridgePaint);

    // Vertical bridge trusses
    for (double x = -14; x <= 14; x += 7) {
      canvas.drawLine(
        Offset(center.dx + x, bridgeDeckY),
        Offset(center.dx + x, center.dy - radius * 0.45),
        bridgePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
