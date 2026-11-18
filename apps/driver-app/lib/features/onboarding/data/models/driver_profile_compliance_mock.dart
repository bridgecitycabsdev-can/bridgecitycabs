import 'package:equatable/equatable.dart';

class DriverProfileComplianceMock extends Equatable {
  final String driverName;
  final String fleetTag;
  final double rating;
  final int matchPercentage;
  final String supportTitle;
  final String supportSubtitle;
  final String complianceTitle;
  final String complianceSubtitle;
  final bool isVerified;
  final String totalRidesFormatted;

  const DriverProfileComplianceMock({
    this.driverName = 'Jesse C.',
    this.fleetTag = 'Lethbridge Fleet',
    this.rating = 4.98,
    this.matchPercentage = 98,
    this.supportTitle = '24/7 DRIVER SUPPORT',
    this.supportSubtitle = 'Priority in-app team line',
    this.complianceTitle = 'Alberta Class 4 & Inspection',
    this.complianceSubtitle = 'Active Provincial Compliance',
    this.isVerified = true,
    this.totalRidesFormatted = '1,420+',
  });

  @override
  List<Object?> get props => [
        driverName,
        fleetTag,
        rating,
        matchPercentage,
        supportTitle,
        supportSubtitle,
        complianceTitle,
        complianceSubtitle,
        isVerified,
        totalRidesFormatted,
      ];
}
