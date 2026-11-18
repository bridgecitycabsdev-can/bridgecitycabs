enum RateDriverStatus {
  initial,
  lowRating,
  highRating,
  submitting,
  success,
  alreadyRated,
  windowExpired,
}

enum RatingSentiment {
  unrated,
  poor,
  fair,
  good,
  great,
  excellent,
}

class RatingTag {
  final String id;
  final String label;
  final bool isNegative;

  const RatingTag({
    required this.id,
    required this.label,
    this.isNegative = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RatingTag && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DriverRatingProfile {
  final String name;
  final double rating;
  final String vehicleName;
  final String cabNumber;
  final String? photoUrl;
  final bool isVerified;
  final bool isLocked;

  const DriverRatingProfile({
    this.name = 'Michael K.',
    this.rating = 4.8,
    this.vehicleName = 'Silver Toyota RAV4',
    this.cabNumber = 'BCC • Vehicle #892',
    this.photoUrl,
    this.isVerified = true,
    this.isLocked = false,
  });

  DriverRatingProfile copyWith({
    String? name,
    double? rating,
    String? vehicleName,
    String? cabNumber,
    String? photoUrl,
    bool? isVerified,
    bool? isLocked,
  }) {
    return DriverRatingProfile(
      name: name ?? this.name,
      rating: rating ?? this.rating,
      vehicleName: vehicleName ?? this.vehicleName,
      cabNumber: cabNumber ?? this.cabNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      isVerified: isVerified ?? this.isVerified,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

class TripSummaryInfo {
  final String tripId;
  final String route;
  final String pickupAddress;
  final String dropoffAddress;
  final double fareCad;
  final String completedAt;
  final String transitZone;

  const TripSummaryInfo({
    this.tripId = 'BC-84920',
    this.route = 'Scenic Heights → Downtown',
    this.pickupAddress = '515 5th Ave S, Downtown Lethbridge',
    this.dropoffAddress = 'Park Place Mall (Main Entrance)',
    this.fareCad = 16.40,
    this.completedAt = 'Today at 2:45 PM',
    this.transitZone = 'Lethbridge Transit Zone',
  });

  String get formattedFare => '\$${fareCad.toStringAsFixed(2)} CAD';

  TripSummaryInfo copyWith({
    String? tripId,
    String? route,
    String? pickupAddress,
    String? dropoffAddress,
    double? fareCad,
    String? completedAt,
    String? transitZone,
  }) {
    return TripSummaryInfo(
      tripId: tripId ?? this.tripId,
      route: route ?? this.route,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      fareCad: fareCad ?? this.fareCad,
      completedAt: completedAt ?? this.completedAt,
      transitZone: transitZone ?? this.transitZone,
    );
  }
}
