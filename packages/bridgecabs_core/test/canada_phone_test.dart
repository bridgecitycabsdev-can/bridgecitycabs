import 'package:bridgecabs_core/phone/canada_phone.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalises Canadian numbers to E.164', () {
    expect(CanadaPhone.toE164('403-555-0100'), '+14035550100');
    expect(CanadaPhone.toE164('4035550100'), '+14035550100');
    expect(CanadaPhone.toE164('(403) 555-0100'), '+14035550100');
    expect(CanadaPhone.toE164('+1 403 555 0100'), '+14035550100');
    expect(CanadaPhone.toE164('14035550100'), '+14035550100');
  });

  test('rejects numbers that are not ten digits', () {
    expect(CanadaPhone.toE164('403555'), isNull);
    expect(CanadaPhone.toE164(''), isNull);
    expect(CanadaPhone.toE164('40355501001'), isNull);
  });
}
