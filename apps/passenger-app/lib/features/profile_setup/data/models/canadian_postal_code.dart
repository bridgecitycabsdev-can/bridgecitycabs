/// Helper for validating, formatting, and resolving Canadian postal codes,
/// with localized neighborhood resolution for Lethbridge and Southern Alberta.
class CanadianPostalCode {
  static final RegExp _cleanRegex = RegExp(r'[^A-Za-z0-9]');
  static final RegExp _validRegex =
      RegExp(r'^[A-CEGHJ-NPR-TVXY]\d[A-CEGHJ-NPR-TV-Z] ?\d[A-CEGHJ-NPR-TV-Z]\d$', caseSensitive: false);

  /// Cleans and formats postal code into `A1A 1A1` standard format.
  static String format(String input) {
    final cleaned = input.replaceAll(_cleanRegex, '').toUpperCase();
    if (cleaned.length <= 3) {
      return cleaned;
    }
    final prefix = cleaned.substring(0, 3);
    final suffix = cleaned.substring(3, cleaned.length > 6 ? 6 : cleaned.length);
    return '$prefix $suffix';
  }

  /// Validates standard Canadian Postal Code format.
  static bool isValid(String input) {
    final trimmed = input.trim().toUpperCase();
    return _validRegex.hasMatch(trimmed);
  }

  /// Resolves Lethbridge & Southern Alberta community/neighborhood names from postal code forward sortation area (FSA).
  static String? resolveRegion(String postalCode) {
    final clean = postalCode.replaceAll(_cleanRegex, '').toUpperCase();
    if (clean.length < 3) return null;
    final fsa = clean.substring(0, 3);

    switch (fsa) {
      case 'T1K':
        return 'West Lethbridge';
      case 'T1J':
        return 'South / Downtown Lethbridge';
      case 'T1H':
        return 'North Lethbridge';
      case 'T4T':
        return 'Coaldale';
      case 'T0L':
        return 'Southern Alberta County';
      case 'T1L':
        return 'Banff / Alberta';
      default:
        if (clean.startsWith('T')) return 'Alberta';
        return 'Canada';
    }
  }
}
