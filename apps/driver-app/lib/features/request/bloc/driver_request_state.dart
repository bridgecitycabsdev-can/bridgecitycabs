import 'package:equatable/equatable.dart';
import '../data/models/driver_acceptance_impact.dart';
import '../data/models/driver_decline_reason.dart';
import '../data/models/driver_dispatch_queue_info.dart';
import '../data/models/driver_request_config.dart';
import '../data/models/driver_request_model.dart';
import '../data/models/driver_request_status.dart';

class DriverRequestState extends Equatable {
  final DriverRequestStatus status;
  final DriverRequestModel request;
  final DriverAcceptanceImpact impact;
  final DriverDispatchQueueInfo queueInfo;
  final DriverDeclineReason? selectedReason;
  final bool isActionLoading;
  final bool shouldNavigateToTrip;
  final bool shouldNavigateToMap;
  final String? errorMessage;

  const DriverRequestState({
    required this.status,
    required this.request,
    required this.impact,
    required this.queueInfo,
    this.selectedReason,
    this.isActionLoading = false,
    this.shouldNavigateToTrip = false,
    this.shouldNavigateToMap = false,
    this.errorMessage,
  });

  factory DriverRequestState.initial() {
    return DriverRequestState(
      status: DriverRequestStatus.incomingInstant,
      request: DriverRequestConfig.instantPreset(),
      impact: DriverRequestConfig.declineImpact(),
      queueInfo: DriverRequestConfig.takenQueueInfo(),
      selectedReason: null,
      isActionLoading: false,
      shouldNavigateToTrip: false,
      shouldNavigateToMap: false,
      errorMessage: null,
    );
  }

  DriverRequestState copyWith({
    DriverRequestStatus? status,
    DriverRequestModel? request,
    DriverAcceptanceImpact? impact,
    DriverDispatchQueueInfo? queueInfo,
    DriverDeclineReason? selectedReason,
    bool? isActionLoading,
    bool? shouldNavigateToTrip,
    bool? shouldNavigateToMap,
    String? errorMessage,
  }) {
    return DriverRequestState(
      status: status ?? this.status,
      request: request ?? this.request,
      impact: impact ?? this.impact,
      queueInfo: queueInfo ?? this.queueInfo,
      selectedReason: selectedReason ?? this.selectedReason,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      shouldNavigateToTrip:
          shouldNavigateToTrip ?? this.shouldNavigateToTrip,
      shouldNavigateToMap:
          shouldNavigateToMap ?? this.shouldNavigateToMap,
      errorMessage: errorMessage,
    );
  }

  bool get isExpiringUrgent => status == DriverRequestStatus.expiringUrgent;
  bool get isSecuring => status == DriverRequestStatus.securingDispatch;
  bool get isExpired => status == DriverRequestStatus.expired;
  bool get isTaken => status == DriverRequestStatus.takenByAnother;
  bool get isScheduled => status == DriverRequestStatus.scheduled;
  bool get isDeclineSheetOpen =>
      status == DriverRequestStatus.declineConfirmation;

  double get timerProgress {
    if (request.totalTimeoutSeconds <= 0) return 0.0;
    return (request.remainingSeconds / request.totalTimeoutSeconds).clamp(
      0.0,
      1.0,
    );
  }

  @override
  List<Object?> get props => [
    status,
    request,
    impact,
    queueInfo,
    selectedReason,
    isActionLoading,
    shouldNavigateToTrip,
    shouldNavigateToMap,
    errorMessage,
  ];
}
