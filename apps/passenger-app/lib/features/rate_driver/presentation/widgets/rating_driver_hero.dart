import 'package:flutter/material.dart';
import '../../data/models/rate_driver_models.dart';

class RatingDriverHero extends StatelessWidget {
  final DriverRatingProfile driver;
  final bool showRatingBadge;
  final bool isLocked;
  final String? customTitle;
  final String? customSubtitle;
  final String? fleetTag;

  const RatingDriverHero({
    super.key,
    required this.driver,
    this.showRatingBadge = false,
    this.isLocked = false,
    this.customTitle,
    this.customSubtitle,
    this.fleetTag,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFEE2E2),
                    const Color(0xFFFEE2E2).withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE2E8F0),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: driver.photoUrl != null
                    ? Image.network(driver.photoUrl!, fit: BoxFit.cover)
                    : Container(
                        color: const Color(0xFF475569),
                        child: const Icon(
                          Icons.person,
                          size: 44,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            if (isLocked)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFF475569),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              )
            else if (showRatingBadge)
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Color(0xFFF59E0B), size: 14),
                      const SizedBox(width: 3),
                      Text(
                        driver.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (driver.isVerified)
              Positioned(
                bottom: 2,
                right: 4,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFF991B1B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (fleetTag != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_taxi, size: 14, color: Color(0xFF991B1B)),
                const SizedBox(width: 6),
                Text(
                  fleetTag!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        Text(
          customTitle ?? 'How was your ride with ${driver.name.split(' ').first}?',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          customSubtitle ?? 'Your feedback helps keep our rides great.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
