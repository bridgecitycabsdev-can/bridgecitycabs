import 'package:equatable/equatable.dart';
import '../../data/models/sos_alert_model.dart';

abstract class SosAlertEvent extends Equatable {
  const SosAlertEvent();

  @override
  List<Object?> get props => [];
}

class SosAlertStarted extends SosAlertEvent {
  final SosRideTelemetry? telemetry;
  final bool? locationEnabled;
  final bool? simulateNetworkFailure;
  final SosAlertStatus? initialStatus;

  const SosAlertStarted({
    this.telemetry,
    this.locationEnabled,
    this.simulateNetworkFailure,
    this.initialStatus,
  });

  @override
  List<Object?> get props => [
        telemetry,
        locationEnabled,
        simulateNetworkFailure,
        initialStatus,
      ];
}

class SosAlertSendTapped extends SosAlertEvent {
  const SosAlertSendTapped();
}

class SosAlertUpdateLocationTapped extends SosAlertEvent {
  const SosAlertUpdateLocationTapped();
}

class SosAlertRetryTapped extends SosAlertEvent {
  const SosAlertRetryTapped();
}

class SosAlertLocationSettingsOpened extends SosAlertEvent {
  const SosAlertLocationSettingsOpened();
}

class SosAlertSendAnywayTapped extends SosAlertEvent {
  const SosAlertSendAnywayTapped();
}

class SosAlertCancelTapped extends SosAlertEvent {
  const SosAlertCancelTapped();
}

class SosAlertCall911Tapped extends SosAlertEvent {
  const SosAlertCall911Tapped();
}

class SosAlertCallSafetyLineTapped extends SosAlertEvent {
  const SosAlertCallSafetyLineTapped();
}

class SosAlertBackToTripTapped extends SosAlertEvent {
  const SosAlertBackToTripTapped();
}
