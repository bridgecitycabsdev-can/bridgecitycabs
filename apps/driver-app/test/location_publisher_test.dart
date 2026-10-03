import 'dart:async';

import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:dio/dio.dart';
import 'package:driver_app/location_buffer.dart';
import 'package:driver_app/location_publisher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  test('does not request permission until consent is accepted', () async {
    var permissionCalls = 0;
    final publisher = LocationPublisher(
      BridgeSocket(),
      Dio(),
      checkPermission: () async {
        permissionCalls++;
        return LocationPermission.denied;
      },
      requestPermission: () async {
        permissionCalls++;
        return LocationPermission.whileInUse;
      },
      positionStream: ({locationSettings}) => const Stream.empty(),
    );

    await publisher.start(intervalSec: 15);
    expect(publisher.status, LocationSendStatus.needsConsent);
    expect(permissionCalls, 1); // check only; no request
    expect(publisher.isRunning, isFalse);

    publisher.markConsentAccepted();
    await publisher.start(intervalSec: 15);
    expect(permissionCalls, greaterThan(1));
  });

  test('buffers pings while socket is down and flushes in order', () async {
    final buffer = LocationBuffer();
    final batches = <List<Map<String, dynamic>>>[];
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/driver/location/batch')) {
              batches.add(
                List<Map<String, dynamic>>.from(
                  (options.data as Map)['points'] as List,
                ),
              );
              handler.resolve(
                Response(requestOptions: options, data: {'accepted': 1}),
              );
              return;
            }
            handler.next(options);
          },
        ),
      );

    final controller = StreamController<Position>();
    final publisher = LocationPublisher(
      BridgeSocket(),
      dio,
      buffer: buffer,
      checkPermission: () async => LocationPermission.whileInUse,
      requestPermission: () async => LocationPermission.whileInUse,
      positionStream: ({locationSettings}) => controller.stream,
    );
    publisher.markConsentAccepted();
    await publisher.start(intervalSec: 5);

    controller.add(_pos(1));
    await Future<void>.delayed(Duration.zero);
    expect(buffer.length, 1);
    expect(buffer.points.first['lat'], closeTo(49.6901, 0.00001));

    await publisher.flushBuffer();
    expect(buffer.length, 0);
    expect(batches.single, hasLength(1));
    expect(batches.single.single['lat'], closeTo(49.6901, 0.00001));
    await controller.close();
  });
}

Position _pos(int n) {
  return Position(
    longitude: -112.84,
    latitude: 49.69 + n * 0.0001,
    timestamp: DateTime.utc(2026, 10, 3, 12, 0, n),
    accuracy: 5,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 90,
    headingAccuracy: 0,
    speed: 10,
    speedAccuracy: 0,
  );
}
