import 'package:bridgecabs_core/auth/refresh_lock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('two callers share one refresh', () async {
    var calls = 0;
    final lock = RefreshLock();
    final first = lock.run(() async {
      calls += 1;
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return 'access';
    });
    final second = lock.run(() async {
      calls += 1;
      return 'other';
    });

    expect(await Future.wait([first, second]), ['access', 'access']);
    expect(calls, 1);
  });

  test('a later caller starts a new refresh', () async {
    var calls = 0;
    final lock = RefreshLock();
    await lock.run(() async {
      calls += 1;
      return 'one';
    });
    await lock.run(() async {
      calls += 1;
      return 'two';
    });
    expect(calls, 2);
  });
}
