import 'package:bridgecabs_core/http/refresh_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('refreshes a 401 once', () {
    expect(
      shouldAttemptRefresh(
        statusCode: 401,
        path: '/driver/me/state',
        retried: false,
      ),
      isTrue,
    );
    expect(
      shouldAttemptRefresh(
        statusCode: 401,
        path: '/driver/me/state',
        retried: true,
      ),
      isFalse,
    );
  });

  test('otp and refresh do not refresh again', () {
    expect(
      shouldAttemptRefresh(
        statusCode: 401,
        path: '/auth/otp/verify',
        retried: false,
      ),
      isFalse,
    );
    expect(
      shouldAttemptRefresh(
        statusCode: 401,
        path: '/auth/refresh',
        retried: false,
      ),
      isFalse,
    );
  });
}
