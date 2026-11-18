import 'package:equatable/equatable.dart';
import '../data/models/driver_trip_config.dart';
import '../data/models/driver_trip_model.dart';
import '../data/models/driver_trip_status.dart';

class DriverTripState extends Equatable {
  final DriverTripStatus status;
  final DriverTripModel trip;
  final DriverTripStatus previousStatus;
  final bool isLoading;
  final String? errorMessage;
  final String? toastMessage;
  final bool isCanceledAndReturning;
  final bool isTripEndedAndSummarizing;

  const DriverTripState({
    required this.status,
    required this.trip,
    this.previousStatus = DriverTripStatus.headingToPickup,
    this.isLoading = false,
    this.errorMessage,
    this.toastMessage,
    this.isCanceledAndReturning = false,
    this.isTripEndedAndSummarizing = false,
  });

  factory DriverTripState.initial({DriverTripStatus? initialStatus}) {
    final status = initialStatus ?? DriverTripStatus.headingToPickup;
    DriverTripModel initialTrip;
    switch (status) {
      case DriverTripStatus.headingToPickup:
        initialTrip = DriverTripConfig.headingToPickupPreset;
        break;
      case DriverTripStatus.waitingForPassenger:
        initialTrip = DriverTripConfig.waitingForPassengerPreset;
        break;
      case DriverTripStatus.cancelTripModal:
        initialTrip = DriverTripConfig.cancelTripModalPreset;
        break;
      case DriverTripStatus.telemetryAlert:
        initialTrip = DriverTripConfig.telemetryAlertPreset;
        break;
      case DriverTripStatus.onTrip:
        initialTrip = DriverTripConfig.activeNavigationPreset;
        break;
      case DriverTripStatus.endTripModal:
        initialTrip = DriverTripConfig.endTripModalPreset;
        break;
      case DriverTripStatus.emergencySosModal:
        initialTrip = DriverTripConfig.emergencySosModalPreset;
        break;
      case DriverTripStatus.canceled:
        initialTrip = DriverTripConfig.headingToPickupPreset;
        break;
    }

    return DriverTripState(
      status: status,
      trip: initialTrip,
    );
  }

  bool get isHeadingToPickup => status == DriverTripStatus.headingToPickup;
  bool get isWaitingForPassenger => status == DriverTripStatus.waitingForPassenger;
  bool get isCancelModal => status == DriverTripStatus.cancelTripModal;
  bool get isTelemetryAlert => status == DriverTripStatus.telemetryAlert;
  bool get isOnTrip => status == DriverTripStatus.onTrip;
  bool get isEndTripModal => status == DriverTripStatus.endTripModal;
  bool get isEmergencySosModal => status == DriverTripStatus.emergencySosModal;
  bool get isCanceled => status == DriverTripStatus.canceled;

  DriverTripState copyWith({
    DriverTripStatus? status,
    DriverTripModel? trip,
    DriverTripStatus? previousStatus,
    bool? isLoading,
    String? errorMessage,
    String? toastMessage,
    bool? isCanceledAndReturning,
    bool? isTripEndedAndSummarizing,
    bool clearToast = false,
    bool clearError = false,
  }) {
    return DriverTripState(
      status: status ?? this.status,
      trip: trip ?? this.trip,
      previousStatus: previousStatus ?? this.previousStatus,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
      isCanceledAndReturning:
          isCanceledAndReturning ?? this.isCanceledAndReturning,
      isTripEndedAndSummarizing:
          isTripEndedAndSummarizing ?? this.isTripEndedAndSummarizing,
    );
  }

  @override
  List<Object?> get props => [
        status,
        trip,
        previousStatus,
        isLoading,
        errorMessage,
        toastMessage,
        isCanceledAndReturning,
        isTripEndedAndSummarizing,
      ];
}
