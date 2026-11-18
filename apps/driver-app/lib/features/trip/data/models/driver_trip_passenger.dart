import 'package:equatable/equatable.dart';

class DriverTripPassenger extends Equatable {
  final String id;
  final String name;
  final String initials;
  final double rating;
  final int completedRides;
  final String membershipBadge;
  final String? avatarUrl;
  final String phone;
  final String vehicleClass;
  final String paymentMethod;
  final String serviceZone;
  final bool isVerified;

  const DriverTripPassenger({
    required this.id,
    required this.name,
    this.initials = 'AM',
    this.rating = 4.8,
    this.completedRides = 42,
    this.membershipBadge = 'Bridge City Regular',
    this.avatarUrl,
    this.phone = '+1 (403) 555-0192',
    this.vehicleClass = 'SEDAN',
    this.paymentMethod = 'CASH',
    this.serviceZone = 'Lethbridge West',
    this.isVerified = true,
  });

  String get serviceSummary => '$vehicleClass • $paymentMethod';

  @override
  List<Object?> get props => [
        id,
        name,
        initials,
        rating,
        completedRides,
        membershipBadge,
        avatarUrl,
        phone,
        vehicleClass,
        paymentMethod,
        serviceZone,
        isVerified,
      ];
}
