import 'package:flutter/material.dart';

class PaymentSkeletonView extends StatefulWidget {
  const PaymentSkeletonView({super.key});

  @override
  State<PaymentSkeletonView> createState() => _PaymentSkeletonViewState();
}

class _PaymentSkeletonViewState extends State<PaymentSkeletonView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.35, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final opacity = _animation.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header top pill placeholder with red dot
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF991B1B),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _placeholder(width: 220, height: 16, opacity: opacity),
                ],
              ),
              const SizedBox(height: 16),

              // Cash Card Placeholder
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Row(
                  children: [
                    _placeholder(width: 44, height: 44, opacity: opacity, radius: 12),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _placeholder(width: 120, height: 14, opacity: opacity),
                          const SizedBox(height: 8),
                          _placeholder(width: 180, height: 12, opacity: opacity),
                        ],
                      ),
                    ),
                    _placeholder(width: 20, height: 20, opacity: opacity, radius: 10),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section Header Placeholder
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _placeholder(width: 100, height: 14, opacity: opacity),
                  _placeholder(width: 60, height: 14, opacity: opacity),
                ],
              ),
              const SizedBox(height: 12),

              // 3 Card row placeholders
              ...List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Row(
                    children: [
                      _placeholder(width: 48, height: 32, opacity: opacity, radius: 8),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _placeholder(width: 130, height: 14, opacity: opacity),
                            const SizedBox(height: 6),
                            _placeholder(width: 80, height: 12, opacity: opacity),
                          ],
                        ),
                      ),
                      if (index == 0)
                        _placeholder(width: 44, height: 20, opacity: opacity, radius: 10)
                      else
                        _placeholder(width: 24, height: 24, opacity: opacity, radius: 12),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),

              // Add card button placeholder
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2).withValues(alpha: opacity),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, size: 16, color: Color(0xFF991B1B)),
                    ),
                    const SizedBox(width: 10),
                    _placeholder(width: 110, height: 14, opacity: opacity),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Security notice card placeholder
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, size: 18, color: Color(0xFF991B1B)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _placeholder(width: double.infinity, height: 10, opacity: opacity),
                          const SizedBox(height: 6),
                          _placeholder(width: 190, height: 10, opacity: opacity),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Footer Seal
              const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.directions_car, size: 14, color: Color(0xFF991B1B)),
                    SizedBox(width: 6),
                    Text(
                      'Bridge City Cabs • Lethbridge Secure Pay',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _placeholder({
    required double width,
    required double height,
    required double opacity,
    double radius = 4,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFCBD5E1).withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
