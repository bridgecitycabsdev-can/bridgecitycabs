import 'package:equatable/equatable.dart';
import 'driver_trip_fare_breakdown.dart';
import 'driver_trip_passenger.dart';

class DriverTripRecord extends Equatable {
  final String id;
  final String dateFormatted;
  final String unitNumber;
  final String status;
  final String manifestType;
  final String pickupTime;
  final String pickupAddress;
  final String pickupSubtitle;
  final String dropoffTime;
  final String dropoffAddress;
  final String dropoffSubtitle;
  final double distanceKm;
  final int durationMinutes;
  final int avgSpeedKmh;
  final double fare;
  final String? fareNote;
  final DriverTripFareBreakdown? fareBreakdown;
  final DriverTripPassenger passenger;

  const DriverTripRecord({
    required this.id,
    required this.dateFormatted,
    this.unitNumber = 'Lethbridge Unit #42',
    this.status = 'COMPLETED',
    this.manifestType = 'ARCHIVED MANIFEST',
    required this.pickupTime,
    required this.pickupAddress,
    this.pickupSubtitle = '',
    required this.dropoffTime,
    required this.dropoffAddress,
    this.dropoffSubtitle = '',
    this.distanceKm = 4.52,
    this.durationMinutes = 14,
    this.avgSpeedKmh = 38,
    this.fare = 20.19,
    this.fareNote,
    this.fareBreakdown,
    this.passenger = const DriverTripPassenger(),
  });

  bool get isCancelled => status.toUpperCase() == 'CANCELLED';
  bool get isCompleted => status.toUpperCase() == 'COMPLETED';

  DriverTripRecord copyWith({
    String? id,
    String? dateFormatted,
    String? unitNumber,
    String? status,
    String? manifestType,
    String? pickupTime,
    String? pickupAddress,
    String? pickupSubtitle,
    String? dropoffTime,
    String? dropoffAddress,
    String? dropoffSubtitle,
    double? distanceKm,
    int? durationMinutes,
    int? avgSpeedKmh,
    double? fare,
    String? fareNote,
    DriverTripFareBreakdown? fareBreakdown,
    DriverTripPassenger? passenger,
  }) {
    return DriverTripRecord(
      id: id ?? this.id,
      dateFormatted: dateFormatted ?? this.dateFormatted,
      unitNumber: unitNumber ?? this.unitNumber,
      status: status ?? this.status,
      manifestType: manifestType ?? this.manifestType,
      pickupTime: pickupTime ?? this.pickupTime,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupSubtitle: pickupSubtitle ?? this.pickupSubtitle,
      dropoffTime: dropoffTime ?? this.dropoffTime,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      dropoffSubtitle: dropoffSubtitle ?? this.dropoffSubtitle,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      avgSpeedKmh: avgSpeedKmh ?? this.avgSpeedKmh,
      fare: fare ?? this.fare,
      fareNote: fareNote ?? this.fareNote,
      fareBreakdown: fareBreakdown ?? this.fareBreakdown,
      passenger: passenger ?? this.passenger,
    );
  }

  @override
  List<Object?> get props => [
    id,
    dateFormatted,
    unitNumber,
    status,
    manifestType,
    pickupTime,
    pickupAddress,
    pickupSubtitle,
    dropoffTime,
    dropoffAddress,
    dropoffSubtitle,
    distanceKm,
    durationMinutes,
    avgSpeedKmh,
    fare,
    fareNote,
    fareBreakdown,
    passenger,
  ];
}
