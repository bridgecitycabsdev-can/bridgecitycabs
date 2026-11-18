import 'package:equatable/equatable.dart';

class DriverSurgeZone extends Equatable {
  final double multiplier;
  final String title;
  final String subtitle;
  final String areaName;

  const DriverSurgeZone({
    this.multiplier = 1.3,
    this.title = 'High demand near...',
    this.subtitle = '1.3x request surge in 4t...',
    this.areaName = 'Legacy Ridge / Old Man River',
  });

  @override
  List<Object?> get props => [multiplier, title, subtitle, areaName];
}
