import 'package:flutter/material.dart';
import '../../data/models/profile_setup_config.dart';

/// Top banner displayed when form validation errors exist (Screen 3).
class ProfileTopErrorBanner extends StatelessWidget {
  final int errorCount;

  const ProfileTopErrorBanner({
    super.key,
    required this.errorCount,
  });

  @override
  Widget build(BuildContext context) {
    if (errorCount <= 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFFCDD2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFB71C1C),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              ProfileSetupConfig.errorBannerText(errorCount),
              style: const TextStyle(
                color: Color(0xFF880E14),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
