import 'faq_item_model.dart';

class SideMenuAndSettingsConfig {
  static const String appName = 'Bridge City Cabs';
  static const String appSubtitle = 'Lethbridge Transit';
  static const String passengerBadge = 'Passenger';

  // Addresses & Contact
  static const String companyAddress = '326F 10 Street North, Lethbridge, AB T1H 2C7';
  static const String companyPhone = '+1 (587) 329-5577';
  static const String companyWebsite = 'www.bridgecitycabs.ca';
  static const String aboutDescription =
      'Local Lethbridge dispatch for trips across the city and to the airport.';
  static const String lethbridgeAddress = companyAddress;
  static const String dispatchPhone = companyPhone;
  static const String websiteUrl = companyWebsite;
  static const String dispatchAssistance = '24/7 Lethbridge dispatch assistance';

  // Versions
  static const String gridVersion = 'Version 1.0.19 • Lethbridge, AB';
  static const String listVersion = 'Bridge City Cabs v4.12.0 • Southern Alberta';
  static const String settingsVersion = 'Version 1.0.19 (Build 240) • Made in Alberta';

  // Alerts
  static const String notificationsOffWarning =
      'Notifications are off for this app in system settings. You may miss driver arrival alerts.';
  static const String activeTripLogoutLocked =
      'Finish your trip before logging out.';

  // FAQs
  static const List<FaqItem> defaultFaqs = [
    FaqItem(
      id: 'faq_fare_calc',
      question: 'How are fares calculated in Lethbridge?',
      answer:
          'Fares are regulated under City of Lethbridge Taxi Commission Bylaws. Rates combine a standardized drop rate, per-kilometer distance fee, and idle traffic time.',
      category: FaqCategory.booking,
      meteredFareBox: MeteredFareBoxData(),
    ),
    FaqItem(
      id: 'faq_cash_payment',
      question: 'Can I pay cash to the driver?',
      answer:
          'Yes, cash is accepted on all rides. Please notify the driver upon boarding or select Cash Payment during booking. In-cab card terminals are also available.',
      category: FaqCategory.payments,
    ),
    FaqItem(
      id: 'faq_lost_item',
      question: 'What if I left an item in the taxi?',
      answer:
          'Report a lost item immediately via the Support menu or call dispatch at +1 (587) 329-5577. All rides are track-logged to identify the assigned cab immediately.',
      category: FaqCategory.safety,
    ),
    FaqItem(
      id: 'faq_airport',
      question: 'How early should I book for Lethbridge Airport (YQL)?',
      answer:
          'We recommend booking at least 30 minutes in advance for airport pickups, especially during peak morning flights or winter conditions across the coulees.',
      category: FaqCategory.airport,
    ),
  ];
}
