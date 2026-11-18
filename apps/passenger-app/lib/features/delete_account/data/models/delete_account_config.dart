class DeleteAccountConfig {
  static const String warningTitle = 'Delete your account?';
  static const String warningSubtitle =
      'This will permanently remove your Bridge City Cabs account and personal data after a short waiting period.';

  static const List<String> deletedItems = [
    'Your profile and phone number',
    'Saved cards (removed from your account)',
    'Notifications and support ticket history',
    'Saved trip preferences and home tags',
  ];

  static const List<String> keptItems = [
    "Trip and payment records we're required to keep by law",
    'Records needed to resolve disputes or safety reports',
  ];

  static const String keptItemsDisclaimer =
      'Kept records are no longer linked to your profile where possible.';

  static const String gracePeriodNotice =
      "You'll have 30 days to change your mind. Log in anytime during this period to instantly restore your account.";

  static const String privacyPolicyLink =
      'Read our Privacy Policy (Alberta PIPA)';

  static const String complianceFooter =
      'Regulated under City of Lethbridge Taxi Commission Bylaws • Passenger Safety Standard';

  static const String confirmDeletionTitle = 'Confirm deletion';
  static const String confirmDeletionSubtitle =
      'This irreversible step disconnects your trip history, saved Lethbridge routes, and payment profiles from Bridge City Cabs.';

  static const String acknowledgmentText =
      "I understand that my account will be permanently scheduled for deletion and I won't be able to recover trip data or credits after the waiting period.";

  static const String phoneMasked = '+1 (403) ••• ••17';

  static const String supportPhone = '403-555-CABS';
}
