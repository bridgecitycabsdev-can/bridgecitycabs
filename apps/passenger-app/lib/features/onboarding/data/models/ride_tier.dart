/// Ride tier option displayed on Onboarding Screen 1.
class RideTier {
  final String id;
  final String name;
  final String typeDescription;
  final int seatCount;
  final int etaMinutes;
  final double fareCad;
  final String? badge;

  const RideTier({
    required this.id,
    required this.name,
    required this.typeDescription,
    required this.seatCount,
    required this.etaMinutes,
    required this.fareCad,
    this.badge,
  });

  String get etaText => '$etaMinutes min away';
  String get fareText => '\$${fareCad.toStringAsFixed(2)}';
  String get seatsText => '$typeDescription • $seatCount seats';

  static const RideTier defaultTier = RideTier(
    id: 'medium',
    name: 'Medium',
    typeDescription: 'Sedan',
    seatCount: 4,
    etaMinutes: 3,
    fareCad: 14.20,
    badge: 'FASTEST',
  );

  static const List<RideTier> sampleTiers = [
    defaultTier,
    RideTier(
      id: 'big',
      name: 'Big',
      typeDescription: 'XL SUV',
      seatCount: 6,
      etaMinutes: 5,
      fareCad: 18.50,
    ),
    RideTier(
      id: 'premium',
      name: 'Premium',
      typeDescription: 'Luxury',
      seatCount: 4,
      etaMinutes: 8,
      fareCad: 23.00,
    ),
  ];
}
