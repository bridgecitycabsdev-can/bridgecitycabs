import '../models/promo_code.dart';
import '../models/ride_option_tier.dart';

abstract class ChooseRideRepository {
  Future<List<RideOptionTier>> getRideTiers({bool simulateUnavailable = false});
  Future<PromoCode> validatePromoCode(String code);
  Future<bool> lockFare(String tierId);
}

class ChooseRideRepositoryImpl implements ChooseRideRepository {
  @override
  Future<List<RideOptionTier>> getRideTiers({
    bool simulateUnavailable = false,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    if (simulateUnavailable) {
      return RideOptionTier.withLuxuryUnavailable();
    }
    return RideOptionTier.standardTiers;
  }

  @override
  Future<PromoCode> validatePromoCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final trimmed = code.trim().toUpperCase();

    if (trimmed == 'LETHBRIDGE3' || trimmed == 'LETH3') {
      return PromoCode.lethbridge3;
    }

    return PromoCode(
      code: code,
      description: '',
      discountAmountCad: 0.0,
      isValid: false,
      errorMessage: 'Invalid or expired promo code. Check code and try again.',
    );
  }

  @override
  Future<bool> lockFare(String tierId) async {
    return true;
  }
}
