import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/driver_request_bloc.dart';
import '../../bloc/driver_request_event.dart';
import '../../data/models/driver_request_model.dart';
import 'driver_request_acceptance_card.dart';
import 'driver_request_countdown_timer.dart';
import 'driver_request_fare_class_card.dart';
import 'driver_request_passenger_tags.dart';
import 'driver_request_route_summary.dart';

class DriverRequestInstantView extends StatelessWidget {
  final DriverRequestModel request;
  final bool isUrgent;

  const DriverRequestInstantView({
    super.key,
    required this.request,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Audio Banner
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUrgent
                                  ? 'BRIDGE CITY PRIORITY'
                                  : 'BRIDGE CITY CABS • Lethbridge Fleet',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isUrgent
                                    ? const Color(0xFFC62828)
                                    : const Color(0xFFB71C1C),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              request.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              request.subtitle,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DriverRequestCountdownTimer(
                        remainingSeconds: request.remainingSeconds,
                        totalSeconds: request.totalTimeoutSeconds,
                        isUrgent: isUrgent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Route Summary Card
                  DriverRequestRouteSummary(
                    distanceKm: request.distanceKm,
                    driveTimeMinutes: request.driveTimeMinutes,
                    routeCorridor: request.routeCorridor,
                  ),
                  const SizedBox(height: 12),

                  // Pickup & Dropoff Address Card
                  _buildAddressCard(),
                  const SizedBox(height: 12),

                  // Fare & Class Row
                  DriverRequestFareClassCard(
                    fareCad: request.fareCad,
                    fareType: request.fareType,
                    paymentMethod: request.paymentMethod,
                    vehicleClass: request.vehicleClass,
                    isPreAuthorized: request.isPreAuthorized,
                  ),
                  const SizedBox(height: 12),

                  // Passenger Tags
                  DriverRequestPassengerTags(
                    passengerName: request.passengerName,
                    passengerRating: request.passengerRating,
                    tags: request.tags,
                  ),
                  const SizedBox(height: 12),

                  // Acceptance Rate Card
                  DriverRequestAcceptanceCard(
                    acceptanceRate: request.acceptanceRate,
                    acceptanceTier: request.acceptanceTier,
                    adviceText: request.acceptanceAdvice,
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),

            // Urgent Depleting Progress Bar if State 3
            if (isUrgent)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (request.remainingSeconds / 5).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Colors.black12,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFE65100),
                    ),
                  ),
                ),
              ),

            // Bottom Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isUrgent ? const Color(0xFFFFF3E0) : const Color(0xFFFFEBEE),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isUrgent ? Icons.volume_up : Icons.volume_up,
                size: 16,
                color: isUrgent ? const Color(0xFFE65100) : const Color(0xFFC62828),
              ),
              const SizedBox(width: 6),
              Text(
                request.audioAlertText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isUrgent
                      ? const Color(0xFFE65100)
                      : const Color(0xFFB71C1C),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.local_taxi,
                size: 14,
                color: isUrgent ? Colors.black54 : const Color(0xFFB71C1C),
              ),
              const SizedBox(width: 4),
              Text(
                request.cabUnit,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
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
          // Pickup
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.circle, size: 12, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'PICKUP',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2E7D32),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            request.pickupEtaDistance,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      request.pickupAddress,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      request.pickupLandmark,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 5, top: 4, bottom: 4),
            child: SizedBox(
              height: 18,
              child: VerticalDivider(
                color: Colors.black26,
                thickness: 1,
              ),
            ),
          ),
          // Dropoff
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.square, size: 12, color: Color(0xFFC62828)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'DROP OFF',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFC62828),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          request.dropoffEtaTime,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      request.dropoffAddress,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      request.dropoffLandmark,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
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
          // Decline Button
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
          // Accept Button
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
                backgroundColor: isUrgent
                    ? const Color(0xFFD84315)
                    : const Color(0xFFB71C1C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    isUrgent ? 'Accept ride • EXPIRING RAPIDLY' : 'ACCEPT RIDE',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (isUrgent) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
