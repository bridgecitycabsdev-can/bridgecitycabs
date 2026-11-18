import 'payment_card_model.dart';

class PaymentMethodsConfig {
  static const String transitHeaderSubtitle =
      'Pay with a saved card or cash on any trip.';

  static const String southernAlbertaGuaranteeTitle =
      'Southern Alberta Dispatch Guarantee';
  static const String southernAlbertaGuaranteeSubtitle =
      'Zero surge booking fees on scheduled medical, transit, and airport pickups.';

  static const String instantReceiptsTitle = 'Instant Digital Receipts';
  static const String instantReceiptsSubtitle =
      'Ride receipts and GST breakdowns are automatically sent to your verified email after drop-off.';

  static const String stripeSecurityNotice =
      'Cards are processed securely by Stripe. Bridge City Cabs never stores your card number.';

  static const String stripeSecurityNoticeFull =
      'Bank-grade end-to-end encryption. Cards are processed securely by Stripe. Bridge City Cabs never stores your card number or CVV.';

  static const String secureTransitFooter =
      'Bridge City Cabs • Lethbridge Secure Pay';

  static const String defaultUpdateErrorMessage =
      "Couldn't update your card. Try again.";

  static const List<PaymentCard> mockCards = [
    PaymentCard(
      id: 'card_visa_4242',
      brand: CardBrand.visa,
      last4: '4242',
      expiry: '08/28',
      isDefault: true,
    ),
    PaymentCard(
      id: 'card_mc_8821',
      brand: CardBrand.mastercard,
      last4: '8821',
      expiry: '11/26',
      isDefault: false,
    ),
  ];
}
