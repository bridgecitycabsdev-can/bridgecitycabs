import 'package:equatable/equatable.dart';

class DriverMenuStats extends Equatable {
  final double todayEarnings;
  final int ridesCompleted;
  final double distanceKm;
  final String? shiftPrompt;

  const DriverMenuStats({
    this.todayEarnings = 41.77,
    this.ridesCompleted = 1,
    this.distanceKm = 10.0,
    this.shiftPrompt,
  });

  DriverMenuStats copyWith({
    double? todayEarnings,
    int? ridesCompleted,
    double? distanceKm,
    String? shiftPrompt,
  }) {
    return DriverMenuStats(
      todayEarnings: todayEarnings ?? this.todayEarnings,
      ridesCompleted: ridesCompleted ?? this.ridesCompleted,
      distanceKm: distanceKm ?? this.distanceKm,
      shiftPrompt: shiftPrompt ?? this.shiftPrompt,
    );
  }

  @override
  List<Object?> get props => [
    todayEarnings,
    ridesCompleted,
    distanceKm,
    shiftPrompt,
  ];
}
