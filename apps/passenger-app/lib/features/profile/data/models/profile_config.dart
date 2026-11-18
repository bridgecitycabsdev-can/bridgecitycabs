import 'user_profile_model.dart';

class ProfileConfig {
  static const String appVersion = 'Version 1.0.19';
  static const String buildNumber = 'Build 240';
  static const String bylawCode = 'Bylaw 5898';
  static const String regionalDispatchPhone = '(403) 327-4005';
  static const String privacyEmail = 'privacy@bridgecabs.ca';
  static const String supportEmail = 'support@bridgecabs.ca';

  static const String pipComplianceNotice =
      'Bridge City Cabs complies with Alberta Personal Information Protection Act (PIPA). For local compliance inquiries, reach out to privacy@bridgecabs.ca.';

  static const String lethalBridgeDispatchNotice =
      'Locally operated in Lethbridge, AB. Serving southern Alberta since 2012.';

  static const String highLevelBridgeNotice =
      'Reliable wheels across the Oldman River coulees, downtown, and West Lethbridge.';

  static const UserProfile defaultProfile = UserProfile(
    id: 'USR-8492',
    fullName: 'Robert Vance',
    phoneNumber: '+1 (403) 555-0192',
    email: 'robert.vance@uleth.ca',
    rating: 5.0,
    totalRides: 42,
    memberSince: '2023',
    isVerified: true,
    riderTier: 'Lethbridge Rider',
    defaultPaymentMethod: 'Visa ending in 4242 • Default',
    notificationsSummary: 'Push & SMS active',
    notificationsEnabled: true,
    privacySummary: 'Location & card policies',
  );

  static const UserProfile settingsProfile = UserProfile(
    id: 'USR-5182',
    fullName: 'Jesse Campbell',
    phoneNumber: '+1 (403) 555-0182',
    email: 'jesse.campbell@yqlmail.ca',
    rating: 4.9,
    totalRides: 28,
    memberSince: '2022',
    isVerified: true,
    riderTier: 'Rider',
    defaultPaymentMethod: 'Mastercard ending in 1902 • Default',
    notificationsSummary: 'Push & SMS active',
    notificationsEnabled: true,
    privacySummary: 'Location & card policies',
  );
}
