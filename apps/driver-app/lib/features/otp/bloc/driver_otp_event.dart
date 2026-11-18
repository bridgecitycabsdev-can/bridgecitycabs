import 'package:equatable/equatable.dart';
import '../data/models/driver_otp_status.dart';
import '../data/models/driver_routing_pathway.dart';

abstract class DriverOtpEvent extends Equatable {
  const DriverOtpEvent();

  @override
  List<Object?> get props => [];
}

class DriverOtpStarted extends DriverOtpEvent {
  final String? phone;
  final DriverOtpStatus initialStatus;

  const DriverOtpStarted({
    this.phone,
    this.initialStatus = DriverOtpStatus.initial,
  });

  @override
  List<Object?> get props => [phone, initialStatus];
}

class DriverOtpDigitPressed extends DriverOtpEvent {
  final String digit;

  const DriverOtpDigitPressed(this.digit);

  @override
  List<Object?> get props => [digit];
}

class DriverOtpBackspacePressed extends DriverOtpEvent {
  const DriverOtpBackspacePressed();
}

class DriverOtpClearPressed extends DriverOtpEvent {
  const DriverOtpClearPressed();
}

class DriverOtpSubmitted extends DriverOtpEvent {
  const DriverOtpSubmitted();
}

class DriverOtpResendTapped extends DriverOtpEvent {
  const DriverOtpResendTapped();
}

class DriverOtpTimerTick extends DriverOtpEvent {
  const DriverOtpTimerTick();
}

class DriverOtpPathwaySelected extends DriverOtpEvent {
  final DriverRoutingPathway pathway;

  const DriverOtpPathwaySelected(this.pathway);

  @override
  List<Object?> get props => [pathway];
}

class DriverOtpStateSwitched extends DriverOtpEvent {
  final DriverOtpStatus status;

  const DriverOtpStateSwitched(this.status);

  @override
  List<Object?> get props => [status];
}
