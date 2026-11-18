import 'package:equatable/equatable.dart';
import '../data/models/driver_splash_model.dart';

abstract class DriverSplashEvent extends Equatable {
  const DriverSplashEvent();

  @override
  List<Object?> get props => [];
}

class DriverSplashStarted extends DriverSplashEvent {
  final DriverSplashStatus initialStatus;

  const DriverSplashStarted({
    this.initialStatus = DriverSplashStatus.initial,
  });

  @override
  List<Object?> get props => [initialStatus];
}

class DriverSplashRetryTapped extends DriverSplashEvent {
  const DriverSplashRetryTapped();
}

class DriverSplashUpdateNowTapped extends DriverSplashEvent {
  const DriverSplashUpdateNowTapped();
}

class DriverSplashStatusChanged extends DriverSplashEvent {
  final DriverSplashStatus status;

  const DriverSplashStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}
