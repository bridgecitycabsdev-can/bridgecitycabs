import 'package:equatable/equatable.dart';
import 'driver_assigned_vehicle.dart';
import 'driver_credential_model.dart';
import 'driver_profile_status.dart';

class DriverProfileData extends Equatable {
  final String fullName;
  final String email;
  final String phone;
  final String licenseNumber;
  final String gender;
  final double? rating;
  final int reviewCount;
  final double todayEarnings;
  final double todayTips;
  final int todayRides;
  final double todayKm;
  final bool isOnline;
  final bool isVerifiedFleet;
  final DriverAssignedVehicle assignedVehicle;
  final List<DriverCredentialModel> credentials;
  final DriverProfileStatus status;

  const DriverProfileData({
    this.fullName = 'Shajil Kunhumon',
    this.email = 's.kunhumon@bridgecity.ca',
    this.phone = '+1 (403) 555-0192',
    this.licenseNumber = 'AB-DL-982104-X',
    this.gender = 'Male',
    this.rating = 4.9,
    this.reviewCount = 120,
    this.todayEarnings = 41.77,
    this.todayTips = 0.00,
    this.todayRides = 1,
    this.todayKm = 10.0,
    this.isOnline = true,
    this.isVerifiedFleet = true,
    this.assignedVehicle = const DriverAssignedVehicle(),
    this.credentials = const [],
    this.status = DriverProfileStatus.activeOnline,
  });

  DriverProfileData copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? licenseNumber,
    String? gender,
    double? rating,
    int? reviewCount,
    double? todayEarnings,
    double? todayTips,
    int? todayRides,
    double? todayKm,
    bool? isOnline,
    bool? isVerifiedFleet,
    DriverAssignedVehicle? assignedVehicle,
    List<DriverCredentialModel>? credentials,
    DriverProfileStatus? status,
  }) {
    return DriverProfileData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      gender: gender ?? this.gender,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      todayTips: todayTips ?? this.todayTips,
      todayRides: todayRides ?? this.todayRides,
      todayKm: todayKm ?? this.todayKm,
      isOnline: isOnline ?? this.isOnline,
      isVerifiedFleet: isVerifiedFleet ?? this.isVerifiedFleet,
      assignedVehicle: assignedVehicle ?? this.assignedVehicle,
      credentials: credentials ?? this.credentials,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    fullName,
    email,
    phone,
    licenseNumber,
    gender,
    rating,
    reviewCount,
    todayEarnings,
    todayTips,
    todayRides,
    todayKm,
    isOnline,
    isVerifiedFleet,
    assignedVehicle,
    credentials,
    status,
  ];
}
