Map<String, dynamic> locationPing({
  required double lat,
  required double lng,
  required double heading,
  required double speedMps,
  required double accuracyM,
  required DateTime recordedAt,
}) {
  return {
    'lat': lat,
    'lng': lng,
    'recordedAt': recordedAt.toUtc().toIso8601String(),
    if (_inRange(heading, 0, 360)) 'heading': heading,
    if (_inRange(speedMps, 0, double.infinity)) 'speedMps': speedMps,
    if (_inRange(accuracyM, 0, double.infinity)) 'accuracyM': accuracyM,
  };
}

bool _inRange(double value, double min, double max) {
  return value.isFinite && value >= min && value <= max;
}
