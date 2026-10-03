/// In-memory ring buffer of location pings while the driver socket is down.
///
/// Cap is 50; flush posts to `/driver/location/batch` in chunks of at most 20
/// (server ArrayMaxSize). Order is oldest → newest.
class LocationBuffer {
  LocationBuffer({this.capacity = 50, this.batchSize = 20});

  final int capacity;
  final int batchSize;
  final List<Map<String, dynamic>> _points = [];

  int get length => _points.length;

  List<Map<String, dynamic>> get points => List.unmodifiable(_points);

  void add(Map<String, dynamic> point) {
    _points.add(point);
    while (_points.length > capacity) {
      _points.removeAt(0);
    }
  }

  void clear() => _points.clear();

  /// Drains the buffer in order, posting each chunk via [sendBatch].
  Future<void> flush(
    Future<void> Function(List<Map<String, dynamic>> chunk) sendBatch,
  ) async {
    if (_points.isEmpty) return;
    final pending = List<Map<String, dynamic>>.from(_points);
    _points.clear();
    for (var i = 0; i < pending.length; i += batchSize) {
      final end = (i + batchSize > pending.length) ? pending.length : i + batchSize;
      final chunk = pending.sublist(i, end);
      try {
        await sendBatch(chunk);
      } catch (_) {
        // Put unsent (and remaining) points back, preserving order.
        _points.insertAll(0, pending.sublist(i));
        while (_points.length > capacity) {
          _points.removeAt(0);
        }
        rethrow;
      }
    }
  }
}
