import 'package:flutter/material.dart';
import '../../data/models/add_card_config.dart';

class AddCardVerificationPendingBanner extends StatelessWidget {
  final VoidCallback onRefresh;

  const AddCardVerificationPendingBanner({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              size: 16,
              color: Color(0xFF991B1B),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AddCardConfig.verificationInProgressTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF991B1B),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  AddCardConfig.verificationInProgressSubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF991B1B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onRefresh,
            borderRadius: BorderRadius.circular(8),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, size: 14, color: Color(0xFF991B1B)),
                SizedBox(width: 4),
                Text(
                  'Refresh',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF991B1B),
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
