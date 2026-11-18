import 'package:equatable/equatable.dart';
import '../../data/models/otp_config.dart';
import '../../data/models/otp_timer.dart';

/// Enum representing the primary OTP status.
enum OtpStatus {
  /// Screen 3: Initial empty input with blinking cursor, "OTP sent successfully" toast.
  initial,

  /// Passenger actively entering digits.
  typing,

  /// Screen 2: All 6 digits auto-filled or typed, "Code auto-filled from SMS" badge.
  autofilled,

  /// Screen 4: Actively verifying code, "LOCKED" badge, spinner on button.
  verifying,

  /// Screen 1: Verification failed, red boxes, "Incorrect code (X attempts remaining)".
  error,

  /// Screen 5: Code expired, "Code Expired (00:00)" card, "Resend code now" CTA.
  expired,

  /// OTP verified successfully, routes to `/home`.
  success,

  /// User requested to edit phone number, routes to `/phone`.
  navigateBack,
}

/// Base abstract class for all OTP states.
abstract class OtpState extends Equatable {
  final OtpStatus status;
  final String phone;
  final String code;
  final OtpTimer resendTimer;
  final int attemptsRemaining;
  final String? errorMessage;
  final String? targetRoute;

  const OtpState({
    required this.status,
    required this.phone,
    this.code = '',
    this.resendTimer = const OtpTimer(remainingSeconds: OtpConfig.defaultResendSeconds),
    this.attemptsRemaining = OtpConfig.maxAttempts,
    this.errorMessage,
    this.targetRoute,
  });

  bool get isInitial => status == OtpStatus.initial;
  bool get isTyping => status == OtpStatus.typing;
  bool get isAutofilled => status == OtpStatus.autofilled;
  bool get isVerifying => status == OtpStatus.verifying;
  bool get isError => status == OtpStatus.error;
  bool get isExpired => status == OtpStatus.expired;
  bool get isSuccess => status == OtpStatus.success;

  bool get isCodeComplete => code.length == OtpConfig.codeLength;
  bool get canSubmit => isCodeComplete && !isVerifying && !isExpired;

  String get maskedPhone => OtpConfig.maskPhone(phone);

  @override
  List<Object?> get props => [
        status,
        phone,
        code,
        resendTimer,
        attemptsRemaining,
        errorMessage,
        targetRoute,
      ];
}

/// Screen 3 (Initial Input State):
/// - 1st box active with cursor, remaining 5 boxes show dots
/// - "OTP sent successfully" green toast notification
/// - "Resend code in 0:28" countdown
/// - Disabled Verify button, "Edit" phone link
class OtpInitialState extends OtpState {
  final bool showSuccessToast;

  const OtpInitialState({
    required super.phone,
    super.code = '',
    super.resendTimer,
    super.attemptsRemaining,
    this.showSuccessToast = true,
  }) : super(status: OtpStatus.initial);

  @override
  List<Object?> get props => [...super.props, showSuccessToast];
}

/// Typing State: User is currently entering digits.
class OtpTypingState extends OtpState {
  const OtpTypingState({
    required super.phone,
    required super.code,
    super.resendTimer,
    super.attemptsRemaining,
  }) : super(status: OtpStatus.typing);
}

/// Screen 2 (Code Auto-filled / Complete State):
/// - 6 digits populated (e.g. `482915`)
/// - "✓ Code auto-filled from SMS" badge
/// - Active red "Verify code →" button
/// - "End-to-end encrypted dispatch network" note
class OtpAutofilledState extends OtpState {
  const OtpAutofilledState({
    required super.phone,
    required super.code,
    super.resendTimer,
    super.attemptsRemaining,
  }) : super(status: OtpStatus.autofilled);
}

/// Screen 4 (Verifying / Loading State):
/// - 6 digits with red underline accents and "🔒 LOCKED" badge
/// - Loading button: Red with white spinner + "Verifying code..."
/// - Sync card: "Securing local transit channel... ● Syncing"
/// - Keypad disabled
class OtpVerifyingState extends OtpState {
  const OtpVerifyingState({
    required super.phone,
    required super.code,
    super.resendTimer,
    super.attemptsRemaining,
  }) : super(status: OtpStatus.verifying);
}

/// Screen 1 (Validation Error / Incorrect Code State):
/// - 6 boxes highlighted in red outline with red digits
/// - Error banner: "(!) Incorrect code. Please try again. (X attempts remaining)"
/// - Enabled "Verify code →" button
class OtpErrorState extends OtpState {
  const OtpErrorState({
    required super.phone,
    required super.code,
    required super.attemptsRemaining,
    super.resendTimer,
    String? errorMessage,
  }) : super(
          status: OtpStatus.error,
          errorMessage: errorMessage ??
              'Incorrect code. Please try again. ($attemptsRemaining attempts remaining)',
        );
}

/// Screen 5 (Code Expired / Timeout State):
/// - Dimmed digits in disabled boxes
/// - Alert card: "Code Expired (00:00) [Timeout]"
/// - Resend card: "Haven't got the code yet?" with "⟳ Resend code now" button
/// - Disabled Verify button
class OtpExpiredState extends OtpState {
  const OtpExpiredState({
    required super.phone,
    super.code = '482910',
    super.attemptsRemaining = 0,
  }) : super(
          status: OtpStatus.expired,
          resendTimer: const OtpTimer(remainingSeconds: 0),
        );
}

/// Terminal Success State: Routes to `/home`.
class OtpSuccessState extends OtpState {
  const OtpSuccessState({
    required super.phone,
    required super.code,
    required String targetRoute,
  }) : super(
          status: OtpStatus.success,
          targetRoute: targetRoute,
        );
}

/// Navigation State: Routes back to `/phone`.
class OtpNavigateToPhoneState extends OtpState {
  const OtpNavigateToPhoneState({required super.phone})
      : super(
          status: OtpStatus.navigateBack,
          targetRoute: '/phone',
        );
}
