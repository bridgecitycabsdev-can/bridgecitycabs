import 'package:equatable/equatable.dart';

enum LiveTrackingStatus {
  driverAssigned,
  driverArriving,
  driverArrived,
  tripInProgress,
  telemetrySyncing,
  sosTriggered,
  tripCompleted,
  cancelled,
}

class TrackingTripDetails extends Equatable {
  final String trackingId;
  final String pickupAddress;
  final String dropoffAddress;
  final String? dropoffEntrance;
  final double fareAmountCad;
  final String fareLabel;
  final String paymentDetails;
  final double tripProgress;
  final int etaMinutes;
  final String? estimatedArrivalTime;
  final bool gpsSynchronized;

  const TrackingTripDetails({
    this.trackingId = 'BC-123456',
    this.pickupAddress = '515 5th Ave S, Downtown',
    this.dropoffAddress = 'Park Place Mall',
    this.dropoffEntrance = 'North Entrance',
    this.fareAmountCad = 22.10,
    this.fareLabel = 'GUARANTEED',
    this.paymentDetails = 'Card ending 4891',
    this.tripProgress = 0.0,
    this.etaMinutes = 3,
    this.estimatedArrivalTime = '3:38 PM',
    this.gpsSynchronized = true,
  });

  String get formattedFare => '\$${fareAmountCad.toStringAsFixed(2)} CAD';

  String get fullDropoffText {
    if (dropoffEntrance != null && dropoffEntrance!.isNotEmpty) {
      return '$dropoffAddress ($dropoffEntrance)';
    }
    return dropoffAddress;
  }

  TrackingTripDetails copyWith({
    String? trackingId,
    String? pickupAddress,
    String? dropoffAddress,
    String? dropoffEntrance,
    double? fareAmountCad,
    String? fareLabel,
    String? paymentDetails,
    double? tripProgress,
    int? etaMinutes,
    String? estimatedArrivalTime,
    bool? gpsSynchronized,
  }) {
    return TrackingTripDetails(
      trackingId: trackingId ?? this.trackingId,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      dropoffEntrance: dropoffEntrance ?? this.dropoffEntrance,
      fareAmountCad: fareAmountCad ?? this.fareAmountCad,
      fareLabel: fareLabel ?? this.fareLabel,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      tripProgress: tripProgress ?? this.tripProgress,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      estimatedArrivalTime: estimatedArrivalTime ?? this.estimatedArrivalTime,
      gpsSynchronized: gpsSynchronized ?? this.gpsSynchronized,
    );
  }

  @override
  List<Object?> get props => [
        trackingId,
        pickupAddress,
        dropoffAddress,
        dropoffEntrance,
        fareAmountCad,
        fareLabel,
        paymentDetails,
        tripProgress,
        etaMinutes,
        estimatedArrivalTime,
        gpsSynchronized,
      ];
}

class TrackingDriverInfo extends Equatable {
  final String name;
  final double rating;
  final String totalTrips;
  final String vehicleModel;
  final String vehicleTier;
  final String vehicleSpecs;
  final String licensePlate;
  final String province;
  final bool isVerified;
  final String? photoUrl;
  final String? carPhotoUrl;

  const TrackingDriverInfo({
    this.name = 'Michael',
    this.rating = 4.9,
    this.totalTrips = '1,420+ trips',
    this.vehicleModel = 'White Toyota Corolla',
    this.vehicleTier = 'Medium Tier',
    this.vehicleSpecs = 'Sedan • 4 seats',
    this.licensePlate = 'BCC • 892',
    this.province = 'ALBERTA',
    this.isVerified = true,
    this.photoUrl,
    this.carPhotoUrl,
  });

  static const sample = TrackingDriverInfo();

  @override
  List<Object?> get props => [
        name,
        rating,
        totalTrips,
        vehicleModel,
        vehicleTier,
        vehicleSpecs,
        licensePlate,
        province,
        isVerified,
        photoUrl,
        carPhotoUrl,
      ];
}
