import 'package:flutter/material.dart';
import '../../data/models/user_profile_model.dart';

class ProfileAvatarHeader extends StatelessWidget {
  final UserProfile user;

  const ProfileAvatarHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        // Large Circular Avatar Placeholder
        Container(
          width: 96,
          height: 96,
          decoration: const BoxDecoration(
            color: Color(0xFFF3F4F6),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.person_outline,
              size: 48,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Full Name
        Text(
          user.fullName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 6),

        // Star Rating & Rides
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(
              5,
              (index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.5),
                child: Icon(
                  Icons.star,
                  size: 16,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${user.rating.toStringAsFixed(1)} (${user.totalRides} rides)',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Membership Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_user_outlined,
                size: 13,
                color: Color(0xFF991B1B),
              ),
              const SizedBox(width: 5),
              Text(
                '${user.riderTier} • Member since ${user.memberSince}',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
