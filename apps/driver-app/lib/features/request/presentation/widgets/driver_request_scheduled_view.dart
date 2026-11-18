import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/driver_request_bloc.dart';
import '../../bloc/driver_request_event.dart';
import '../../data/models/driver_request_model.dart';
import 'driver_request_acceptance_card.dart';
import 'driver_request_countdown_timer.dart';
import 'driver_request_fare_class_card.dart';
import 'driver_request_passenger_tags.dart';

class DriverRequestScheduledView extends StatelessWidget {
  final DriverRequestModel request;

  const DriverRequestScheduledView({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Scheduled Booking Banner
            _buildTopBanner(),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  // Header with Timer
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'NEW DISPATCH',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.black54,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            request.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      DriverRequestCountdownTimer(
                        remainingSeconds: request.remainingSeconds,
                        totalSeconds: request.totalTimeoutSeconds,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Route Corridor & Map Strip
                  _buildCorridorStrip(),
                  const SizedBox(height: 12),

                  // Pickup Location & Scheduled Alert Box
                  _buildPickupCard(),
                  const SizedBox(height: 12),

                  // Dropoff Location (Airport)
                  _buildDropoffCard(),
                  const SizedBox(height: 12),

                  // Fare & Class
                  DriverRequestFareClassCard(
                    fareCad: request.fareCad,
                    fareType: request.fareType,
                    paymentMethod: request.paymentMethod,
                    vehicleClass: request.vehicleClass,
                    isPreAuthorized: request.isPreAuthorized,
                  ),
                  const SizedBox(height: 12),

                  // Passenger & Scheduled Tags
                  DriverRequestPassengerTags(
                    passengerName: request.passengerName,
                    passengerRating: request.passengerRating,
                    tags: request.tags,
                    isScheduled: true,
                  ),
                  const SizedBox(height: 12),

                  // Acceptance Rate Card
                  DriverRequestAcceptanceCard(
                    acceptanceRate: request.acceptanceRate,
                    acceptanceTier: request.acceptanceTier,
                    adviceText: request.acceptanceAdvice,
                    isScheduled: true,
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),

            // Bottom Buttons
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFFFEBEE),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_month, size: 16, color: Color(0xFFC62828)),
              SizedBox(width: 6),
              Text(
                'SCHEDULED BOOKING',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFB71C1C),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Advance',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFFC62828),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorridorStrip() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: Color(0xFF2E7D32)),
                    SizedBox(width: 8),
                    Icon(Icons.directions_car, size: 14, color: Colors.black45),
                    SizedBox(width: 8),
                    Icon(Icons.square, size: 10, color: Color(0xFFC62828)),
                  ],
                ),
                Text(
                  '${request.distanceKm.toStringAsFixed(2)} km • ${request.driveTimeMinutes} min',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 70,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE8ECEF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(Icons.alt_route, size: 14, color: Colors.black54),
                const SizedBox(width: 6),
                Text(
                  request.routeCorridor,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.circle, size: 10, color: Color(0xFF2E7D32)),
                  SizedBox(width: 6),
                  Text(
                    'PICKUP LOCATION',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2E7D32),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  request.pickupZone,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            request.pickupAddress,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          // Scheduled Highlight Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8F8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFCDD2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Color(0xFFC62828)),
                    const SizedBox(width: 6),
                    Text(
                      request.scheduledDateTimeText ?? 'Scheduled Pickup',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  request.scheduledNotice ??
                      'Advance reservation • Arrive 5 min before pickup time',
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropoffCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.square, size: 10, color: Color(0xFFC62828)),
              SizedBox(width: 6),
              Text(
                'DROP OFF',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFC62828),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            request.dropoffAddress,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          Text(
            request.dropoffLandmark,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: () {
                context
                    .read<DriverRequestBloc>()
                    .add(const DriverRequestDeclinePressed());
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: const Color(0xFFF5F5F5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.close, size: 16, color: Colors.black87),
                  SizedBox(width: 6),
                  Text(
                    'Decline',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                context
                    .read<DriverRequestBloc>()
                    .add(const DriverRequestAcceptPressed());
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFFB71C1C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'ACCEPT RIDE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
