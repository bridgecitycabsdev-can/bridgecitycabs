import 'package:equatable/equatable.dart';

/// Instant ride tier estimation for the home screen booking panels.
class RideTierEstimate extends Equatable {
  final String id;
  final String name;
  final String badge;
  final int etaMinutes;
  final String vehicleDetails;
  final double priceCad;
  final double? originalPriceCad;

  const RideTierEstimate({
    required this.id,
    required this.name,
    required this.badge,
    required this.etaMinutes,
    required this.vehicleDetails,
    required this.priceCad,
    this.originalPriceCad,
  });

  String get etaText => '$etaMinutes mins away • $vehicleDetails';
  String get formattedPrice => '\$${priceCad.toStringAsFixed(2)}';
  String? get formattedOriginalPrice =>
      originalPriceCad != null ? '\$${originalPriceCad!.toStringAsFixed(2)}' : null;

  @override
  List<Object?> get props => [
        id,
        name,
        badge,
        etaMinutes,
        vehicleDetails,
        priceCad,
        originalPriceCad,
      ];
}
