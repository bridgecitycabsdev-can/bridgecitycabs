import 'package:equatable/equatable.dart';

class DriverRideRequestMock extends Equatable {
  final String tier;
  final double estimatedFare;
  final String distance;
  final String tripDuration;
  final int countdownSeconds;
  final String pickupAddress;
  final String dropoffAddress;

  const DriverRideRequestMock({
    this.tier = 'STANDARD CAD',
    this.estimatedFare = 22.50,
    this.distance = '4.8 km',
    this.tripDuration = '9 min trip',
    this.countdownSeconds = 14,
    this.pickupAddress = 'Scenic Dr & 4th Ave S',
    this.dropoffAddress = 'University Dr W, ULeth',
  });

  @override
  List<Object?> get props => [
        tier,
        estimatedFare,
        distance,
        tripDuration,
        countdownSeconds,
        pickupAddress,
        dropoffAddress,
      ];
}
