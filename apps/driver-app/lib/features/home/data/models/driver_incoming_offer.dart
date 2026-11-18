import 'package:equatable/equatable.dart';

class DriverIncomingOffer extends Equatable {
  final String offerId;
  final int remainingSeconds;
  final double estimatedFare;
  final String pickupAddress;
  final String dropoffAddress;
  final double distanceKm;
  final int estimatedDurationMin;

  const DriverIncomingOffer({
    this.offerId = 'OFFER-7821',
    this.remainingSeconds = 13,
    this.estimatedFare = 22.50,
    this.pickupAddress = 'Scenic Dr & 4th Ave S',
    this.dropoffAddress = 'University Dr W, ULeth',
    this.distanceKm = 4.8,
    this.estimatedDurationMin = 9,
  });

  DriverIncomingOffer copyWith({
    String? offerId,
    int? remainingSeconds,
    double? estimatedFare,
    String? pickupAddress,
    String? dropoffAddress,
    double? distanceKm,
    int? estimatedDurationMin,
  }) {
    return DriverIncomingOffer(
      offerId: offerId ?? this.offerId,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedDurationMin: estimatedDurationMin ?? this.estimatedDurationMin,
    );
  }

  @override
  List<Object?> get props => [
        offerId,
        remainingSeconds,
        estimatedFare,
        pickupAddress,
        dropoffAddress,
        distanceKm,
        estimatedDurationMin,
      ];
}
