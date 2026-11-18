import 'package:equatable/equatable.dart';
import 'driver_application_milestone.dart';

class DriverRegisterStep4Data extends Equatable {
  final String driverName;
  final String vehicleModel;
  final int vehicleYear;
  final String licensePlate;
  final String fleetId;
  final String fleetTag;
  final String operatingHub;
  final List<DriverApplicationMilestone> milestones;
  final String? alertTitle;
  final String? alertMessage;
  final String? flaggedDocumentName;
  final String? flaggedDocumentReason;
  final String lastSyncedTime;
  final String offlinePhone;

  const DriverRegisterStep4Data({
    this.driverName = 'Marcus Vance',
    this.vehicleModel = 'Toyota Camry Hybrid',
    this.vehicleYear = 2021,
    this.licensePlate = 'AB · BCC-9482',
    this.fleetId = '#409',
    this.fleetTag = 'Active Partner',
    this.operatingHub = 'Lethbridge Downtown & Airport',
    this.milestones = const [],
    this.alertTitle,
    this.alertMessage,
    this.flaggedDocumentName,
    this.flaggedDocumentReason,
    this.lastSyncedTime = '2:14 PM',
    this.offlinePhone = '403-328-8888',
  });

  DriverRegisterStep4Data copyWith({
    String? driverName,
    String? vehicleModel,
    int? vehicleYear,
    String? licensePlate,
    String? fleetId,
    String? fleetTag,
    String? operatingHub,
    List<DriverApplicationMilestone>? milestones,
    String? alertTitle,
    String? alertMessage,
    String? flaggedDocumentName,
    String? flaggedDocumentReason,
    String? lastSyncedTime,
    String? offlinePhone,
  }) {
    return DriverRegisterStep4Data(
      driverName: driverName ?? this.driverName,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleYear: vehicleYear ?? this.vehicleYear,
      licensePlate: licensePlate ?? this.licensePlate,
      fleetId: fleetId ?? this.fleetId,
      fleetTag: fleetTag ?? this.fleetTag,
      operatingHub: operatingHub ?? this.operatingHub,
      milestones: milestones ?? this.milestones,
      alertTitle: alertTitle ?? this.alertTitle,
      alertMessage: alertMessage ?? this.alertMessage,
      flaggedDocumentName: flaggedDocumentName ?? this.flaggedDocumentName,
      flaggedDocumentReason:
          flaggedDocumentReason ?? this.flaggedDocumentReason,
      lastSyncedTime: lastSyncedTime ?? this.lastSyncedTime,
      offlinePhone: offlinePhone ?? this.offlinePhone,
    );
  }

  @override
  List<Object?> get props => [
        driverName,
        vehicleModel,
        vehicleYear,
        licensePlate,
        fleetId,
        fleetTag,
        operatingHub,
        milestones,
        alertTitle,
        alertMessage,
        flaggedDocumentName,
        flaggedDocumentReason,
        lastSyncedTime,
        offlinePhone,
      ];
}
