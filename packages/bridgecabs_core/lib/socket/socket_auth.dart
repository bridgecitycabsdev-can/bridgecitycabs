bool isUnauthenticated(Object? error) {
  if (error == null) return false;
  if (error is Map) {
    final message = error['message'] ?? error['data'];
    if (message != null && '$message'.contains('UNAUTHENTICATED')) return true;
  }
  return error.toString().contains('UNAUTHENTICATED');
}
