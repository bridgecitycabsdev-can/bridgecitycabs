import 'package:flutter_stripe/flutter_stripe.dart';

import '../../data/repositories/payment_repository.dart';

/// Opens Stripe's payment sheet for a SetupIntent. Card numbers stay in Stripe.
Future<void> presentCardSetup(PaymentRepository payments) async {
  final key = await payments.publishableKey();
  Stripe.publishableKey = key;
  await Stripe.instance.applySettings();
  final secret = await payments.setupIntentSecret();
  await Stripe.instance.initPaymentSheet(
    paymentSheetParameters: SetupPaymentSheetParameters(
      setupIntentClientSecret: secret,
      merchantDisplayName: 'BridgeCabs',
    ),
  );
  await Stripe.instance.presentPaymentSheet();
}

bool stripeCancelled(Object error) {
  return error is StripeException &&
      error.error.code == FailureCode.Canceled;
}
