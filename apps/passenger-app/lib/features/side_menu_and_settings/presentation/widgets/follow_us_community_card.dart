import 'package:flutter/material.dart';

class FollowUsCommunityCard extends StatelessWidget {
  const FollowUsCommunityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Follow us',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Lethbridge community',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildSocialCircle(
                child: const Text(
                  'f',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Color(0xFF991B1B),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildSocialCircle(
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 16,
                  color: Color(0xFF991B1B),
                ),
              ),
              const SizedBox(width: 8),
              _buildSocialCircle(
                child: const Icon(
                  Icons.chat_bubble_outline,
                  size: 15,
                  color: Color(0xFF991B1B),
                ),
              ),
              const SizedBox(width: 8),
              _buildSocialCircle(
                child: const Icon(
                  Icons.music_note,
                  size: 16,
                  color: Color(0xFF991B1B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialCircle({required Widget child}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}
