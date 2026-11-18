import 'package:equatable/equatable.dart';

/// Base class for all authentication events.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Fired whenever the passenger types or pastes into the phone input field.
class AuthPhoneChanged extends AuthEvent {
  final String rawPhone;

  const AuthPhoneChanged(this.rawPhone);

  @override
  List<Object?> get props => [rawPhone];
}

/// Fired when the passenger taps the "Continue →" button to request an SMS OTP code.
class AuthSubmitRequested extends AuthEvent {
  const AuthSubmitRequested();
}

/// Internal timer tick fired every second while the rate-limit countdown is active.
class AuthCooldownTicked extends AuthEvent {
  final int remainingSeconds;

  const AuthCooldownTicked(this.remainingSeconds);

  @override
  List<Object?> get props => [remainingSeconds];
}

/// Fired when the rate limit cooldown countdown reaches 00:00.
class AuthCooldownExpired extends AuthEvent {
  const AuthCooldownExpired();
}

/// Fired when the user taps "Entered wrong number? Edit" to cancel submission and edit.
class AuthEditPhoneTapped extends AuthEvent {
  const AuthEditPhoneTapped();
}

/// Fired when the user taps "Help" on the support card during rate limit or login trouble.
class AuthHelpTapped extends AuthEvent {
  const AuthHelpTapped();
}

/// Fired when the server returns a rate limit response (HTTP 429) or for manual cooldown trigger.
class AuthTriggerCooldown extends AuthEvent {
  final int totalSeconds;

  const AuthTriggerCooldown({this.totalSeconds = 300});

  @override
  List<Object?> get props => [totalSeconds];
}
