import 'package:equatable/equatable.dart';

class DriverMenuProfile extends Equatable {
  final String name;
  final double rating;
  final int totalRides;
  final String? avatarUrl;
  final String fleetUnit;
  final String municipalPermit;
  final String? shiftDuration;
  final String fleetZone;

  const DriverMenuProfile({
    this.name = 'Shajil Kunhumon',
    this.rating = 4.9,
    this.totalRides = 120,
    this.avatarUrl,
    this.fleetUnit = 'LETHBRIDGE FLEET UNIT #42',
    this.municipalPermit = 'City Permit LIC-4812',
    this.shiftDuration,
    this.fleetZone = 'Lethbridge Fleet Zone 01',
  });

  DriverMenuProfile copyWith({
    String? name,
    double? rating,
    int? totalRides,
    String? avatarUrl,
    String? fleetUnit,
    String? municipalPermit,
    String? shiftDuration,
    String? fleetZone,
  }) {
    return DriverMenuProfile(
      name: name ?? this.name,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      fleetUnit: fleetUnit ?? this.fleetUnit,
      municipalPermit: municipalPermit ?? this.municipalPermit,
      shiftDuration: shiftDuration ?? this.shiftDuration,
      fleetZone: fleetZone ?? this.fleetZone,
    );
  }

  @override
  List<Object?> get props => [
    name,
    rating,
    totalRides,
    avatarUrl,
    fleetUnit,
    municipalPermit,
    shiftDuration,
    fleetZone,
  ];
}
