import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class RideOptionTier extends Equatable {
  final String id;
  final String name;
  final String categoryTag;
  final String? badgeLabel;
  final int etaMinutes;
  final int seats;
  final String features;
  final double baseFareCad;
  final double gstCad;
  final double totalFareCad;
  final double? originalFareCad;
  final double promoDiscountCad;
  final bool isFastest;
  final bool isAvailable;
  final String? unavailableReason;
  final IconData icon;

  const RideOptionTier({
    required this.id,
    required this.name,
    required this.categoryTag,
    this.badgeLabel,
    required this.etaMinutes,
    required this.seats,
    required this.features,
    required this.baseFareCad,
    required this.gstCad,
    required this.totalFareCad,
    this.originalFareCad,
    this.promoDiscountCad = 0.0,
    this.isFastest = false,
    this.isAvailable = true,
    this.unavailableReason,
    required this.icon,
  });

  String get formattedTotal => '\$${totalFareCad.toStringAsFixed(2)} CAD';
  String get formattedPriceBare => '\$${totalFareCad.toStringAsFixed(2)}';
  String get formattedBase => '\$${baseFareCad.toStringAsFixed(2)}';
  String get formattedGst => '\$${gstCad.toStringAsFixed(2)}';
  String? get formattedOriginal =>
      originalFareCad != null ? '\$${originalFareCad!.toStringAsFixed(2)}' : null;

  bool get hasDiscount => promoDiscountCad > 0.0 && originalFareCad != null;

  RideOptionTier applyDiscount(double discountCad) {
    final original = originalFareCad ?? totalFareCad;
    final newTotal = (original - discountCad).clamp(5.0, 999.0);
    final newSubtotal = (newTotal / 1.05);
    final newGst = newTotal - newSubtotal;

    return RideOptionTier(
      id: id,
      name: name,
      categoryTag: categoryTag,
      badgeLabel: badgeLabel,
      etaMinutes: etaMinutes,
      seats: seats,
      features: features,
      baseFareCad: double.parse(newSubtotal.toStringAsFixed(2)),
      gstCad: double.parse(newGst.toStringAsFixed(2)),
      totalFareCad: newTotal,
      originalFareCad: original,
      promoDiscountCad: discountCad,
      isFastest: isFastest,
      isAvailable: isAvailable,
      unavailableReason: unavailableReason,
      icon: icon,
    );
  }

  RideOptionTier removeDiscount() {
    final orig = originalFareCad ?? totalFareCad;
    final subtotal = orig / 1.05;
    final gst = orig - subtotal;

    return RideOptionTier(
      id: id,
      name: name,
      categoryTag: categoryTag,
      badgeLabel: badgeLabel,
      etaMinutes: etaMinutes,
      seats: seats,
      features: features,
      baseFareCad: double.parse(subtotal.toStringAsFixed(2)),
      gstCad: double.parse(gst.toStringAsFixed(2)),
      totalFareCad: orig,
      originalFareCad: null,
      promoDiscountCad: 0.0,
      isFastest: isFastest,
      isAvailable: isAvailable,
      unavailableReason: unavailableReason,
      icon: icon,
    );
  }

  static const List<RideOptionTier> standardTiers = [
    RideOptionTier(
      id: 'sedan',
      name: 'Sedan',
      categoryTag: 'Medium',
      badgeLabel: 'RECOMMENDED',
      etaMinutes: 3,
      seats: 4,
      features: 'Reliable everyday transit · 4 seats',
      baseFareCad: 17.52,
      gstCad: 0.88,
      totalFareCad: 18.40,
      originalFareCad: null,
      isFastest: true,
      isAvailable: true,
      icon: Icons.directions_car_rounded,
    ),
    RideOptionTier(
      id: 'suv',
      name: 'SUV',
      categoryTag: 'Big',
      badgeLabel: 'BIG',
      etaMinutes: 6,
      seats: 6,
      features: 'Extra winter traction · 6 seats',
      baseFareCad: 23.33,
      gstCad: 1.17,
      totalFareCad: 24.50,
      originalFareCad: null,
      icon: Icons.airport_shuttle_rounded,
    ),
    RideOptionTier(
      id: 'minivan',
      name: 'Minivan',
      categoryTag: 'Big',
      badgeLabel: 'BIG',
      etaMinutes: 8,
      seats: 6,
      features: 'Luggage friendly · 6 seats',
      baseFareCad: 26.67,
      gstCad: 1.33,
      totalFareCad: 28.00,
      originalFareCad: null,
      icon: Icons.directions_bus_rounded,
    ),
    RideOptionTier(
      id: 'luxury',
      name: 'Executive Camry',
      categoryTag: 'Premium',
      badgeLabel: 'PREMIUM',
      etaMinutes: 8,
      seats: 4,
      features: 'Executive sedans · Top drivers',
      baseFareCad: 29.52,
      gstCad: 1.48,
      totalFareCad: 31.00,
      originalFareCad: null,
      icon: Icons.local_taxi_rounded,
    ),
  ];

  static List<RideOptionTier> withLuxuryUnavailable() {
    return [
      standardTiers[0],
      standardTiers[1],
      standardTiers[2],
      const RideOptionTier(
        id: 'luxury',
        name: 'Executive Camry',
        categoryTag: 'Premium',
        badgeLabel: 'PREMIUM',
        etaMinutes: 0,
        seats: 4,
        features: 'Executive sedans · Top drivers',
        baseFareCad: 29.52,
        gstCad: 1.48,
        totalFareCad: 31.00,
        isAvailable: false,
        unavailableReason: 'Not available right now • No cabs near',
        icon: Icons.local_taxi_rounded,
      ),
    ];
  }

  static List<RideOptionTier> promoAppliedTiers() {
    return [
      const RideOptionTier(
        id: 'sedan',
        name: 'Sedan',
        categoryTag: 'Medium',
        badgeLabel: 'RECOMMENDED',
        etaMinutes: 3,
        seats: 4,
        features: 'Reliable everyday transit · 4 seats',
        baseFareCad: 14.10,
        gstCad: 0.70,
        totalFareCad: 15.40,
        originalFareCad: 18.40,
        promoDiscountCad: 3.00,
        isFastest: true,
        isAvailable: true,
        icon: Icons.directions_car_rounded,
      ),
      const RideOptionTier(
        id: 'suv',
        name: 'SUV · Big',
        categoryTag: 'Big',
        badgeLabel: 'BIG',
        etaMinutes: 6,
        seats: 6,
        features: 'Extra winter traction · 6 seats',
        baseFareCad: 20.57,
        gstCad: 1.03,
        totalFareCad: 21.60,
        originalFareCad: 24.60,
        promoDiscountCad: 3.00,
        icon: Icons.airport_shuttle_rounded,
      ),
      const RideOptionTier(
        id: 'luxury',
        name: 'Premium',
        categoryTag: 'Premium',
        badgeLabel: 'PREMIUM',
        etaMinutes: 8,
        seats: 4,
        features: 'Executive sedans · Top drivers',
        baseFareCad: 26.67,
        gstCad: 1.33,
        totalFareCad: 28.00,
        originalFareCad: 31.00,
        promoDiscountCad: 3.00,
        icon: Icons.local_taxi_rounded,
      ),
    ];
  }

  @override
  List<Object?> get props => [
        id,
        name,
        categoryTag,
        badgeLabel,
        etaMinutes,
        seats,
        features,
        baseFareCad,
        gstCad,
        totalFareCad,
        originalFareCad,
        promoDiscountCad,
        isFastest,
        isAvailable,
        unavailableReason,
        icon,
      ];
}
