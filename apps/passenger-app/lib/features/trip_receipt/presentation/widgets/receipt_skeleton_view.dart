import 'package:flutter/material.dart';
import '../../data/models/trip_receipt_config.dart';

class ReceiptSkeletonView extends StatelessWidget {
  const ReceiptSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Skeleton
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 30, bottom: 24),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0F1),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: Color(0xFFC62828),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                _skeletonBox(width: 180, height: 22, color: const Color(0xFFFFCDD2)),
                const SizedBox(height: 8),
                _skeletonBox(width: 240, height: 14, color: const Color(0xFFFFEBEE)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Total Card Skeleton with spinner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Column(
                    children: [
                      _skeletonBox(width: 160, height: 32),
                      const SizedBox(height: 12),
                      _skeletonBox(width: 120, height: 20),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(Color(0xFFC62828)),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            TripReceiptConfig.calculatingFareSkeleton,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Route Skeleton
                _buildCardPlaceholder(height: 100),
                const SizedBox(height: 16),

                // Driver Skeleton
                _buildCardPlaceholder(height: 90),
                const SizedBox(height: 16),

                // Fare Breakdown Skeleton
                _buildCardPlaceholder(height: 140),
                const SizedBox(height: 20),

                // Button Skeleton
                _skeletonBox(
                  width: double.infinity,
                  height: 50,
                  radius: 25,
                  color: const Color(0xFFE5E7EB),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPlaceholder({required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _skeletonBox(width: 140, height: 14),
          _skeletonBox(width: 220, height: 14),
          _skeletonBox(width: 180, height: 14),
        ],
      ),
    );
  }

  static Widget _skeletonBox({
    required double width,
    required double height,
    double radius = 6,
    Color color = const Color(0xFFE5E7EB),
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
