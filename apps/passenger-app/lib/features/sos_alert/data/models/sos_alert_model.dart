import 'package:equatable/equatable.dart';

enum SosAlertStatus {
  readyToSend,
  sending,
  active,
  failed,
  cancelled,
}

enum LocationServiceStatus {
  enabled,
  disabled,
}

class SosRideTelemetry extends Equatable {
  final String tripId;
  final String driverName;
  final String vehicleModel;
  final String vehicleColor;
  final String vehiclePlate;
  final String cabNumber;
  final String currentAddress;
  final String lastKnownPosition;
  final String accuracyLabel;
  final String routeStatus;

  const SosRideTelemetry({
    required this.tripId,
    required this.driverName,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.vehiclePlate,
    required this.cabNumber,
    required this.currentAddress,
    required this.lastKnownPosition,
    this.accuracyLabel = 'Accurate GPS fix • Updated 3s ago',
    this.routeStatus = 'En route to Destination • In Progress',
  });

  SosRideTelemetry copyWith({
    String? tripId,
    String? driverName,
    String? vehicleModel,
    String? vehicleColor,
    String? vehiclePlate,
    String? cabNumber,
    String? currentAddress,
    String? lastKnownPosition,
    String? accuracyLabel,
    String? routeStatus,
  }) {
    return SosRideTelemetry(
      tripId: tripId ?? this.tripId,
      driverName: driverName ?? this.driverName,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      cabNumber: cabNumber ?? this.cabNumber,
      currentAddress: currentAddress ?? this.currentAddress,
      lastKnownPosition: lastKnownPosition ?? this.lastKnownPosition,
      accuracyLabel: accuracyLabel ?? this.accuracyLabel,
      routeStatus: routeStatus ?? this.routeStatus,
    );
  }

  @override
  List<Object?> get props => [
        tripId,
        driverName,
        vehicleModel,
        vehicleColor,
        vehiclePlate,
        cabNumber,
        currentAddress,
        lastKnownPosition,
        accuracyLabel,
        routeStatus,
      ];
}
