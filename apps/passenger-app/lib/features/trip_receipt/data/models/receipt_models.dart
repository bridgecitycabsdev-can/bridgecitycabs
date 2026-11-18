import 'package:equatable/equatable.dart';
import 'receipt_fare_breakdown.dart';

enum TripReceiptStatus {
  loading,
  cashPending,
  cashConfirmed,
  cardPaid,
  discountApplied,
}

class TripReceiptDetails extends Equatable {
  final String trackingId;
  final String pickupAddress;
  final String pickupTime;
  final String dropoffAddress;
  final String dropoffTime;
  final double distanceKm;
  final int durationMinutes;
  final String routeTag;
  final String driverName;
  final double driverRating;
  final String driverBadge;
  final String driverInitials;
  final String vehicleModel;
  final String vehicleSpecs;
  final String licensePlate;
  final String province;
  final List<String> featureTags;
  final ReceiptFareBreakdown fare;
  final double? userRating;
  final String? ratingFeedback;

  const TripReceiptDetails({
    this.trackingId = 'BC-123456',
    this.pickupAddress = '515 5th Ave S, Downtown Lethbridge',
    this.pickupTime = '3:12 PM',
    this.dropoffAddress = 'Park Place Mall (North Entrance)',
    this.dropoffTime = '3:27 PM',
    this.distanceKm = 5.2,
    this.durationMinutes = 15,
    this.routeTag = 'Direct',
    this.driverName = 'Michael K.',
    this.driverRating = 4.9,
    this.driverBadge = 'Authorized Driver',
    this.driverInitials = 'MK',
    this.vehicleModel = 'White Toyota Corolla',
    this.vehicleSpecs = 'Sedan • 4 seats',
    this.licensePlate = 'BCC • 892',
    this.province = 'ALBERTA',
    this.featureTags = const [
      'Standard Sedan',
      '4 Passenger Seats',
      'Clean Air Fleet',
    ],
    this.fare = const ReceiptFareBreakdown(),
    this.userRating,
    this.ratingFeedback,
  });

  String get statsText => '$distanceKm km • $durationMinutes mins trip time';

  TripReceiptDetails copyWith({
    String? trackingId,
    String? pickupAddress,
    String? pickupTime,
    String? dropoffAddress,
    String? dropoffTime,
    double? distanceKm,
    int? durationMinutes,
    String? routeTag,
    String? driverName,
    double? driverRating,
    String? driverBadge,
    String? driverInitials,
    String? vehicleModel,
    String? vehicleSpecs,
    String? licensePlate,
    String? province,
    List<String>? featureTags,
    ReceiptFareBreakdown? fare,
    double? userRating,
    String? ratingFeedback,
  }) {
    return TripReceiptDetails(
      trackingId: trackingId ?? this.trackingId,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupTime: pickupTime ?? this.pickupTime,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      dropoffTime: dropoffTime ?? this.dropoffTime,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      routeTag: routeTag ?? this.routeTag,
      driverName: driverName ?? this.driverName,
      driverRating: driverRating ?? this.driverRating,
      driverBadge: driverBadge ?? this.driverBadge,
      driverInitials: driverInitials ?? this.driverInitials,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleSpecs: vehicleSpecs ?? this.vehicleSpecs,
      licensePlate: licensePlate ?? this.licensePlate,
      province: province ?? this.province,
      featureTags: featureTags ?? this.featureTags,
      fare: fare ?? this.fare,
      userRating: userRating ?? this.userRating,
      ratingFeedback: ratingFeedback ?? this.ratingFeedback,
    );
  }

  @override
  List<Object?> get props => [
        trackingId,
        pickupAddress,
        pickupTime,
        dropoffAddress,
        dropoffTime,
        distanceKm,
        durationMinutes,
        routeTag,
        driverName,
        driverRating,
        driverBadge,
        driverInitials,
        vehicleModel,
        vehicleSpecs,
        licensePlate,
        province,
        featureTags,
        fare,
        userRating,
        ratingFeedback,
      ];
}
