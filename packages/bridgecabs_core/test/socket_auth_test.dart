import 'package:bridgecabs_core/socket/socket_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('detects an unauthenticated connect error', () {
    expect(isUnauthenticated('UNAUTHENTICATED'), isTrue);
    expect(isUnauthenticated({'message': 'UNAUTHENTICATED'}), isTrue);
    expect(isUnauthenticated('timeout'), isFalse);
  });
}
