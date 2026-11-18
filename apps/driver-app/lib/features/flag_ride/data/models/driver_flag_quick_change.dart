import 'package:equatable/equatable.dart';

class DriverFlagQuickChange extends Equatable {
  final double tenderAmount;
  final double fareAmount;

  const DriverFlagQuickChange({
    required this.tenderAmount,
    required this.fareAmount,
  });

  double get changeDue => (tenderAmount - fareAmount).clamp(0.0, 9999.0);

  String get tenderText => 'If passenger gives \$${tenderAmount.toStringAsFixed(2)}';
  String get returnText => 'Return \$${changeDue.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [tenderAmount, fareAmount];
}
