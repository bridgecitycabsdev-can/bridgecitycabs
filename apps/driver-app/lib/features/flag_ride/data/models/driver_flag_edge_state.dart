import 'package:equatable/equatable.dart';

enum DriverFlagEdgeStateType {
  telemetryFault(
    'STATE 01 • TELEMETRY FAULT',
    "Can't find your location",
    'Turn on GPS to start a flag ride. High-precision vehicle coordinates are required under municipal taxi regulations.',
  ),
  routeConflict(
    'STATE 02 • ROUTE CONFLICT',
    'Finish current trip before flagging',
    'Active booking takes precedence. Multiple concurrent meters are strictly disabled.',
  ),
  authorizationOffline(
    'STATE 03 • AUTHORIZATION',
    'Flag Rides Unavailable',
    'Driver Status: OFFLINE (Shift verification pending). You must establish active duty to accept street passengers.',
  ),
  initializingMeter(
    'STATE 04 • INITIALIZING METER',
    'Drop Flag Tariff Rate \$4.10 Flat Base',
    'Calibrating virtual taximeter against Lethbridge digital zone coordinates...',
  ),
  telemetryTimeout(
    'STATE 05 • TELEMETRY TIMEOUT',
    "Couldn't start the trip",
    'Dispatch telemetry timeout. Cellular connection dropped near River Valley coulees.',
  ),
  fareResolution(
    'STATE 06 • FARE RESOLUTION',
    "We're calculating your fare...",
    'Syncing GPS odometer logs with City of Lethbridge rates (\$2.05/km + \$0.70/min wait).',
  ),
  localBlackoutMode(
    'STATE 07 • LOCAL BLACKOUT MODE',
    "You're offline",
    "Shift trip recorded locally via device accelerometer and hardware odometer. We'll automatically sync this trip when cell connectivity reconnects.",
  );

  final String header;
  final String title;
  final String message;

  const DriverFlagEdgeStateType(
    this.header,
    this.title,
    this.message,
  );
}

class DriverFlagEdgeModel extends Equatable {
  final int activeCategory; // 1: GPS Lost, 2: Active Route, 3: Offline Lock
  final DriverFlagEdgeStateType? selectedEdgeState;

  const DriverFlagEdgeModel({
    this.activeCategory = 1,
    this.selectedEdgeState,
  });

  DriverFlagEdgeModel copyWith({
    int? activeCategory,
    DriverFlagEdgeStateType? selectedEdgeState,
  }) {
    return DriverFlagEdgeModel(
      activeCategory: activeCategory ?? this.activeCategory,
      selectedEdgeState: selectedEdgeState ?? this.selectedEdgeState,
    );
  }

  @override
  List<Object?> get props => [activeCategory, selectedEdgeState];
}
