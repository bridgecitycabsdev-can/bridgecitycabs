import 'package:equatable/equatable.dart';

class FareBreakdown extends Equatable {
  final double subtotalCad;
  final double gstCad;
  final double totalCad;
  final double? transitFeeCad;
  final double? weatherSurchargeCad;
  final bool isGuaranteed;
  final double? newFareCad;
  final double? previousFareCad;

  const FareBreakdown({
    required this.subtotalCad,
    required this.gstCad,
    required this.totalCad,
    this.transitFeeCad,
    this.weatherSurchargeCad,
    this.isGuaranteed = true,
    this.newFareCad,
    this.previousFareCad,
  });

  String get formattedSubtotal => '\$${subtotalCad.toStringAsFixed(2)} CAD';
  String get formattedGst => '\$${gstCad.toStringAsFixed(2)} CAD';
  String get formattedTotal => '\$${totalCad.toStringAsFixed(2)} CAD';
  String? get formattedNewFare =>
      newFareCad != null ? '\$${newFareCad!.toStringAsFixed(2)} CAD' : null;
  String? get formattedPreviousFare =>
      previousFareCad != null ? '\$${previousFareCad!.toStringAsFixed(2)} CAD' : null;

  static const FareBreakdown standard = FareBreakdown(
    subtotalCad: 21.05,
    gstCad: 1.05,
    totalCad: 22.10,
    isGuaranteed: true,
  );

  static const FareBreakdown withWeatherSurcharge = FareBreakdown(
    subtotalCad: 18.40,
    transitFeeCad: 1.25,
    gstCad: 0.95,
    weatherSurchargeCad: 1.50,
    totalCad: 22.10,
    isGuaranteed: true,
  );

  static const FareBreakdown fareChanged = FareBreakdown(
    subtotalCad: 23.43,
    gstCad: 1.17,
    totalCad: 24.60,
    previousFareCad: 22.10,
    newFareCad: 24.60,
    isGuaranteed: true,
  );

  @override
  List<Object?> get props => [
        subtotalCad,
        gstCad,
        totalCad,
        transitFeeCad,
        weatherSurchargeCad,
        isGuaranteed,
        newFareCad,
        previousFareCad,
      ];
}
