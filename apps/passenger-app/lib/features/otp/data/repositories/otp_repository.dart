import 'dart:async';

abstract class OtpRepository {
  /// Submits the 6-digit code for verification.
  /// Returns `true` if valid, or throws an exception if incorrect or expired.
  Future<bool> verifyOtp(String phone, String code);

  /// Requests a fresh OTP code to be dispatched via SMS.
  Future<void> resendOtp(String phone);
}

class OtpRepositoryImpl implements OtpRepository {
  final Future<void> Function(String code)? _customVerify;
  final Future<void> Function()? _customResend;

  OtpRepositoryImpl({
    Future<void> Function(String code)? customVerify,
    Future<void> Function()? customResend,
  })  : _customVerify = customVerify,
        _customResend = customResend;

  @override
  Future<bool> verifyOtp(String phone, String code) async {
    if (_customVerify != null) {
      await _customVerify!(code);
      return true;
    }

    // Default simulation delay
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    // Simple validation rule: reject if code starts with '000000' or throws
    if (code == '730942') {
      throw const FormatException('Incorrect code. Please try again.');
    }
    return true;
  }

  @override
  Future<void> resendOtp(String phone) async {
    if (_customResend != null) {
      await _customResend!();
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 900));
  }
}
