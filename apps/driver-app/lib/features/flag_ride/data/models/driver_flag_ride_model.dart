import 'package:equatable/equatable.dart';
import 'driver_flag_edge_state.dart';
import 'driver_flag_quick_change.dart';

class DriverFlagRideModel extends Equatable {
  final String flagTripId;
  final int unitNumber;
  final String assignedVehicle;
  final String assignedCarId;
  final String gpsSignalLevel;
  final String zone;
  final String pickupAddress;
  final String dropoffAddress;
  final String dropoffPostal;
  final int passengerCount;
  final double estimatedFareCad;
  final double computedFareCad;
  final double subtotalMeterFare;
  final double gstAlberta;
  final double netEarning;
  final int tripProgressPercent;
  final double distanceRemainingKm;
  final double distanceTotalKm;
  final int durationMinutes;
  final String durationFormatted;
  final String etaText;
  final int currentSpeedKmh;
  final double baseRateCad;
  final double perKmRateCad;
  final bool isMeterRunning;
  final bool isCashCollected;
  final List<DriverFlagQuickChange> quickChangeOptions;
  final DriverFlagEdgeModel edgeModel;

  const DriverFlagRideModel({
    this.flagTripId = 'FL-88214',
    this.unitNumber = 42,
    this.assignedVehicle = 'Medium (Camry Hybrid)',
    this.assignedCarId = 'Car #104 Assigned',
    this.gpsSignalLevel = 'HIGH',
    this.zone = 'Downtown Zone 1',
    this.pickupAddress = '524 4th Ave S, Downtown Lethbridge',
    this.dropoffAddress = '440 University Dr W',
    this.dropoffPostal = 'West Lethbridge, AB T1K 3M4',
    this.passengerCount = 2,
    this.estimatedFareCad = 15.00,
    this.computedFareCad = 12.40,
    this.subtotalMeterFare = 17.71,
    this.gstAlberta = 0.89,
    this.netEarning = 15.81,
    this.tripProgressPercent = 57,
    this.distanceRemainingKm = 1.8,
    this.distanceTotalKm = 4.2,
    this.durationMinutes = 12,
    this.durationFormatted = '06:35',
    this.etaText = '~4 mins to West Side',
    this.currentSpeedKmh = 48,
    this.baseRateCad = 3.80,
    this.perKmRateCad = 1.85,
    this.isMeterRunning = true,
    this.isCashCollected = false,
    this.quickChangeOptions = const [
      DriverFlagQuickChange(tenderAmount: 20.00, fareAmount: 18.60),
      DriverFlagQuickChange(tenderAmount: 25.00, fareAmount: 18.60),
    ],
    this.edgeModel = const DriverFlagEdgeModel(),
  });

  DriverFlagRideModel copyWith({
    String? flagTripId,
    int? unitNumber,
    String? assignedVehicle,
    String? assignedCarId,
    String? gpsSignalLevel,
    String? zone,
    String? pickupAddress,
    String? dropoffAddress,
    String? dropoffPostal,
    int? passengerCount,
    double? estimatedFareCad,
    double? computedFareCad,
    double? subtotalMeterFare,
    double? gstAlberta,
    double? netEarning,
    int? tripProgressPercent,
    double? distanceRemainingKm,
    double? distanceTotalKm,
    int? durationMinutes,
    String? durationFormatted,
    String? etaText,
    int? currentSpeedKmh,
    double? baseRateCad,
    double? perKmRateCad,
    bool? isMeterRunning,
    bool? isCashCollected,
    List<DriverFlagQuickChange>? quickChangeOptions,
    DriverFlagEdgeModel? edgeModel,
  }) {
    return DriverFlagRideModel(
      flagTripId: flagTripId ?? this.flagTripId,
      unitNumber: unitNumber ?? this.unitNumber,
      assignedVehicle: assignedVehicle ?? this.assignedVehicle,
      assignedCarId: assignedCarId ?? this.assignedCarId,
      gpsSignalLevel: gpsSignalLevel ?? this.gpsSignalLevel,
      zone: zone ?? this.zone,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      dropoffPostal: dropoffPostal ?? this.dropoffPostal,
      passengerCount: passengerCount ?? this.passengerCount,
      estimatedFareCad: estimatedFareCad ?? this.estimatedFareCad,
      computedFareCad: computedFareCad ?? this.computedFareCad,
      subtotalMeterFare: subtotalMeterFare ?? this.subtotalMeterFare,
      gstAlberta: gstAlberta ?? this.gstAlberta,
      netEarning: netEarning ?? this.netEarning,
      tripProgressPercent: tripProgressPercent ?? this.tripProgressPercent,
      distanceRemainingKm: distanceRemainingKm ?? this.distanceRemainingKm,
      distanceTotalKm: distanceTotalKm ?? this.distanceTotalKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      durationFormatted: durationFormatted ?? this.durationFormatted,
      etaText: etaText ?? this.etaText,
      currentSpeedKmh: currentSpeedKmh ?? this.currentSpeedKmh,
      baseRateCad: baseRateCad ?? this.baseRateCad,
      perKmRateCad: perKmRateCad ?? this.perKmRateCad,
      isMeterRunning: isMeterRunning ?? this.isMeterRunning,
      isCashCollected: isCashCollected ?? this.isCashCollected,
      quickChangeOptions: quickChangeOptions ?? this.quickChangeOptions,
      edgeModel: edgeModel ?? this.edgeModel,
    );
  }

  @override
  List<Object?> get props => [
        flagTripId,
        unitNumber,
        assignedVehicle,
        assignedCarId,
        gpsSignalLevel,
        zone,
        pickupAddress,
        dropoffAddress,
        dropoffPostal,
        passengerCount,
        estimatedFareCad,
        computedFareCad,
        subtotalMeterFare,
        gstAlberta,
        netEarning,
        tripProgressPercent,
        distanceRemainingKm,
        distanceTotalKm,
        durationMinutes,
        durationFormatted,
        etaText,
        currentSpeedKmh,
        baseRateCad,
        perKmRateCad,
        isMeterRunning,
        isCashCollected,
        quickChangeOptions,
        edgeModel,
      ];
}
