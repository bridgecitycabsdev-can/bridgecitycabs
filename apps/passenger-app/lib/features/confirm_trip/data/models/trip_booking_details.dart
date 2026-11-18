import 'package:equatable/equatable.dart';

class TripBookingDetails extends Equatable {
  final String pickupAddress;
  final String dropoffAddress;
  final String vehicleName;
  final String vehicleTag;
  final int vehicleEtaMinutes;
  final int seats;
  final double distanceKm;
  final int durationMinutes;
  final String pickupTime;
  final String? driverNotes;

  const TripBookingDetails({
    this.pickupAddress = '515 5th Ave S, Downtown Lethbridge',
    this.dropoffAddress = 'Park Place Mall, Main Entrance (North Bay)',
    this.vehicleName = 'SUV • Big',
    this.vehicleTag = '6 seats',
    this.vehicleEtaMinutes = 4,
    this.seats = 6,
    this.distanceKm = 4.8,
    this.durationMinutes = 7,
    this.pickupTime = 'Now',
    this.driverNotes,
  });

  String get statsText => '$distanceKm km • $durationMinutes min trip';

  TripBookingDetails copyWith({
    String? pickupAddress,
    String? dropoffAddress,
    String? vehicleName,
    String? vehicleTag,
    int? vehicleEtaMinutes,
    int? seats,
    double? distanceKm,
    int? durationMinutes,
    String? pickupTime,
    String? driverNotes,
  }) {
    return TripBookingDetails(
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      vehicleName: vehicleName ?? this.vehicleName,
      vehicleTag: vehicleTag ?? this.vehicleTag,
      vehicleEtaMinutes: vehicleEtaMinutes ?? this.vehicleEtaMinutes,
      seats: seats ?? this.seats,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      pickupTime: pickupTime ?? this.pickupTime,
      driverNotes: driverNotes ?? this.driverNotes,
    );
  }

  @override
  List<Object?> get props => [
        pickupAddress,
        dropoffAddress,
        vehicleName,
        vehicleTag,
        vehicleEtaMinutes,
        seats,
        distanceKm,
        durationMinutes,
        pickupTime,
        driverNotes,
      ];
}
