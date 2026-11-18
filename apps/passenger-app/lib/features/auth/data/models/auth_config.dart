/// Localized strings, constants, and layout configuration for Auth screens.
class AuthConfig {
  static const String appBrand = 'BRIDGE CITY';
  static const String appSubtitle = 'CABS • ALBERTA';
  static const String screenTitle = 'Login';
  static const String screenSubtitle = 'Login to start a journey with us.';

  static const String phoneFieldLabel = 'Mobile Phone Number';
  static const String phonePlaceholder = 'Enter number';
  static const String phoneExample = '587 329 5577';
  static const String phoneExampleWithRegion = 'e.g. 587 329 5577 (Alberta)';
  static const String phoneErrorPrompt = 'Enter a valid phone number';
  static const String readyForDispatch =
      'Ready for dispatch across Southern Alberta';

  // Cooldown / Rate Limit Banner Strings
  static const String tooManyAttemptsTitle = 'Too many attempts';
  static const String cooldownMessage =
      'For security, requests are temporarily paused. Try again after the cool-down expires.';
  static const String cooldownWaitHint =
      'Wait 5 minutes before requesting another code';
  static const String cooldownActiveTag = 'Cooldown active';

  // Help / Support Card Strings
  static const String helpHeader = 'Having trouble logging in?';
  static const String helpSubtext = 'Call dispatch or check service status';
  static const String helpButtonText = 'Help';
  static const String dispatchHotlineUrl = 'tel:4035552227';

  // Info Cards Strings
  static const String instantSmsTitle = 'Instant SMS Verification';
  static const String instantSmsSubtext =
      'We will send a 4-digit rapid dispatch code to verify your ride profile.';

  static const String dispatchingPinTitle = 'Dispatching 6-digit PIN';
  static const String dispatchingPinSubtext =
      'Standard message rates may apply via Telus / Rogers / Bell';

  static const String albertaRegionalTitle = 'Alberta Regional Code';
  static const String albertaRegionalSubtext =
      'We support Lethbridge, Calgary, and standard 10-digit mobile lines across Canada.';

  // Buttons & Actions
  static const String continueButton = 'Continue';
  static const String sendingCodeButton = 'Sending code...';
  static const String editWrongNumber = 'Entered wrong number?';
  static const String editText = 'Edit';

  // Footers
  static const String footerRegionsClassic =
      'LETHBRIDGE • COALDALE • CLARESHOLM';
  static const String footerRegionsServing =
      'Serving Lethbridge, Coaldale & Surrounding County';
  static const String termsText = 'Terms and Conditions';
  static const String privacyText = 'Privacy Policy';
}
