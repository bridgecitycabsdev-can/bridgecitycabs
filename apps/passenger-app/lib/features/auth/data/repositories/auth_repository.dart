import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../models/auth_config.dart';
import '../models/phone_number_validation.dart';

class RateLimitException implements Exception {
  final int cooldownSeconds;
  final String message;

  const RateLimitException({
    required this.cooldownSeconds,
    required this.message,
  });

  @override
  String toString() => message;
}

abstract class AuthRepository {
  /// Sends OTP to the provided Canadian phone number.
  /// Throws [RateLimitException] if too many attempts were made.
  Future<String> requestOtp(String rawPhone);

  /// Launches the phone dialer to reach passenger dispatch support.
  Future<bool> callDispatchSupport();
}

class AuthRepositoryImpl implements AuthRepository {
  final Future<String> Function(String rawPhone)? _customRequestOtp;

  AuthRepositoryImpl({Future<String> Function(String rawPhone)? customRequestOtp})
      : _customRequestOtp = customRequestOtp;

  @override
  Future<String> requestOtp(String rawPhone) async {
    if (_customRequestOtp != null) {
      return _customRequestOtp!(rawPhone);
    }

    final e164 = CanadianPhoneUtils.toE164(rawPhone);
    if (e164 == null) {
      throw const FormatException('Invalid Canadian phone number');
    }

    // Simulate API delay
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    return e164;
  }

  @override
  Future<bool> callDispatchSupport() async {
    final uri = Uri.parse(AuthConfig.dispatchHotlineUrl);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }
}
