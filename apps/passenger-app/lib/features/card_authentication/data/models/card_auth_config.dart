import 'card_auth_model.dart';

class CardAuthConfig {
  static const double defaultFareCad = 22.10;
  static const String bookingId = '#LTC-89104';
  static const String pickupAddress = '440 University Dr W';
  static const String dropoffAddress = '501 1st Ave S';
  static const String routeTitle = 'Downtown Central ➔ Lethbridge Park';

  static const String errDeclinedGeneric = 'ERR_DECLINED_GENERIC';
  static const String declinedErrorMessage =
      'Your card was declined. No booking was made and your account was not charged.';

  static const String expiredErrorMessage =
      'This card has expired. Please choose another payment method.';

  static const List<AuthPaymentMethod> mockMethods = [
    AuthPaymentMethod(
      id: 'pm_visa_4242',
      brand: 'Visa',
      last4: '4242',
      expiry: '08/26',
      accountType: 'Personal account',
      isDeclined: true,
      subtitle: 'Expires 08/26',
    ),
    AuthPaymentMethod(
      id: 'pm_mc_1984',
      brand: 'Mastercard',
      last4: '1984',
      expiry: '11/27',
      accountType: 'Debit card',
      isBackup: true,
      subtitle: 'Expires 11/27',
    ),
    AuthPaymentMethod(
      id: 'pm_cash',
      brand: 'Cash',
      last4: '',
      expiry: '',
      isCash: true,
      subtitle: 'Pay your driver directly at drop-off',
    ),
  ];

  static const AuthPaymentMethod expiredCardMethod = AuthPaymentMethod(
    id: 'pm_visa_expired',
    brand: 'Visa',
    last4: '4242',
    expiry: '04/24',
    accountType: 'Personal account',
    isExpired: true,
    subtitle: 'Expired (04/24)',
  );
}
