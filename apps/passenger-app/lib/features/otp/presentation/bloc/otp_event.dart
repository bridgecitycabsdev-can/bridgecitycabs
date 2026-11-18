import 'package:equatable/equatable.dart';

/// Base class for all OTP validation events.
abstract class OtpEvent extends Equatable {
  const OtpEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched on page mount to initialize countdown and phone context.
class OtpStarted extends OtpEvent {
  final String phone;

  const OtpStarted({required this.phone});

  @override
  List<Object?> get props => [phone];
}

/// Dispatched when the passenger taps a digit on the in-app numeric keypad.
class OtpDigitEntered extends OtpEvent {
  final String digit;

  const OtpDigitEntered(this.digit);

  @override
  List<Object?> get props => [digit];
}

/// Dispatched when the passenger taps the backspace key on the keypad.
class OtpDigitDeleted extends OtpEvent {
  const OtpDigitDeleted();
}

/// Dispatched when the operating system or SMS broadcast auto-fills the 6-digit code.
class OtpCodeAutofilled extends OtpEvent {
  final String code;

  const OtpCodeAutofilled(this.code);

  @override
  List<Object?> get props => [code];
}

/// Dispatched when the passenger taps the "Verify code →" button.
class OtpSubmitRequested extends OtpEvent {
  const OtpSubmitRequested();
}

/// Dispatched when the passenger taps "Resend code" or "Resend code now".
class OtpResendRequested extends OtpEvent {
  const OtpResendRequested();
}

/// Internal timer tick fired every second for the resend countdown.
class OtpResendTicked extends OtpEvent {
  final int remainingSeconds;

  const OtpResendTicked(this.remainingSeconds);

  @override
  List<Object?> get props => [remainingSeconds];
}

/// Dispatched when security timeout occurs, causing the token to expire.
class OtpExpiredTriggered extends OtpEvent {
  const OtpExpiredTriggered();
}

/// Dispatched when the passenger taps "Edit" next to the masked phone number.
class OtpEditPhoneTapped extends OtpEvent {
  const OtpEditPhoneTapped();
}
