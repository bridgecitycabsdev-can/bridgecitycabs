import 'package:equatable/equatable.dart';

class DriverHomeMetrics extends Equatable {
  final double todayEarnings;
  final bool isEarningsLocked;
  final int ridesToday;
  final int acceptanceRate;
  final String onlineTime;
  final int pingMs;
  final String? shiftStartTime;
  final String currentLocationName;
  final String fleetUnit;

  const DriverHomeMetrics({
    this.todayEarnings = 41.77,
    this.isEarningsLocked = false,
    this.ridesToday = 1,
    this.acceptanceRate = 50,
    this.onlineTime = '2h 15m',
    this.pingMs = 18,
    this.shiftStartTime = '07:45 AM',
    this.currentLocationName = 'Downtown Lethbridge • 3 Ave S',
    this.fleetUnit = 'Unit 42',
  });

  DriverHomeMetrics copyWith({
    double? todayEarnings,
    bool? isEarningsLocked,
    int? ridesToday,
    int? acceptanceRate,
    String? onlineTime,
    int? pingMs,
    String? shiftStartTime,
    String? currentLocationName,
    String? fleetUnit,
  }) {
    return DriverHomeMetrics(
      todayEarnings: todayEarnings ?? this.todayEarnings,
      isEarningsLocked: isEarningsLocked ?? this.isEarningsLocked,
      ridesToday: ridesToday ?? this.ridesToday,
      acceptanceRate: acceptanceRate ?? this.acceptanceRate,
      onlineTime: onlineTime ?? this.onlineTime,
      pingMs: pingMs ?? this.pingMs,
      shiftStartTime: shiftStartTime ?? this.shiftStartTime,
      currentLocationName: currentLocationName ?? this.currentLocationName,
      fleetUnit: fleetUnit ?? this.fleetUnit,
    );
  }

  @override
  List<Object?> get props => [
        todayEarnings,
        isEarningsLocked,
        ridesToday,
        acceptanceRate,
        onlineTime,
        pingMs,
        shiftStartTime,
        currentLocationName,
        fleetUnit,
      ];
}
