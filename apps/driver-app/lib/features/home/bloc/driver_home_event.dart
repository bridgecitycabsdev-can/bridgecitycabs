import 'package:equatable/equatable.dart';
import '../data/models/driver_home_status.dart';

abstract class DriverHomeEvent extends Equatable {
  const DriverHomeEvent();

  @override
  List<Object?> get props => [];
}

class DriverHomeStarted extends DriverHomeEvent {
  final DriverHomeStatus initialStatus;

  const DriverHomeStarted({
    this.initialStatus = DriverHomeStatus.offline,
  });

  @override
  List<Object?> get props => [initialStatus];
}

class DriverHomeGoOnlineRequested extends DriverHomeEvent {
  const DriverHomeGoOnlineRequested();
}

class DriverHomeGoOfflineRequested extends DriverHomeEvent {
  const DriverHomeGoOfflineRequested();
}

class DriverHomeSetAwayRequested extends DriverHomeEvent {
  const DriverHomeSetAwayRequested();
}

class DriverHomeResumeActiveRequested extends DriverHomeEvent {
  const DriverHomeResumeActiveRequested();
}

class DriverHomeEnableLocationRequested extends DriverHomeEvent {
  const DriverHomeEnableLocationRequested();
}

class DriverHomeRetryConnectionRequested extends DriverHomeEvent {
  const DriverHomeRetryConnectionRequested();
}

class DriverHomeViewIncomingOfferRequested extends DriverHomeEvent {
  const DriverHomeViewIncomingOfferRequested();
}

class DriverHomeViewDocumentsRequested extends DriverHomeEvent {
  const DriverHomeViewDocumentsRequested();
}

class DriverHomeCheckApplicationStatusRequested extends DriverHomeEvent {
  const DriverHomeCheckApplicationStatusRequested();
}

class DriverHomeEarningsRefreshRequested extends DriverHomeEvent {
  const DriverHomeEarningsRefreshRequested();
}

class DriverHomeThemeToggled extends DriverHomeEvent {
  const DriverHomeThemeToggled();
}

class DriverHomeStateSwitched extends DriverHomeEvent {
  final DriverHomeStatus status;

  const DriverHomeStateSwitched(this.status);

  @override
  List<Object?> get props => [status];
}
