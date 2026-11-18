import 'package:flutter/material.dart';
import '../../data/models/past_trip_detail_config.dart';

class TripActionListTiles extends StatelessWidget {
  final bool isDownloadingPdf;
  final VoidCallback onRateDriver;
  final VoidCallback onDownloadReceipt;
  final VoidCallback onReportProblem;

  const TripActionListTiles({
    super.key,
    this.isDownloadingPdf = false,
    required this.onRateDriver,
    required this.onDownloadReceipt,
    required this.onReportProblem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Action Cards List
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Rate Your Driver
                _buildActionTile(
                  icon: Icons.star_border_rounded,
                  iconColor: const Color(0xFFD97706),
                  iconBg: const Color(0xFFFFFBEB),
                  title: 'Rate your driver',
                  subtitle: 'Feedback window closes in 24 hours',
                  trailing: const Icon(Icons.chevron_right,
                      size: 20, color: Color(0xFF9CA3AF)),
                  onTap: onRateDriver,
                ),
                const Divider(height: 1, indent: 56, color: Color(0xFFF3F4F6)),

                // Download Official Tax Receipt
                _buildActionTile(
                  icon: Icons.receipt_long_outlined,
                  iconColor: const Color(0xFF374151),
                  iconBg: const Color(0xFFF3F4F6),
                  title: 'Download official tax receipt',
                  subtitle: 'Alberta CRA compliant PDF receipt',
                  trailing: isDownloadingPdf
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF991B1B),
                          ),
                        )
                      : const Icon(Icons.download_rounded,
                          size: 20, color: Color(0xFF4B5563)),
                  onTap: isDownloadingPdf ? null : onDownloadReceipt,
                ),
                const Divider(height: 1, indent: 56, color: Color(0xFFF3F4F6)),

                // Report a Problem
                _buildActionTile(
                  icon: Icons.headset_mic_outlined,
                  iconColor: const Color(0xFF4B5563),
                  iconBg: const Color(0xFFF3F4F6),
                  title: 'Report a problem',
                  subtitle: 'Linked ticket for lost item or fare query',
                  trailing: const Icon(Icons.chevron_right,
                      size: 20, color: Color(0xFF9CA3AF)),
                  onTap: onReportProblem,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // City of Lethbridge Bylaw regulatory note
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              PastTripDetailConfig.bylawNotice,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
