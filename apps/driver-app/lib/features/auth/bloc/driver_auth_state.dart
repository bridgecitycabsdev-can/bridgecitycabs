import 'package:equatable/equatable.dart';
import '../data/models/driver_auth_status.dart';
import '../data/models/driver_fleet_zone_info.dart';

class DriverAuthState extends Equatable {
  final DriverAuthStatus status;
  final String rawInput;
  final String digitsOnly;
  final String formattedPhone;
  final String? errorMessage;
  final int failedAttempts;
  final int lockoutRemainingSeconds;
  final DriverFleetZoneInfo fleetInfo;
  final String? feedbackMessage;

  const DriverAuthState({
    this.status = DriverAuthStatus.initial,
    this.rawInput = '',
    this.digitsOnly = '',
    this.formattedPhone = '',
    this.errorMessage,
    this.failedAttempts = 0,
    this.lockoutRemainingSeconds = 897, // 14 mins 57 secs
    this.fleetInfo = DriverFleetZoneInfo.surgeActive,
    this.feedbackMessage,
  });

  bool get canContinue =>
      status == DriverAuthStatus.valid ||
      status == DriverAuthStatus.unregistered;

  bool get isLocked => status == DriverAuthStatus.locked;
  bool get isSubmitting => status == DriverAuthStatus.submitting;

  String get formattedLockoutTime {
    final minutes = lockoutRemainingSeconds ~/ 60;
    final seconds = lockoutRemainingSeconds % 60;
    final minsStr = minutes.toString().padLeft(2, '0');
    final secsStr = seconds.toString().padLeft(2, '0');
    return '$minsStr:$secsStr';
  }

  DriverAuthState copyWith({
    DriverAuthStatus? status,
    String? rawInput,
    String? digitsOnly,
    String? formattedPhone,
    String? errorMessage,
    int? failedAttempts,
    int? lockoutRemainingSeconds,
    DriverFleetZoneInfo? fleetInfo,
    String? feedbackMessage,
  }) {
    return DriverAuthState(
      status: status ?? this.status,
      rawInput: rawInput ?? this.rawInput,
      digitsOnly: digitsOnly ?? this.digitsOnly,
      formattedPhone: formattedPhone ?? this.formattedPhone,
      errorMessage: errorMessage,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockoutRemainingSeconds:
          lockoutRemainingSeconds ?? this.lockoutRemainingSeconds,
      fleetInfo: fleetInfo ?? this.fleetInfo,
      feedbackMessage: feedbackMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        rawInput,
        digitsOnly,
        formattedPhone,
        errorMessage,
        failedAttempts,
        lockoutRemainingSeconds,
        fleetInfo,
        feedbackMessage,
      ];
}
