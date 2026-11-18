import 'package:equatable/equatable.dart';
import '../data/models/driver_decline_reason.dart';
import '../data/models/driver_request_model.dart';
import '../data/models/driver_request_status.dart';

abstract class DriverRequestEvent extends Equatable {
  const DriverRequestEvent();

  @override
  List<Object?> get props => [];
}

class DriverRequestStarted extends DriverRequestEvent {
  final DriverRequestModel? initialRequest;
  final DriverRequestStatus initialStatus;

  const DriverRequestStarted({
    this.initialRequest,
    this.initialStatus = DriverRequestStatus.incomingInstant,
  });

  @override
  List<Object?> get props => [initialRequest, initialStatus];
}

class DriverRequestTimerTicked extends DriverRequestEvent {
  final int remainingSeconds;

  const DriverRequestTimerTicked(this.remainingSeconds);

  @override
  List<Object?> get props => [remainingSeconds];
}

class DriverRequestAcceptPressed extends DriverRequestEvent {
  const DriverRequestAcceptPressed();
}

class DriverRequestDeclinePressed extends DriverRequestEvent {
  const DriverRequestDeclinePressed();
}

class DriverRequestReasonSelected extends DriverRequestEvent {
  final DriverDeclineReason reason;

  const DriverRequestReasonSelected(this.reason);

  @override
  List<Object?> get props => [reason];
}

class DriverRequestKeepAndAcceptPressed extends DriverRequestEvent {
  const DriverRequestKeepAndAcceptPressed();
}

class DriverRequestDeclineConfirmed extends DriverRequestEvent {
  const DriverRequestDeclineConfirmed();
}

class DriverRequestReturnToMapPressed extends DriverRequestEvent {
  const DriverRequestReturnToMapPressed();
}

class DriverRequestStateForced extends DriverRequestEvent {
  final DriverRequestStatus status;

  const DriverRequestStateForced(this.status);

  @override
  List<Object?> get props => [status];
}
