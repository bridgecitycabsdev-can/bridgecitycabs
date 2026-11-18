import 'package:equatable/equatable.dart';
import '../data/models/driver_otp_config.dart';
import '../data/models/driver_otp_status.dart';
import '../data/models/driver_routing_pathway.dart';

class DriverOtpState extends Equatable {
  final DriverOtpStatus status;
  final String code;
  final String phone;
  final String maskedPhone;
  final int resendCooldownSeconds;
  final String? errorMessage;
  final DriverRoutingPathwayType selectedPathway;
  final String? feedbackMessage;
  final String? targetRoute;

  const DriverOtpState({
    this.status = DriverOtpStatus.initial,
    this.code = '',
    this.phone = '+14035550117',
    this.maskedPhone = DriverOtpConfig.defaultMaskedPhone,
    this.resendCooldownSeconds = 28,
    this.errorMessage,
    this.selectedPathway = DriverRoutingPathwayType.approvedDriver,
    this.feedbackMessage,
    this.targetRoute,
  });

  bool get isCodeComplete => code.length == DriverOtpConfig.otpLength;
  bool get canSubmit => status == DriverOtpStatus.ready;
  bool get isSubmitting => status == DriverOtpStatus.submitting;
  bool get isExpired => status == DriverOtpStatus.expired;
  bool get isIncorrect => status == DriverOtpStatus.incorrect;
  bool get isResendAvailable => resendCooldownSeconds <= 0 && !isSubmitting;

  String get formattedCooldown {
    final minutes = resendCooldownSeconds ~/ 60;
    final seconds = resendCooldownSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Returns character for box at [index] (0..5)
  String digitAt(int index) {
    if (index < code.length) {
      return code[index];
    }
    return '';
  }

  DriverOtpState copyWith({
    DriverOtpStatus? status,
    String? code,
    String? phone,
    String? maskedPhone,
    int? resendCooldownSeconds,
    String? errorMessage,
    DriverRoutingPathwayType? selectedPathway,
    String? feedbackMessage,
    String? targetRoute,
  }) {
    return DriverOtpState(
      status: status ?? this.status,
      code: code ?? this.code,
      phone: phone ?? this.phone,
      maskedPhone: maskedPhone ?? this.maskedPhone,
      resendCooldownSeconds:
          resendCooldownSeconds ?? this.resendCooldownSeconds,
      errorMessage: errorMessage,
      selectedPathway: selectedPathway ?? this.selectedPathway,
      feedbackMessage: feedbackMessage,
      targetRoute: targetRoute,
    );
  }

  @override
  List<Object?> get props => [
        status,
        code,
        phone,
        maskedPhone,
        resendCooldownSeconds,
        errorMessage,
        selectedPathway,
        feedbackMessage,
        targetRoute,
      ];
}
