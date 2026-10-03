import 'package:bridgecabs_core/driver/server_clock.dart';
import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('countdown uses the server clock when the device is 10 seconds slow', () {
    fakeAsync((async) {
      final serverClock = ServerClock();
      // Device clock is behind the server by 10 seconds.
      serverClock.sync(clock.now().toUtc().add(const Duration(seconds: 10)));
      final expiresAt = serverClock.now().add(const Duration(seconds: 15));

      int remainingMs() {
        final left = expiresAt.difference(serverClock.now());
        return left.isNegative ? 0 : left.inMilliseconds;
      }

      expect(remainingMs(), closeTo(15_000, 50));
      async.elapse(const Duration(seconds: 5));
      expect(remainingMs(), closeTo(10_000, 50));
      async.elapse(const Duration(seconds: 12));
      expect(remainingMs(), 0);
    });
  });

  test('server offset shortens the offer window by the skew', () {
    withClock(Clock.fixed(DateTime.utc(2026, 10, 3, 18, 0, 0)), () {
      final serverClock = ServerClock();
      serverClock.sync(DateTime.utc(2026, 10, 3, 18, 0, 10));
      final expiresAt = DateTime.utc(2026, 10, 3, 18, 0, 25);
      // Device would see 25s left; server clock leaves 15s.
      expect(expiresAt.difference(clock.now().toUtc()).inSeconds, 25);
      expect(expiresAt.difference(serverClock.now()).inSeconds, 15);
    });
  });
}
