import 'dart:async';
import '../models/fare_breakdown.dart';
import '../models/payment_method_info.dart';

abstract class ConfirmTripRepository {
  Future<bool> bookTrip({
    required PaymentMethodInfo payment,
    required double totalAmount,
  });

  Future<FareBreakdown?> checkForFareUpdate();
  Future<PaymentMethodInfo> linkNewCard();
}

class ConfirmTripRepositoryImpl implements ConfirmTripRepository {
  final bool simulateDecline;
  final bool simulateFareChange;

  ConfirmTripRepositoryImpl({
    this.simulateDecline = false,
    this.simulateFareChange = false,
  });

  @override
  Future<bool> bookTrip({
    required PaymentMethodInfo payment,
    required double totalAmount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (simulateDecline && payment.isCard) {
      throw Exception('Payment card declined by issuer.');
    }

    return true;
  }

  @override
  Future<FareBreakdown?> checkForFareUpdate() async {
    if (simulateFareChange) {
      return FareBreakdown.fareChanged;
    }
    return null;
  }

  @override
  Future<PaymentMethodInfo> linkNewCard() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return PaymentMethodInfo.linkedVisa;
  }
}
