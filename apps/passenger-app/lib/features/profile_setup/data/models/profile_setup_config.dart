/// Configuration constants and localized text for the Profile Setup screen.
class ProfileSetupConfig {
  static const String appBarTitle = 'Set Up Your Account';
  static const String stepLabel = 'ONBOARDING';
  static const String stepCountText = 'Step 2 of 3';

  static const String headline = 'Set up your account';
  static const String introNotice =
      'Drivers rely on verified profiles for safe, punctual pickups across Lethbridge.';

  // Photo
  static const String addPhotoOptional = 'Add photo (optional)';
  static const String photoAdded = 'Photo added';
  static const String changePhoto = 'Change';

  // Field Labels
  static const String firstNameLabel = 'First name';
  static const String lastNameLabel = 'Last name';
  static const String emailLabel = 'Institutional or Personal Email';
  static const String emailRequiredLabel = 'Email address';
  static const String postalCodeLabel = 'Home Postal Code';
  static const String postalCodeShortLabel = 'Postal code';
  static const String genderLabel = 'Gender identification';
  static const String genderSafetyHint = 'Optional • Rider safety';

  // Placeholders
  static const String lastNamePlaceholder = 'Legal last name';
  static const String postalCodeExample = 'e.g. T1J 1B7';

  // Readiness Card
  static const String readinessTitle = "You're ready for your first booking!";
  static const String readinessSubtitle =
      'Profile fully authenticated with Bridge City rapid dispatch standards.';

  // Action Buttons
  static const String continueToRideOptions = 'Continue to Ride Options';
  static const String continueButton = 'Continue';
  static const String skipForNow = 'Skip for now';

  // Security Note
  static const String securityNote =
      'Encrypted profile data • Stored securely in Alberta';

  // Validation Errors
  static const String requiredTag = 'Required';
  static const String firstNameRequired = 'First name is required';
  static const String lastNameRequired = 'Last name is required';
  static const String emailInvalid = 'Enter a valid email address';
  static const String postalCodeInvalid =
      'Enter a valid Canadian postal code (e.g. T1J 1B7)';

  static String errorBannerText(int errorCount) =>
      'Please fix the $errorCount highlighted error${errorCount > 1 ? 's' : ''} to continue.';
}
