const _skipRefresh = [
  '/auth/login',
  '/auth/refresh',
  '/auth/logout',
  '/auth/otp/request',
  '/auth/otp/verify',
];

/// A 401 refreshes once, then the original request is replayed.
/// Login, OTP, refresh, and logout do not refresh.
bool shouldAttemptRefresh({
  required int? statusCode,
  required String path,
  required bool retried,
}) {
  if (retried || statusCode != 401) return false;
  return !_skipRefresh.any(path.contains);
}
