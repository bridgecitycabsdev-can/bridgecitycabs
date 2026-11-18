import 'package:equatable/equatable.dart';
import 'driver_cancel_reason.dart';
import 'driver_trip_passenger.dart';

class DriverTripModel extends Equatable {
  final String tripId;
  final int unitNumber;
  final DriverTripPassenger passenger;
  final String pickupAddress;
  final String pickupSecondary;
  final String pickupNote;
  final String dropoffAddress;
  final String dropoffSecondary;
  final String? scheduledTime;
  final bool luggageAssistRequested;
  final double distanceKm;
  final int etaMinutes;
  final int distanceAwayMeters;
  final int proximityLockThresholdMeters;
  final int currentSpeedKmh;
  final String nextTurnGuidance;
  final int waitTimeElapsedSeconds;
  final int freeWaitLimitSeconds;
  final double extraWaitRatePerMin;
  final DriverCancelReason selectedCancelReason;
  final int telemetryActiveTab;
  final String telemetryWarningTitle;
  final String telemetryWarningMessage;
  final String dispatchBannerText;
  final double fareCad;
  final bool isFareVerified;

  // In-progress Active Navigation fields (Image 1 & 2)
  final String corridorTitle;
  final double distanceRemainingKm;
  final int tripDurationElapsedSeconds;
  final bool isMeterRunning;
  final String dropoffProximityMode; // 'far' (1.2 km warning) or 'within50m' (normal)
  final double dropoffDistanceAwayKm;
  final double estimatedDropoffFareCad;
  final double computedMeterFareCad;
  final bool isSosActive;

  const DriverTripModel({
    this.tripId = 'BC-123456',
    this.unitNumber = 42,
    required this.passenger,
    this.pickupAddress = '440 University Dr W, Lethbridge',
    this.pickupSecondary = 'Lethbridge West Campus Loop',
    this.pickupNote = 'Pickup note: Blue door, side entrance',
    this.dropoffAddress = '501 1st Ave S',
    this.dropoffSecondary = 'Lethbridge (Downtown Core)',
    this.scheduledTime = 'Scheduled • Fri 3:30 PM',
    this.luggageAssistRequested = true,
    this.distanceKm = 4.1,
    this.etaMinutes = 9,
    this.distanceAwayMeters = 120,
    this.proximityLockThresholdMeters = 100,
    this.currentSpeedKmh = 48,
    this.nextTurnGuidance = 'Next: Turn right on 3rd Ave S',
    this.waitTimeElapsedSeconds = 153, // 2:33
    this.freeWaitLimitSeconds = 300, // 5:00
    this.extraWaitRatePerMin = 0.45,
    this.selectedCancelReason = DriverCancelReason.passengerAsked,
    this.telemetryActiveTab = 1,
    this.telemetryWarningTitle = 'Weak GPS Signal',
    this.telemetryWarningMessage =
        'Your location may be inaccurate. Keep phone mounted near windshield on Scenic Drive.',
    this.dispatchBannerText =
        '#14 EN ROUTE TO PICKUP • 432 Scenic Dr S, Lethbridge',
    this.fareCad = 15.00,
    this.isFareVerified = true,
    this.corridorTitle = 'Coulee Crossing (West Lethbridge → Downtown)',
    this.distanceRemainingKm = 2.4,
    this.tripDurationElapsedSeconds = 392, // 6:32
    this.isMeterRunning = true,
    this.dropoffProximityMode = 'far',
    this.dropoffDistanceAwayKm = 1.2,
    this.estimatedDropoffFareCad = 18.40,
    this.computedMeterFareCad = 16.85,
    this.isSosActive = false,
  });

  bool get isArrivalLocked => distanceAwayMeters > proximityLockThresholdMeters;

  String get formattedWaitTime {
    final minutes = waitTimeElapsedSeconds ~/ 60;
    final seconds = waitTimeElapsedSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedFreeWaitLimit {
    final minutes = freeWaitLimitSeconds ~/ 60;
    final seconds = freeWaitLimitSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedTripDurationElapsed {
    final minutes = tripDurationElapsedSeconds ~/ 60;
    final seconds = tripDurationElapsedSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  bool get isExtraWaitCharged =>
      waitTimeElapsedSeconds > freeWaitLimitSeconds;

  double get waitProgress =>
      (waitTimeElapsedSeconds / freeWaitLimitSeconds).clamp(0.0, 1.0);

  bool get isFarDropoff => dropoffProximityMode == 'far';

  DriverTripModel copyWith({
    String? tripId,
    int? unitNumber,
    DriverTripPassenger? passenger,
    String? pickupAddress,
    String? pickupSecondary,
    String? pickupNote,
    String? dropoffAddress,
    String? dropoffSecondary,
    String? scheduledTime,
    bool? luggageAssistRequested,
    double? distanceKm,
    int? etaMinutes,
    int? distanceAwayMeters,
    int? proximityLockThresholdMeters,
    int? currentSpeedKmh,
    String? nextTurnGuidance,
    int? waitTimeElapsedSeconds,
    int? freeWaitLimitSeconds,
    double? extraWaitRatePerMin,
    DriverCancelReason? selectedCancelReason,
    int? telemetryActiveTab,
    String? telemetryWarningTitle,
    String? telemetryWarningMessage,
    String? dispatchBannerText,
    double? fareCad,
    bool? isFareVerified,
    String? corridorTitle,
    double? distanceRemainingKm,
    int? tripDurationElapsedSeconds,
    bool? isMeterRunning,
    String? dropoffProximityMode,
    double? dropoffDistanceAwayKm,
    double? estimatedDropoffFareCad,
    double? computedMeterFareCad,
    bool? isSosActive,
  }) {
    return DriverTripModel(
      tripId: tripId ?? this.tripId,
      unitNumber: unitNumber ?? this.unitNumber,
      passenger: passenger ?? this.passenger,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupSecondary: pickupSecondary ?? this.pickupSecondary,
      pickupNote: pickupNote ?? this.pickupNote,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      dropoffSecondary: dropoffSecondary ?? this.dropoffSecondary,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      luggageAssistRequested:
          luggageAssistRequested ?? this.luggageAssistRequested,
      distanceKm: distanceKm ?? this.distanceKm,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      distanceAwayMeters: distanceAwayMeters ?? this.distanceAwayMeters,
      proximityLockThresholdMeters:
          proximityLockThresholdMeters ?? this.proximityLockThresholdMeters,
      currentSpeedKmh: currentSpeedKmh ?? this.currentSpeedKmh,
      nextTurnGuidance: nextTurnGuidance ?? this.nextTurnGuidance,
      waitTimeElapsedSeconds:
          waitTimeElapsedSeconds ?? this.waitTimeElapsedSeconds,
      freeWaitLimitSeconds:
          freeWaitLimitSeconds ?? this.freeWaitLimitSeconds,
      extraWaitRatePerMin: extraWaitRatePerMin ?? this.extraWaitRatePerMin,
      selectedCancelReason:
          selectedCancelReason ?? this.selectedCancelReason,
      telemetryActiveTab: telemetryActiveTab ?? this.telemetryActiveTab,
      telemetryWarningTitle:
          telemetryWarningTitle ?? this.telemetryWarningTitle,
      telemetryWarningMessage:
          telemetryWarningMessage ?? this.telemetryWarningMessage,
      dispatchBannerText: dispatchBannerText ?? this.dispatchBannerText,
      fareCad: fareCad ?? this.fareCad,
      isFareVerified: isFareVerified ?? this.isFareVerified,
      corridorTitle: corridorTitle ?? this.corridorTitle,
      distanceRemainingKm: distanceRemainingKm ?? this.distanceRemainingKm,
      tripDurationElapsedSeconds:
          tripDurationElapsedSeconds ?? this.tripDurationElapsedSeconds,
      isMeterRunning: isMeterRunning ?? this.isMeterRunning,
      dropoffProximityMode: dropoffProximityMode ?? this.dropoffProximityMode,
      dropoffDistanceAwayKm:
          dropoffDistanceAwayKm ?? this.dropoffDistanceAwayKm,
      estimatedDropoffFareCad:
          estimatedDropoffFareCad ?? this.estimatedDropoffFareCad,
      computedMeterFareCad:
          computedMeterFareCad ?? this.computedMeterFareCad,
      isSosActive: isSosActive ?? this.isSosActive,
    );
  }

  @override
  List<Object?> get props => [
        tripId,
        unitNumber,
        passenger,
        pickupAddress,
        pickupSecondary,
        pickupNote,
        dropoffAddress,
        dropoffSecondary,
        scheduledTime,
        luggageAssistRequested,
        distanceKm,
        etaMinutes,
        distanceAwayMeters,
        proximityLockThresholdMeters,
        currentSpeedKmh,
        nextTurnGuidance,
        waitTimeElapsedSeconds,
        freeWaitLimitSeconds,
        extraWaitRatePerMin,
        selectedCancelReason,
        telemetryActiveTab,
        telemetryWarningTitle,
        telemetryWarningMessage,
        dispatchBannerText,
        fareCad,
        isFareVerified,
        corridorTitle,
        distanceRemainingKm,
        tripDurationElapsedSeconds,
        isMeterRunning,
        dropoffProximityMode,
        dropoffDistanceAwayKm,
        estimatedDropoffFareCad,
        computedMeterFareCad,
        isSosActive,
      ];
}
