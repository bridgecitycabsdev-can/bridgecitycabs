import 'package:flutter/material.dart';
import '../../data/models/driver_search_models.dart';
import '../../data/models/searching_driver_config.dart';

class SearchingRouteSummaryCard extends StatelessWidget {
  final SearchBookingDetails booking;
  final SearchingDriverStatus status;
  final bool isReconnecting;

  const SearchingRouteSummaryCard({
    super.key,
    required this.booking,
    required this.status,
    this.isReconnecting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pickup row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: status == SearchingDriverStatus.driverFound ||
                            isReconnecting
                        ? const Color(0xFFC62828)
                        : const Color(0xFF00A86B),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status == SearchingDriverStatus.driverFound
                          ? 'PICKUP SPOT'
                          : 'PICKUP',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9E9E9E),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.pickupAddress,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Connector line
          Padding(
            padding: const EdgeInsets.only(left: 4.5, top: 4, bottom: 4),
            child: Container(
              width: 1.5,
              height: 18,
              color: const Color(0xFFE0E0E0),
            ),
          ),

          // Dropoff row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: status == SearchingDriverStatus.driverFound ||
                            isReconnecting
                        ? const Color(0xFF1F1F1F)
                        : const Color(0xFFC62828),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status == SearchingDriverStatus.driverFound
                          ? 'DESTINATION'
                          : 'DROPOFF',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9E9E9E),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.fullDropoffText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),

          // Vehicle & Fare summary row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: Color(0xFF424242),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            booking.vehicleTier,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F1F1F),
                            ),
                          ),
                          if (booking.seats > 0 &&
                              status != SearchingDriverStatus.driverFound) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${booking.seats} seats',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.credit_card,
                            size: 13,
                            color: Color(0xFF757575),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            booking.paymentMethodText,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (status == SearchingDriverStatus.driverFound) ...[
                    const Text(
                      'Agreed Fare',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                  Text(
                    booking.formattedFare,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFC62828),
                    ),
                  ),
                  if (isReconnecting) ...[
                    const Text(
                      'Fixed rate locked',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          // Driver found server matching banner
          if (status == SearchingDriverStatus.driverFound) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation(Color(0xFFC62828)),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      SearchingDriverConfig.matchingDispatchBanner,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4B5563),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Scheduled ride notice
          if (booking.isScheduled &&
              booking.scheduledDispatchNotice != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 13,
                  color: Color(0xFFC62828),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    booking.scheduledDispatchNotice!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
