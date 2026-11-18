import 'package:equatable/equatable.dart';

enum NoDriverStatus {
  idle,
  retrySearching,
  stillNoDriver,
  cancelling,
  cancelled,
}

class NoDriverBookingDetails extends Equatable {
  final String trackingId;
  final String pickupAddress;
  final String dropoffAddress;
  final String vehicleTier;
  final String vehicleSpecs;
  final double fareAmountCad;
  final String? fareLabel;
  final String dispatchLocation;

  const NoDriverBookingDetails({
    this.trackingId = 'BC-123456',
    this.pickupAddress = '515 5th Ave S, Downtown',
    this.dropoffAddress = 'Park Place Mall',
    this.vehicleTier = 'SUV • Big',
    this.vehicleSpecs = '6 seats',
    this.fareAmountCad = 22.10,
    this.fareLabel,
    this.dispatchLocation = 'Lethbridge Dispatch',
  });

  String get formattedFare => '\$${fareAmountCad.toStringAsFixed(2)} CAD';

  NoDriverBookingDetails copyWith({
    String? trackingId,
    String? pickupAddress,
    String? dropoffAddress,
    String? vehicleTier,
    String? vehicleSpecs,
    double? fareAmountCad,
    String? fareLabel,
    String? dispatchLocation,
  }) {
    return NoDriverBookingDetails(
      trackingId: trackingId ?? this.trackingId,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      vehicleTier: vehicleTier ?? this.vehicleTier,
      vehicleSpecs: vehicleSpecs ?? this.vehicleSpecs,
      fareAmountCad: fareAmountCad ?? this.fareAmountCad,
      fareLabel: fareLabel ?? this.fareLabel,
      dispatchLocation: dispatchLocation ?? this.dispatchLocation,
    );
  }

  @override
  List<Object?> get props => [
        trackingId,
        pickupAddress,
        dropoffAddress,
        vehicleTier,
        vehicleSpecs,
        fareAmountCad,
        fareLabel,
        dispatchLocation,
      ];
}
