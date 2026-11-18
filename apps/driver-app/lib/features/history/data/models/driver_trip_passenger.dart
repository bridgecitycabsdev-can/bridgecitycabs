import 'package:equatable/equatable.dart';

class DriverTripPassenger extends Equatable {
  final String name;
  final String? avatarUrl;
  final double rating;
  final int totalRides;
  final bool isVerified;
  final String verificationText;

  const DriverTripPassenger({
    this.name = 'Jordan S.',
    this.avatarUrl,
    this.rating = 4.9,
    this.totalRides = 114,
    this.isVerified = true,
    this.verificationText = 'Passenger verification verified',
  });

  DriverTripPassenger copyWith({
    String? name,
    String? avatarUrl,
    double? rating,
    int? totalRides,
    bool? isVerified,
    String? verificationText,
  }) {
    return DriverTripPassenger(
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      isVerified: isVerified ?? this.isVerified,
      verificationText: verificationText ?? this.verificationText,
    );
  }

  @override
  List<Object?> get props => [
    name,
    avatarUrl,
    rating,
    totalRides,
    isVerified,
    verificationText,
  ];
}
