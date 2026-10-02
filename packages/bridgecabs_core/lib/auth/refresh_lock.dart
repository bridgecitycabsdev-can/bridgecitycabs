/// One refresh for a burst of 401s. A second caller awaits the same future.
class RefreshLock {
  Future<String?>? _flight;

  Future<String?> run(Future<String?> Function() refresh) {
    final existing = _flight;
    if (existing != null) return existing;
    late final Future<String?> flight;
    flight = refresh().whenComplete(() {
      if (identical(_flight, flight)) _flight = null;
    });
    _flight = flight;
    return flight;
  }
}
