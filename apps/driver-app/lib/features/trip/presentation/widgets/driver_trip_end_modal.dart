import 'package:flutter/material.dart';
import '../../data/models/driver_trip_model.dart';

class DriverTripEndModal extends StatelessWidget {
  final DriverTripModel trip;
  final ValueChanged<String> onProximityModeChanged;
  final VoidCallback onEndTripConfirmed;
  final VoidCallback onCancelPressed;

  const DriverTripEndModal({
    super.key,
    required this.trip,
    required this.onProximityModeChanged,
    required this.onEndTripConfirmed,
    required this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isFar = trip.isFarDropoff;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Red Pin Icon Circle
          Center(
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFFDE8E8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: Color(0xFFBA0C2F),
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Title
          const Center(
            child: Text(
              'End this trip?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Make sure you've reached the drop-off location and the passenger has gathered all personal belongings.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  height: 1.35,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Designated Drop-off card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBA0C2F),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DESIGNATED DROP-OFF',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6B7280),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        trip.dropoffAddress,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${trip.dropoffDistanceAwayKm} km away',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isFar
                            ? const Color(0xFFBA0C2F)
                            : const Color(0xFF10B981),
                      ),
                    ),
                    Text(
                      'Est. \$${trip.estimatedDropoffFareCad.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Proximity test toggle chips (Far vs Within 50m)
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => onProximityModeChanged('far'),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isFar
                          ? const Color(0xFFFDE8E8)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isFar
                            ? const Color(0xFFBA0C2F)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: isFar
                              ? const Color(0xFFBA0C2F)
                              : const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Far (1.2 km Warning)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isFar ? FontWeight.w700 : FontWeight.w500,
                            color: isFar
                                ? const Color(0xFFBA0C2F)
                                : const Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => onProximityModeChanged('within50m'),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: !isFar
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: !isFar
                            ? const Color(0xFF10B981)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 14,
                          color: !isFar
                              ? const Color(0xFF10B981)
                              : const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Within 50m (Normal)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                !isFar ? FontWeight.w700 : FontWeight.w500,
                            color: !isFar
                                ? const Color(0xFF047857)
                                : const Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Early Dropoff Alert Warning Card (Shown when far)
          if (isFar)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFEE2E2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDE8E8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFBA0C2F),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "You're 1.2 km from the drop-off. End the trip anyway?",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Ending the trip early will compute the meter fare based on current GPS telemetry. A short-drop notation will be flagged to dispatch.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFB91C1C),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),

          // Computed Meter Fare row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 18,
                    color: Color(0xFF4B5563),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Computed Meter Fare',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '\$${trip.computedMeterFareCad.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Taxes included',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF047857),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // End trip & Generate Receipt solid red button
          ElevatedButton(
            onPressed: onEndTripConfirmed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBA0C2F),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline_rounded, size: 18),
                SizedBox(width: 8),
                Text(
                  'End trip & Generate Receipt',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Not yet text button
          Center(
            child: TextButton(
              onPressed: onCancelPressed,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.undo_rounded, size: 16, color: Color(0xFF4B5563)),
                  SizedBox(width: 4),
                  Text(
                    'Not yet',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Bylaw 6138 Compliance note
          const Row(
            children: [
              Icon(
                Icons.shield_outlined,
                size: 14,
                color: Color(0xFF6B7280),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'City of Lethbridge Taxi Commission Bylaw 6138 Compliance: Fare finalized instantly via onboard digital meter algorithm upon trip termination.',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B7280),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
