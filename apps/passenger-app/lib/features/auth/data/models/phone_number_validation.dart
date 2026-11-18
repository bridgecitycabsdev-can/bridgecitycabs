import 'package:bridgecabs_core/bridgecabs_core.dart';

/// Formatter and validator for Canadian phone numbers (Alberta 403 / 587 / 825 / 780).
class CanadianPhoneUtils {
  static final RegExp _digitsOnly = RegExp(r'\D');

  /// Extracts digits only from a raw phone string.
  static String extractDigits(String input) {
    var digits = input.replaceAll(_digitsOnly, '');
    if (digits.length == 11 && digits.startsWith('1')) {
      digits = digits.substring(1);
    }
    return digits;
  }

  /// Formats clean 10 digits as `(587) 329-5577`.
  /// Handles partial typing gracefully for input formatting.
  static String format(String input) {
    final digits = extractDigits(input);
    if (digits.isEmpty) return '';

    if (digits.length <= 3) {
      return '($digits';
    } else if (digits.length <= 6) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3)}';
    } else {
      final end = digits.length > 10 ? 10 : digits.length;
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6, end)}';
    }
  }

  /// Validates if digits constitute a valid 10-digit Canadian phone line.
  static bool isValid(String input) {
    final digits = extractDigits(input);
    if (digits.length != 10) return false;
    // Valid Canadian area code starts with 2-9
    final first = int.tryParse(digits[0]);
    return first != null && first >= 2;
  }

  /// Converts valid input to E.164 (`+1XXXXXXXXXX`).
  static String? toE164(String input) {
    return CanadaPhone.toE164(input);
  }
}
