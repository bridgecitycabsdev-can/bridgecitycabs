enum DriverAuthStatus {
  initial, // Empty phone input: (403) 000-0000 placeholder, continue disabled
  valid, // Valid 10-digit number: green checkmark, red border, surge zone card, continue active
  invalid, // Incomplete number (e.g. 8 digits): red warning, clear button, continue disabled
  unregistered, // Driver account not found: top error card, register link, continue active
  locked, // Too many attempts (5/5): amber countdown timer card, lock icon, continue locked
  submitting, // Sending SMS verification code: button spinner "Sending code..."
  codeSent, // Code sent: navigate to OTP screen (/code?phone=...)
}

extension DriverAuthStatusX on DriverAuthStatus {
  bool get isInitial => this == DriverAuthStatus.initial;
  bool get isValid => this == DriverAuthStatus.valid;
  bool get isInvalid => this == DriverAuthStatus.invalid;
  bool get isUnregistered => this == DriverAuthStatus.unregistered;
  bool get isLocked => this == DriverAuthStatus.locked;
  bool get isSubmitting => this == DriverAuthStatus.submitting;
  bool get isCodeSent => this == DriverAuthStatus.codeSent;

  bool get canSubmit =>
      this == DriverAuthStatus.valid || this == DriverAuthStatus.unregistered;
}
