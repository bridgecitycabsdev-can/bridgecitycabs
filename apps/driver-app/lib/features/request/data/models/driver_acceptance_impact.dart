import 'package:equatable/equatable.dart';

class DriverAcceptanceImpact extends Equatable {
  final int currentRate;
  final int projectedRate;
  final int penaltyPercent;
  final String ratingTier;
  final String rollingWindow;
  final String targetAdvice;

  const DriverAcceptanceImpact({
    this.currentRate = 50,
    this.projectedRate = 48,
    this.penaltyPercent = -2,
    this.ratingTier = 'Poor',
    this.rollingWindow = 'Rolling 100 trips',
    this.targetAdvice =
        'Keep your acceptance rate above 85% for priority trips',
  });

  DriverAcceptanceImpact copyWith({
    int? currentRate,
    int? projectedRate,
    int? penaltyPercent,
    String? ratingTier,
    String? rollingWindow,
    String? targetAdvice,
  }) {
    return DriverAcceptanceImpact(
      currentRate: currentRate ?? this.currentRate,
      projectedRate: projectedRate ?? this.projectedRate,
      penaltyPercent: penaltyPercent ?? this.penaltyPercent,
      ratingTier: ratingTier ?? this.ratingTier,
      rollingWindow: rollingWindow ?? this.rollingWindow,
      targetAdvice: targetAdvice ?? this.targetAdvice,
    );
  }

  @override
  List<Object?> get props => [
    currentRate,
    projectedRate,
    penaltyPercent,
    ratingTier,
    rollingWindow,
    targetAdvice,
  ];
}
