import 'package:bridgecabs_core/driver/server_clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('syncs the offset so now() tracks the server', () {
    final clock = ServerClock();
    final serverNow = DateTime.now().toUtc().add(const Duration(seconds: 12));
    clock.sync(serverNow);
    final delta = clock.now().difference(DateTime.now().toUtc()).inMilliseconds;
    expect(delta, closeTo(12_000, 50));
  });
}
