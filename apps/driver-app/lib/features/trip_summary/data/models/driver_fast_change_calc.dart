import 'package:equatable/equatable.dart';

class DriverFastChangeOption extends Equatable {
  final double tenderAmount;
  final double fareAmount;

  const DriverFastChangeOption({
    required this.tenderAmount,
    required this.fareAmount,
  });

  double get changeDue => (tenderAmount - fareAmount).clamp(0.0, 9999.0);

  String get tenderLabel => 'If passenger gives \$${tenderAmount.toStringAsFixed(0)}';
  String get changeLabel => 'Return \$${changeDue.toStringAsFixed(2)} change';

  @override
  List<Object?> get props => [tenderAmount, fareAmount];
}
