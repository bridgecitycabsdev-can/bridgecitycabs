import 'package:driver_app/location_ping.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('omits unknown heading and speed', () {
    final payload = locationPing(
      lat: 49.69,
      lng: -112.84,
      heading: -1,
      speedMps: -1,
      accuracyM: 8,
      recordedAt: DateTime.utc(2026, 10, 2, 15),
    );
    expect(payload['lat'], 49.69);
    expect(payload['recordedAt'], '2026-10-02T15:00:00.000Z');
    expect(payload.containsKey('heading'), isFalse);
    expect(payload.containsKey('speedMps'), isFalse);
    expect(payload['accuracyM'], 8);
  });
}
