import 'package:equatable/equatable.dart';

/// Cooldown timer model tracking remaining cooldown countdown and progress bar.
class CooldownTimer extends Equatable {
  final int totalSeconds;
  final int remainingSeconds;

  const CooldownTimer({
    required this.totalSeconds,
    required this.remainingSeconds,
  });

  /// Formats time in MM:SS (e.g., 296 seconds -> "04:56").
  String get formattedTime {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Calculates elapsed progress between 0.0 and 1.0.
  double get progress {
    if (totalSeconds <= 0) return 1.0;
    return (totalSeconds - remainingSeconds) / totalSeconds;
  }

  bool get isExpired => remainingSeconds <= 0;

  CooldownTimer tick() {
    return CooldownTimer(
      totalSeconds: totalSeconds,
      remainingSeconds: (remainingSeconds - 1).clamp(0, totalSeconds),
    );
  }

  @override
  List<Object?> get props => [totalSeconds, remainingSeconds];
}
