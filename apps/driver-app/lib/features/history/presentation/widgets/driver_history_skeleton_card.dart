import 'package:flutter/material.dart';

class DriverHistorySkeletonCard extends StatelessWidget {
  const DriverHistorySkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPlaceholder(width: 80, height: 16),
              _buildPlaceholder(width: 50, height: 16),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Column(
                children: [
                  _buildCirclePlaceholder(size: 8),
                  const SizedBox(height: 12),
                  _buildCirclePlaceholder(size: 8),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlaceholder(width: double.infinity, height: 12),
                    const SizedBox(height: 10),
                    _buildPlaceholder(width: 140, height: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPlaceholder(width: 90, height: 10),
              _buildPlaceholder(width: 50, height: 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }

  Widget _buildCirclePlaceholder({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFE0E0E0),
        shape: BoxShape.circle,
      ),
    );
  }
}
