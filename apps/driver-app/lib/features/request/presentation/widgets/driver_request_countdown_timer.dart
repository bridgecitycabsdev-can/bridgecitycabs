import 'dart:math' as math;
import 'package:flutter/material.dart';

class DriverRequestCountdownTimer extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isUrgent;

  const DriverRequestCountdownTimer({
    super.key,
    required this.remainingSeconds,
    this.totalSeconds = 15,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0
        ? (remainingSeconds / totalSeconds).clamp(0.0, 1.0)
        : 0.0;
    final strokeColor = isUrgent || remainingSeconds <= 3
        ? const Color(0xFFD32F2F)
        : const Color(0xFFB71C1C);

    return SizedBox(
      width: 58,
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(58, 58),
            painter: _CircularProgressPainter(
              progress: progress,
              trackColor: Colors.black12,
              progressColor: strokeColor,
              strokeWidth: 4.5,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$remainingSeconds',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isUrgent ? const Color(0xFFD32F2F) : Colors.black87,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                'SEC',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isUrgent ? const Color(0xFFD32F2F) : Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}
