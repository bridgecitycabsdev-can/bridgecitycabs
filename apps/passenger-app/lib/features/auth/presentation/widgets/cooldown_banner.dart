import 'package:flutter/material.dart';
import '../../data/models/auth_config.dart';
import '../../data/models/cooldown_timer.dart';

/// Top banner displayed when rate limiting / cooldown is active (Screen 2).
class CooldownBanner extends StatelessWidget {
  final CooldownTimer cooldown;

  const CooldownBanner({
    super.key,
    required this.cooldown,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFCDD2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: Stopwatch, Title, Countdown Timer Capsule
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.timer_outlined,
                  color: Color(0xFFB71C1C),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  AuthConfig.tooManyAttemptsTitle,
                  style: TextStyle(
                    color: Color(0xFF880E14),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              // Countdown Capsule: "04:56"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFCDD2)),
                ),
                child: Text(
                  cooldown.formattedTime,
                  style: const TextStyle(
                    color: Color(0xFFB71C1C),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Description
          const Text(
            AuthConfig.cooldownMessage,
            style: TextStyle(
              color: Color(0xFF4A1014),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),

          // Lock Icon & Wait hint
          const Row(
            children: [
              Icon(
                Icons.lock_clock_outlined,
                color: Color(0xFFB71C1C),
                size: 14,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  AuthConfig.cooldownWaitHint,
                  style: TextStyle(
                    color: Color(0xFF880E14),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal Progress Indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: cooldown.progress,
              backgroundColor: const Color(0xFFFFCDD2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB71C1C)),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}
