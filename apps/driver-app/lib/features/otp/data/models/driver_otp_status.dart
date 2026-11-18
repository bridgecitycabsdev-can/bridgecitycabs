enum DriverOtpStatus {
  initial, // Fresh entry with cursor in first box and dashes, countdown active, "OTP sent successfully"
  ready, // All 6 digits entered, red "Verify code ➔" active
  submitting, // Spinner on button "Verifying code...", "Authenticating with Lethbridge Dispatch..."
  incorrect, // Red boxes with error banner "Incorrect code. Please try again."
  expired, // Grey boxes with "Code expired (10:00 limit reached)", "Request a new code" card, locked button
  verified, // Successfully verified and routed to pathway destination
}

extension DriverOtpStatusX on DriverOtpStatus {
  bool get isInitial => this == DriverOtpStatus.initial;
  bool get isReady => this == DriverOtpStatus.ready;
  bool get isSubmitting => this == DriverOtpStatus.submitting;
  bool get isIncorrect => this == DriverOtpStatus.incorrect;
  bool get isExpired => this == DriverOtpStatus.expired;
  bool get isVerified => this == DriverOtpStatus.verified;

  bool get canSubmit => this == DriverOtpStatus.ready;
}
