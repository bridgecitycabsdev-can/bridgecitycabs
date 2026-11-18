import 'package:equatable/equatable.dart';

/// Timer model for the OTP resend countdown.
class OtpTimer extends Equatable {
  final int remainingSeconds;

  const OtpTimer({required this.remainingSeconds});

  /// Formats time as `M:SS` (e.g. 28 -> "0:28", 4 -> "0:04").
  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  bool get canResend => remainingSeconds <= 0;

  OtpTimer tick() {
    return OtpTimer(
      remainingSeconds: (remainingSeconds - 1).clamp(0, 999),
    );
  }

  @override
  List<Object?> get props => [remainingSeconds];
}
