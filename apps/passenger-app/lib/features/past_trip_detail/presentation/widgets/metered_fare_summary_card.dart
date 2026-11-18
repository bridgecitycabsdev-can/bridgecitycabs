import 'package:flutter/material.dart';
import '../../data/models/past_trip_detail_model.dart';

class MeteredFareSummaryCard extends StatelessWidget {
  final PastTripDetailModel trip;

  const MeteredFareSummaryCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Rate Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fare summary',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trip.rateType,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Line Items
          _buildFareLine(
            'Base Drop Rate',
            '\$${trip.baseDropRateCad.toStringAsFixed(2)} CAD',
          ),
          _buildFareLine(
            'Distance (${trip.distanceKm} km)',
            '\$${trip.distanceRateCad.toStringAsFixed(2)} CAD',
          ),
          _buildFareLine(
            'Waiting / Transit Delay',
            '\$${trip.waitingDelayCad.toStringAsFixed(2)} CAD',
          ),
          _buildFareLine(
            'Subtotal',
            '\$${trip.subtotalCad.toStringAsFixed(2)} CAD',
            isBold: true,
          ),
          _buildFareLine(
            'GST (5% Alberta)',
            '\$${trip.gstCad.toStringAsFixed(2)} CAD',
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Color(0xFFE5E7EB)),
          ),

          // Total Charged
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Charged',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                trip.formattedTotal,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF991B1B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Payment Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      trip.isCash
                          ? Icons.payments_outlined
                          : Icons.credit_card,
                      size: 18,
                      color: const Color(0xFF374151),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      trip.paymentMethodTitle,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: trip.isSettled
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trip.isSettled ? Icons.check : Icons.hourglass_top,
                        size: 12,
                        color: trip.isSettled
                            ? const Color(0xFF059669)
                            : const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trip.paymentStatusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: trip.isSettled
                              ? const Color(0xFF059669)
                              : const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFareLine(String label, String amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isBold
                  ? const Color(0xFF111827)
                  : const Color(0xFF4B5563),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: isBold
                  ? const Color(0xFF111827)
                  : const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}
