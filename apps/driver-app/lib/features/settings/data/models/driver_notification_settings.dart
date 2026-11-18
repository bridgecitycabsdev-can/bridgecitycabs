import 'package:equatable/equatable.dart';

enum DriverDispatchChime {
  bridgeCityChime,
  lethbridgePulse,
  highAlertHorn,
}

extension DriverDispatchChimeX on DriverDispatchChime {
  String get title {
    switch (this) {
      case DriverDispatchChime.bridgeCityChime:
        return 'Bridge City Chime';
      case DriverDispatchChime.lethbridgePulse:
        return 'Lethbridge Pulse';
      case DriverDispatchChime.highAlertHorn:
        return 'High Alert Horn';
    }
  }

  String get subtitle {
    switch (this) {
      case DriverDispatchChime.bridgeCityChime:
        return 'Default dispatch chime';
      case DriverDispatchChime.lethbridgePulse:
        return 'Dual low tone sequence';
      case DriverDispatchChime.highAlertHorn:
        return 'Loud siren for highway speeds';
    }
  }
}

class DriverNotificationSettings extends Equatable {
  final bool isPermissionGranted;
  final bool rideRequestsAlert;
  final bool tripUpdatesAlert;
  final bool earningsStatementsAlert;
  final bool promotionsAlert;
  final DriverDispatchChime selectedChime;
  final bool vibrationPattern;
  final bool inCabPriorityAudio;

  const DriverNotificationSettings({
    this.isPermissionGranted = false,
    this.rideRequestsAlert = true,
    this.tripUpdatesAlert = true,
    this.earningsStatementsAlert = true,
    this.promotionsAlert = false,
    this.selectedChime = DriverDispatchChime.bridgeCityChime,
    this.vibrationPattern = true,
    this.inCabPriorityAudio = true,
  });

  int get activeAlertsCount {
    int count = 0;
    if (rideRequestsAlert) count++;
    if (tripUpdatesAlert) count++;
    if (earningsStatementsAlert) count++;
    if (promotionsAlert) count++;
    return count;
  }

  DriverNotificationSettings copyWith({
    bool? isPermissionGranted,
    bool? rideRequestsAlert,
    bool? tripUpdatesAlert,
    bool? earningsStatementsAlert,
    bool? promotionsAlert,
    DriverDispatchChime? selectedChime,
    bool? vibrationPattern,
    bool? inCabPriorityAudio,
  }) {
    return DriverNotificationSettings(
      isPermissionGranted: isPermissionGranted ?? this.isPermissionGranted,
      rideRequestsAlert: rideRequestsAlert ?? this.rideRequestsAlert,
      tripUpdatesAlert: tripUpdatesAlert ?? this.tripUpdatesAlert,
      earningsStatementsAlert:
          earningsStatementsAlert ?? this.earningsStatementsAlert,
      promotionsAlert: promotionsAlert ?? this.promotionsAlert,
      selectedChime: selectedChime ?? this.selectedChime,
      vibrationPattern: vibrationPattern ?? this.vibrationPattern,
      inCabPriorityAudio: inCabPriorityAudio ?? this.inCabPriorityAudio,
    );
  }

  @override
  List<Object?> get props => [
    isPermissionGranted,
    rideRequestsAlert,
    tripUpdatesAlert,
    earningsStatementsAlert,
    promotionsAlert,
    selectedChime,
    vibrationPattern,
    inCabPriorityAudio,
  ];
}
