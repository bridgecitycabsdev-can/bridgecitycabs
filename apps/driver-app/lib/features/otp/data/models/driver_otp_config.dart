class DriverOtpConfig {
  static const String appTitle = 'BRIDGE CITY CABS';
  static const String screenTitle = 'Driver Verification';
  static const String driverBadge = 'DRIVER';
  static const String driverPortalBadge = 'DRIVER PORTAL';

  static const String heading = 'Enter OTP';
  static const String instructionPrefix = 'We sent a code to';
  static const String instructionSuffix = 'Please enter the 6-digit code.';
  static const String defaultMaskedPhone = '+1 (403) ••• ••17';

  // Status & Notifications
  static const String otpSentSuccess = 'OTP sent successfully';
  static const String incorrectCodeError = 'Incorrect code. Please try again.';
  static const String codeExpiredMessage = 'Code expired (10:00 limit reached)';
  static const String requestNewCodeTitle = 'Request a new code';
  static const String requestNewCodeSubtitle =
      'Instant SMS dispatch to cab console';
  static const String authenticatingDispatch =
      'Authenticating with Lethbridge Dispatch...';

  // Resend
  static const String resendPrompt = "Haven't got the code yet?";
  static const String resendAction = 'Resend code';

  // Buttons
  static const String verifyButtonText = 'Verify code';
  static const String verifyingButtonText = 'Verifying code...';
  static const String lockedVerifyButtonText = 'Verify code';

  // Pathway headers
  static const String routingFlowHeader = 'DRIVER ROUTING FLOW';
  static const String routingPreviewsHeader = 'DISPATCH ROUTING PREVIEWS';
  static const String routingOutcomesHeader = 'VERIFICATION OUTCOMES';
  static const String authenticationRoutesHeader = 'DRIVER AUTHENTICATION ROUTES';
  static const String resolutionPathwaysHeader = 'ROUTING RESOLUTION PATHWAYS';

  // Length
  static const int otpLength = 6;
  static const int defaultResendCooldownSeconds = 30;
}
