import 'package:equatable/equatable.dart';
import '../../data/models/cooldown_timer.dart';

/// Enum representing the primary status of the phone auth screen.
enum AuthStatus {
  /// Screen 3: Initial empty input field.
  empty,

  /// Screen 1: Complete and valid 10-digit Canadian phone number ready to submit.
  valid,

  /// Screen 5: Incomplete or invalid phone format with error prompt.
  invalid,

  /// Screen 4: Actively requesting OTP with loading spinner on Continue button.
  submitting,

  /// Screen 2: Rate limited / cooldown active with countdown timer.
  rateLimited,

  /// Code successfully dispatched, triggers navigation to OTP entry screen.
  success,
}

/// Base class for Auth state.
abstract class AuthState extends Equatable {
  final AuthStatus status;
  final String rawPhone;
  final String formattedPhone;
  final CooldownTimer? cooldown;
  final String? errorMessage;
  final String? targetRoute;

  const AuthState({
    required this.status,
    this.rawPhone = '',
    this.formattedPhone = '',
    this.cooldown,
    this.errorMessage,
    this.targetRoute,
  });

  bool get isEmpty => status == AuthStatus.empty;
  bool get isValid => status == AuthStatus.valid;
  bool get isInvalid => status == AuthStatus.invalid;
  bool get isSubmitting => status == AuthStatus.submitting;
  bool get isRateLimited => status == AuthStatus.rateLimited;
  bool get isSuccess => status == AuthStatus.success;

  bool get canSubmit => isValid && !isSubmitting && !isRateLimited;

  @override
  List<Object?> get props => [
        status,
        rawPhone,
        formattedPhone,
        cooldown,
        errorMessage,
        targetRoute,
      ];
}

/// Screen 3 (Empty Input State):
/// Placeholder "Enter number", Instant SMS Verification card, disabled Continue.
class AuthPhoneEmpty extends AuthState {
  const AuthPhoneEmpty()
      : super(
          status: AuthStatus.empty,
          rawPhone: '',
          formattedPhone: '',
        );
}

/// Screen 1 (Valid Input State):
/// Formatted `(587) 329-5577`, checkmark icon, "Ready for dispatch" pill, active red Continue.
class AuthPhoneValid extends AuthState {
  const AuthPhoneValid({
    required super.rawPhone,
    required super.formattedPhone,
  }) : super(status: AuthStatus.valid);
}

/// Screen 5 (Validation Error State):
/// Incomplete number e.g. `(587) 32`, red warning outline, "Enter a valid phone number" prompt.
class AuthPhoneInvalid extends AuthState {
  const AuthPhoneInvalid({
    required super.rawPhone,
    required super.formattedPhone,
    String? errorMessage,
  }) : super(
          status: AuthStatus.invalid,
          errorMessage: errorMessage ?? 'Enter a valid phone number',
        );
}

/// Screen 4 (Sending Code / Submitting State):
/// "Dispatching 6-digit PIN" notice card, "Sending code..." loading button, "Entered wrong number? Edit".
class AuthSubmitting extends AuthState {
  const AuthSubmitting({
    required super.rawPhone,
    required super.formattedPhone,
  }) : super(status: AuthStatus.submitting);
}

/// Screen 2 (Rate Limited / Cooldown Active State):
/// "Too many attempts" banner with countdown ("04:56"), locked input with "Cooldown active", Help support card.
class AuthRateLimited extends AuthState {
  const AuthRateLimited({
    required super.rawPhone,
    required super.formattedPhone,
    required CooldownTimer cooldown,
  }) : super(
          status: AuthStatus.rateLimited,
          cooldown: cooldown,
        );
}

/// Success / Navigation State:
/// Code dispatched, routes to `/code?phone=...`.
class AuthCodeSentSuccess extends AuthState {
  const AuthCodeSentSuccess({
    required super.rawPhone,
    required super.formattedPhone,
    required String targetRoute,
  }) : super(
          status: AuthStatus.success,
          targetRoute: targetRoute,
        );
}
