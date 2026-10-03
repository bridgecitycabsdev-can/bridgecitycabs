import 'package:driver_app/location_buffer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps the last 50 points', () {
    final buffer = LocationBuffer(capacity: 50);
    for (var i = 0; i < 60; i++) {
      buffer.add({'n': i});
    }
    expect(buffer.length, 50);
    expect(buffer.points.first['n'], 10);
    expect(buffer.points.last['n'], 59);
  });

  test('flushes buffered pings in order after reconnect', () async {
    final buffer = LocationBuffer(capacity: 50, batchSize: 20);
    for (var i = 0; i < 45; i++) {
      buffer.add({'n': i});
    }
    final sent = <int>[];
    await buffer.flush((chunk) async {
      for (final row in chunk) {
        sent.add(row['n'] as int);
      }
    });
    expect(sent, List.generate(45, (i) => i));
    expect(buffer.length, 0);
  });

  test('puts unsent points back when a batch fails', () async {
    final buffer = LocationBuffer(capacity: 50, batchSize: 10);
    for (var i = 0; i < 25; i++) {
      buffer.add({'n': i});
    }
    var calls = 0;
    try {
      await buffer.flush((chunk) async {
        calls++;
        if (calls == 2) throw Exception('offline');
      });
      fail('expected flush to throw');
    } catch (_) {}
    expect(buffer.points.map((e) => e['n']), List.generate(15, (i) => i + 10));
  });
}
