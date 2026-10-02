/// Canadian numbers become E.164 (`+1` and ten digits) before they are sent.
abstract final class CanadaPhone {
  static final _nonDigits = RegExp(r'\D');

  static String? toE164(String raw) {
    var digits = raw.replaceAll(_nonDigits, '');
    if (digits.length == 11 && digits.startsWith('1')) {
      digits = digits.substring(1);
    }
    if (digits.length != 10) return null;
    return '+1$digits';
  }
}

class PhoneException implements Exception {
  const PhoneException(this.message);
  final String message;

  @override
  String toString() => message;
}
