import 'package:equatable/equatable.dart';
import '../../data/models/sos_alert_config.dart';
import '../../data/models/sos_alert_model.dart';

class SosAlertState extends Equatable {
  final SosAlertStatus status;
  final LocationServiceStatus locationStatus;
  final SosRideTelemetry telemetry;
  final int beaconPingCount;
  final DateTime? alertSentTimestamp;
  final String? networkErrorMessage;
  final bool isUpdatingLocation;
  final String? userFeedbackMessage;
  final bool dismissedLocationWarning;

  const SosAlertState({
    this.status = SosAlertStatus.readyToSend,
    this.locationStatus = LocationServiceStatus.enabled,
    this.telemetry = SosAlertConfig.defaultTelemetry,
    this.beaconPingCount = 0,
    this.alertSentTimestamp,
    this.networkErrorMessage,
    this.isUpdatingLocation = false,
    this.userFeedbackMessage,
    this.dismissedLocationWarning = false,
  });

  bool get isReady => status == SosAlertStatus.readyToSend;
  bool get isSending => status == SosAlertStatus.sending;
  bool get isActive => status == SosAlertStatus.active;
  bool get isFailed => status == SosAlertStatus.failed;
  bool get isCancelled => status == SosAlertStatus.cancelled;

  bool get shouldShowLocationWarning =>
      locationStatus == LocationServiceStatus.disabled && !dismissedLocationWarning;

  bool get shouldShowConnectionWarning =>
      networkErrorMessage != null && networkErrorMessage!.isNotEmpty;

  String get formattedSentTime {
    if (alertSentTimestamp == null) return 'Just now • 1:46 PM';
    final hour = alertSentTimestamp!.hour > 12
        ? alertSentTimestamp!.hour - 12
        : (alertSentTimestamp!.hour == 0 ? 12 : alertSentTimestamp!.hour);
    final minute = alertSentTimestamp!.minute.toString().padLeft(2, '0');
    final amPm = alertSentTimestamp!.hour >= 12 ? 'PM' : 'AM';
    return 'Just now • $hour:$minute $amPm';
  }

  SosAlertState copyWith({
    SosAlertStatus? status,
    LocationServiceStatus? locationStatus,
    SosRideTelemetry? telemetry,
    int? beaconPingCount,
    DateTime? Function()? alertSentTimestamp,
    String? Function()? networkErrorMessage,
    bool? isUpdatingLocation,
    String? Function()? userFeedbackMessage,
    bool? dismissedLocationWarning,
  }) {
    return SosAlertState(
      status: status ?? this.status,
      locationStatus: locationStatus ?? this.locationStatus,
      telemetry: telemetry ?? this.telemetry,
      beaconPingCount: beaconPingCount ?? this.beaconPingCount,
      alertSentTimestamp: alertSentTimestamp != null
          ? alertSentTimestamp()
          : this.alertSentTimestamp,
      networkErrorMessage: networkErrorMessage != null
          ? networkErrorMessage()
          : this.networkErrorMessage,
      isUpdatingLocation: isUpdatingLocation ?? this.isUpdatingLocation,
      userFeedbackMessage: userFeedbackMessage != null
          ? userFeedbackMessage()
          : this.userFeedbackMessage,
      dismissedLocationWarning:
          dismissedLocationWarning ?? this.dismissedLocationWarning,
    );
  }

  @override
  List<Object?> get props => [
        status,
        locationStatus,
        telemetry,
        beaconPingCount,
        alertSentTimestamp,
        networkErrorMessage,
        isUpdatingLocation,
        userFeedbackMessage,
        dismissedLocationWarning,
      ];
}
