/// Configuration constants and phone masking helper for the OTP verification flow.
class OtpConfig {
  static const int codeLength = 6;
  static const int defaultResendSeconds = 30;
  static const int maxAttempts = 3;

  static const String appTitle = 'Bridge City Cabs';
  static const String enterOtpTitle = 'Enter OTP';
  static const String verifyButton = 'Verify code';
  static const String verifyingButton = 'Verifying code...';
  static const String resendButton = 'Resend code';
  static const String resendNowButton = 'Resend code now';
  static const String editPhoneText = 'Edit';

  // Badges & notices
  static const String autoFilledBadge = 'Code auto-filled from SMS';
  static const String otpSentSuccess = 'OTP sent successfully';
  static const String lockedBadge = 'LOCKED';
  static const String syncingNotice = 'Securing local transit channel...';
  static const String syncingTag = 'Syncing';
  static const String encryptedNotice =
      'End-to-end encrypted dispatch network';

  // Expired card copy
  static const String expiredTitle = 'Code Expired (00:00)';
  static const String expiredTag = 'Timeout';
  static const String expiredDescription =
      'This security token has timed out for your protection. Please generate a fresh code to continue.';
  static const String havenGotCodeYet = "Haven't got the code yet?";
  static const String smsGatewaySubtext =
      'Instant SMS transmission via Lethbridge Gateway';

  /// Formats phone into masked format e.g. `+1 (587) ••• ••77`.
  static String maskPhone(String phone) {
    var digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 11 && digits.startsWith('1')) {
      digits = digits.substring(1);
    }
    if (digits.length >= 10) {
      final area = digits.substring(0, 3);
      final lastTwo = digits.substring(digits.length - 2);
      return '+1 ($area) ••• ••$lastTwo';
    }
    return phone.isNotEmpty ? phone : '+1 (587) ••• ••77';
  }
}
