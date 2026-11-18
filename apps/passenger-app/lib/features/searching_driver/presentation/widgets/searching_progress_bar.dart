import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../data/models/driver_search_models.dart';
import '../../data/models/searching_driver_config.dart';

class SearchingProgressBar extends StatefulWidget {
  final SearchingDriverStatus status;
  final bool isReconnecting;

  const SearchingProgressBar({
    super.key,
    required this.status,
    this.isReconnecting = false,
  });

  @override
  State<SearchingProgressBar> createState() => _SearchingProgressBarState();
}

class _SearchingProgressBarState extends State<SearchingProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isReconnecting) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              width: double.infinity,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _BarberPolePainter(_controller.value),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                SearchingDriverConfig.reconnectingTelemetry,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFC62828),
                ),
              ),
              Text(
                'Bridge City Cabs',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (widget.status == SearchingDriverStatus.driverFound) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Container(
          height: 5,
          width: double.infinity,
          color: const Color(0xFF00A86B),
        ),
      );
    }

    if (widget.status == SearchingDriverStatus.cancelling) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Container(
          height: 4,
          width: double.infinity,
          color: const Color(0xFFF3C6C6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 140,
              color: const Color(0xFFC62828),
            ),
          ),
        ),
      );
    }

    // Default searching
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Container(
        height: 4,
        width: double.infinity,
        color: const Color(0xFFE5E7EB),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.38,
            child: Container(
              color: const Color(0xFFC62828),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarberPolePainter extends CustomPainter {
  final double animationValue;

  _BarberPolePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFFFEBEE);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final stripePaint = Paint()
      ..color = const Color(0xFFC62828)
      ..style = PaintingStyle.fill;

    const stripeWidth = 8.0;
    const gap = 8.0;
    const totalStep = stripeWidth + gap;

    final offset = animationValue * totalStep;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    for (double x = -totalStep + offset; x < size.width + totalStep; x += totalStep) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + stripeWidth, size.height)
        ..lineTo(x + stripeWidth + 6, 0)
        ..lineTo(x + 6, 0)
        ..close();
      canvas.drawPath(path, stripePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BarberPolePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
