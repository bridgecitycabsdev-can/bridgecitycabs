import 'package:flutter/material.dart';
import '../../data/models/support_config.dart';

class SupportEmptyView extends StatelessWidget {
  final VoidCallback onCreateTicket;

  const SupportEmptyView({
    super.key,
    required this.onCreateTicket,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFCA5A5), width: 2),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Color(0xFFB91C1C),
              size: 54,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No tickets yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Need assistance with a recent ride, lost item, or payment? Create a report and local Lethbridge dispatch will assist you shortly.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onCreateTicket,
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              label: const Text(
                'Create new ticket',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB91C1C),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_outlined,
                  color: Color(0xFF059669),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    SupportConfig.responseTimeSubtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4B5563),
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
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
