import 'package:equatable/equatable.dart';
import '../data/models/driver_auth_status.dart';

abstract class DriverAuthEvent extends Equatable {
  const DriverAuthEvent();

  @override
  List<Object?> get props => [];
}

class DriverAuthPhoneChanged extends DriverAuthEvent {
  final String phone;

  const DriverAuthPhoneChanged(this.phone);

  @override
  List<Object?> get props => [phone];
}

class DriverAuthPhoneCleared extends DriverAuthEvent {
  const DriverAuthPhoneCleared();
}

class DriverAuthSubmitted extends DriverAuthEvent {
  const DriverAuthSubmitted();
}

class DriverAuthBecomeDriverTapped extends DriverAuthEvent {
  const DriverAuthBecomeDriverTapped();
}

class DriverAuthLockoutTick extends DriverAuthEvent {
  const DriverAuthLockoutTick();
}

class DriverAuthNotYourNumberTapped extends DriverAuthEvent {
  const DriverAuthNotYourNumberTapped();
}

class DriverAuthStateSwitched extends DriverAuthEvent {
  final DriverAuthStatus status;

  const DriverAuthStateSwitched(this.status);

  @override
  List<Object?> get props => [status];
}
