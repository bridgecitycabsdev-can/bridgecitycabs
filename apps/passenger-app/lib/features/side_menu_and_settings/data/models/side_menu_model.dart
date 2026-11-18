import 'package:equatable/equatable.dart';

enum SideMenuLayout {
  grid,
  list;

  String get label => this == SideMenuLayout.grid ? 'Grid View' : 'List View';
}

enum QaSideMenuState {
  defaultState,
  unreadBadge,
  liveTripActive;

  String get chipLabel {
    switch (this) {
      case QaSideMenuState.defaultState:
        return '1. Default';
      case QaSideMenuState.unreadBadge:
        return '2. Unread Badge';
      case QaSideMenuState.liveTripActive:
        return '3. Live Trip Active';
    }
  }
}

class SideMenuProfile extends Equatable {
  final String name;
  final String phone;
  final double rating;
  final int totalRides;
  final bool isVerified;
  final String avatarUrl;

  const SideMenuProfile({
    required this.name,
    required this.phone,
    this.rating = 4.96,
    this.totalRides = 48,
    this.isVerified = false,
    this.avatarUrl = '',
  });

  static const marcus = SideMenuProfile(
    name: 'Marcus Vance',
    phone: '+1 (403) ••• ••17',
    rating: 4.96,
    totalRides: 48,
    isVerified: false,
  );

  String get phoneNumber => phone;

  int get rideCount => totalRides;

  static const clara = SideMenuProfile(
    name: 'Clara Henderson',
    phone: '+1 (403) 555-0198',
    rating: 4.96,
    totalRides: 64,
    isVerified: true,
  );

  @override
  List<Object?> get props => [name, phone, rating, totalRides, isVerified, avatarUrl];
}

class ActiveTripBannerData extends Equatable {
  final String vehicleName;
  final String driverName;
  final int etaMinutes;
  final String statusText;
  final String arrivingText;

  const ActiveTripBannerData({
    this.vehicleName = 'Camry SE',
    this.driverName = 'Marcus V.',
    this.etaMinutes = 4,
    this.statusText = 'Trip in progress',
    this.arrivingText = 'Arriving in ~4 mins',
  });

  String get vehicleModel => vehicleName;

  String get topBannerText => '$statusText • $vehicleName ($driverName) ➔';

  @override
  List<Object?> get props => [vehicleName, driverName, etaMinutes, statusText, arrivingText];
}
