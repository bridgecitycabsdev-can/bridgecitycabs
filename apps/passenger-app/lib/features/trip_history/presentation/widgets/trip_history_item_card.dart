import 'package:flutter/material.dart';
import '../../data/models/trip_history_model.dart';

class TripHistoryItemCard extends StatelessWidget {
  final TripRecord trip;
  final VoidCallback onTap;

  const TripHistoryItemCard({
    super.key,
    required this.trip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = trip.isCompleted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left vertical colored accent bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: isCompleted ? const Color(0xFFDC2626) : const Color(0xFFD1D5DB),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Date/Time and Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                trip.dateTimeLabel,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            trip.formattedTotal,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isCompleted ? const Color(0xFF111827) : const Color(0xFF6B7280),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Route Section
                      _buildRouteRow(
                        isPickup: true,
                        address: trip.pickupAddress,
                        isCompleted: isCompleted,
                      ),
                      _buildDottedConnector(),
                      _buildRouteRow(
                        isPickup: false,
                        address: trip.dropoffAddress,
                        isCompleted: isCompleted,
                      ),
                      const SizedBox(height: 12),

                      // Badges Row
                      Row(
                        children: [
                          // Status Badge
                          _buildStatusBadge(isCompleted),
                          const SizedBox(width: 6),
                          // Payment Badge
                          _buildPillBadge(
                            icon: trip.paymentMethod.toLowerCase().contains('cash')
                                ? Icons.payments_outlined
                                : Icons.credit_card,
                            label: trip.paymentMethod,
                          ),
                          const SizedBox(width: 6),
                          // Vehicle Pill
                          _buildPillBadge(
                            label: trip.vehicleTypePill,
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF9CA3AF),
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteRow({
    required bool isPickup,
    required String address,
    required bool isCompleted,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isPickup
                ? (isCompleted ? const Color(0xFF10B981) : const Color(0xFF9CA3AF))
                : (isCompleted ? const Color(0xFFDC2626) : const Color(0xFF9CA3AF)),
            shape: isPickup ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isPickup ? null : BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPickup ? 'PICKUP' : 'DROPOFF',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDottedConnector() {
    return Container(
      margin: const EdgeInsets.only(left: 4.5),
      height: 14,
      width: 1,
      color: const Color(0xFFD1D5DB),
    );
  }

  Widget _buildStatusBadge(bool isCompleted) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 12, color: Color(0xFF059669)),
            SizedBox(width: 4),
            Text(
              'Completed',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF059669),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.close, size: 12, color: Color(0xFFDC2626)),
          SizedBox(width: 4),
          Text(
            'Canceled',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillBadge({IconData? icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: const Color(0xFF4B5563)),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}
