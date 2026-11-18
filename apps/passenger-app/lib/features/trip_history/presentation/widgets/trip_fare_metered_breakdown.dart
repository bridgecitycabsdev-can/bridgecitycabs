import 'package:flutter/material.dart';
import '../../data/models/trip_history_config.dart';
import '../../data/models/trip_history_model.dart';

class TripFareMeteredBreakdown extends StatelessWidget {
  final TripRecord trip;
  final bool isDownloading;
  final VoidCallback onRateDriver;
  final VoidCallback onDownloadReceipt;
  final VoidCallback onReportProblem;

  const TripFareMeteredBreakdown({
    super.key,
    required this.trip,
    required this.isDownloading,
    required this.onRateDriver,
    required this.onDownloadReceipt,
    required this.onReportProblem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fare Summary Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fare summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Metered Rate #1',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF991B1B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Itemized rows
              _FareRow(label: 'Base Drop Rate', value: '\$${trip.baseRateCad.toStringAsFixed(2)} CAD'),
              const SizedBox(height: 8),
              _FareRow(
                label: 'Distance (${trip.distanceKm.toStringAsFixed(2)} km)',
                value: '\$${trip.distanceRateCad.toStringAsFixed(2)} CAD',
              ),
              const SizedBox(height: 8),
              _FareRow(label: 'Waiting / Transit Delay', value: '\$${trip.waitingTimeCad.toStringAsFixed(2)} CAD'),
              const SizedBox(height: 8),
              _FareRow(label: 'Subtotal', value: '\$${trip.subtotalCad.toStringAsFixed(2)} CAD'),
              const SizedBox(height: 8),
              _FareRow(label: 'GST (5% Alberta)', value: '\$${trip.gstCad.toStringAsFixed(2)} CAD'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFFE5E7EB)),
              ),

              // Total row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL CHARGED',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6B7280),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        trip.formattedTotal,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.credit_card, size: 14, color: Color(0xFF991B1B)),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip.paymentMethod,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.check, size: 10, color: Color(0xFF059669)),
                                const SizedBox(width: 2),
                                Text(
                                  trip.paymentStatus,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Action Tiles
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              // Rate Driver
              _ActionTile(
                icon: Icons.star_outline,
                iconColor: const Color(0xFFF59E0B),
                iconBgColor: const Color(0xFFFFFBEB),
                title: 'Rate your driver',
                subtitle: 'Feedback window closes in 24 hours',
                trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFF9CA3AF)),
                onTap: onRateDriver,
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFE5E7EB)),

              // Download Receipt
              _ActionTile(
                icon: Icons.receipt_long_outlined,
                iconColor: const Color(0xFF374151),
                iconBgColor: const Color(0xFFF3F4F6),
                title: 'Download official tax receipt',
                subtitle: 'Alberta CRA compliant PDF receipt',
                trailing: isDownloading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download, size: 20, color: Color(0xFF6B7280)),
                onTap: isDownloading ? null : onDownloadReceipt,
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFE5E7EB)),

              // Report a problem
              _ActionTile(
                icon: Icons.help_outline,
                iconColor: const Color(0xFFB91C1C),
                iconBgColor: const Color(0xFFFEF2F2),
                title: 'Report a problem',
                subtitle: 'Linked ticket for lost item or fare query',
                trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFF9CA3AF)),
                onTap: onReportProblem,
              ),
            ],
          ),
        ),

        // Bylaw 6138 Footer Card
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.shield_outlined, size: 16, color: Color(0xFF059669)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  TripHistoryConfig.bylawAuditNotice,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FareRow extends StatelessWidget {
  final String label;
  final String value;

  const _FareRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF4B5563),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
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
