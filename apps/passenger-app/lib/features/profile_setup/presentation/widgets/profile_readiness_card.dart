import 'package:flutter/material.dart';
import '../../data/models/profile_setup_config.dart';

/// Celebration readiness card shown when all required profile fields are valid (Screen 2).
class ProfileReadinessCard extends StatelessWidget {
  const ProfileReadinessCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          // Celebration party popper circle
          Text(
            '🎉',
            style: TextStyle(fontSize: 22),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ProfileSetupConfig.readinessTitle,
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  ProfileSetupConfig.readinessSubtitle,
                  style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
