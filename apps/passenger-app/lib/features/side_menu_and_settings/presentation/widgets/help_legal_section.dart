import 'package:flutter/material.dart';

class HelpLegalSection extends StatelessWidget {
  final ValueChanged<String> onTileTapped;

  const HelpLegalSection({
    super.key,
    required this.onTileTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'HELP & LEGAL',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Column(
            children: [
              _buildTile(
                id: 'faqs',
                icon: Icons.quiz_outlined,
                title: 'FAQs',
                showDivider: true,
              ),
              _buildTile(
                id: 'terms',
                icon: Icons.description_outlined,
                title: 'Terms and conditions',
                showDivider: true,
              ),
              _buildTile(
                id: 'privacy',
                icon: Icons.shield_outlined,
                title: 'Privacy and data',
                showDivider: true,
              ),
              _buildTile(
                id: 'about',
                icon: Icons.info_outline,
                title: 'About',
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTile({
    required String id,
    required IconData icon,
    required String title,
    required bool showDivider,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () => onTileTapped(id),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF4B5563),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF9CA3AF),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            indent: 48,
            color: Color(0xFFF3F4F6),
          ),
      ],
    );
  }
}
