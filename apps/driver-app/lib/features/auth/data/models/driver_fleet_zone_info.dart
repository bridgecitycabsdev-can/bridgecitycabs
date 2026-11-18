import 'package:equatable/equatable.dart';

enum FleetInfoCardType {
  surgeActive,
  registeredFleet,
  cityFleet247,
  dispatchRadioHelp,
}

class DriverFleetZoneInfo extends Equatable {
  final FleetInfoCardType type;
  final String title;
  final String subtitle;
  final String? badgeText;
  final bool isBadgeGreen;

  const DriverFleetZoneInfo({
    required this.type,
    required this.title,
    required this.subtitle,
    this.badgeText,
    this.isBadgeGreen = true,
  });

  static const DriverFleetZoneInfo surgeActive = DriverFleetZoneInfo(
    type: FleetInfoCardType.surgeActive,
    title: 'Lethbridge Fleet Zone',
    subtitle: 'High demand near Downtown & West Lethbridge',
    badgeText: '● Surge Active',
    isBadgeGreen: true,
  );

  static const DriverFleetZoneInfo registeredFleet = DriverFleetZoneInfo(
    type: FleetInfoCardType.registeredFleet,
    title: 'Registered Fleet Drivers',
    subtitle:
        'A verification code will be sent via SMS to verify your registered Lethbridge permit vehicle.',
    badgeText: null,
  );

  static const DriverFleetZoneInfo cityFleet = DriverFleetZoneInfo(
    type: FleetInfoCardType.cityFleet247,
    title: 'Lethbridge City Fleet',
    subtitle: 'Fast automated dispatch active',
    badgeText: 'Fleet 24/7',
    isBadgeGreen: true,
  );

  @override
  List<Object?> get props => [type, title, subtitle, badgeText, isBadgeGreen];
}
