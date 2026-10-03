import 'dart:async';

import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'location_buffer.dart';
import 'location_ping.dart';
import 'location_settings.dart';

enum LocationSendStatus { idle, sending, denied, needsConsent }

typedef PermissionRequester = Future<LocationPermission> Function();
typedef PermissionChecker = Future<LocationPermission> Function();
typedef PositionStreamFactory =
    Stream<Position> Function({LocationSettings? locationSettings});

/// On-shift location via a foreground service (Android) / background mode (iOS).
///
/// Never tracks off-shift. Buffers up to 50 pings while the socket is down and
/// flushes them to `POST /driver/location/batch` on reconnect.
class LocationPublisher extends ChangeNotifier {
  LocationPublisher(
    this._socket,
    this._dio, {
    LocationBuffer? buffer,
    PermissionChecker? checkPermission,
    PermissionRequester? requestPermission,
    PositionStreamFactory? positionStream,
  }) : _buffer = buffer ?? LocationBuffer(),
       _checkPermission = checkPermission ?? Geolocator.checkPermission,
       _requestPermission = requestPermission ?? Geolocator.requestPermission,
       _positionStream = positionStream ?? Geolocator.getPositionStream;

  final BridgeSocket _socket;
  final Dio _dio;
  final LocationBuffer _buffer;
  final PermissionChecker _checkPermission;
  final PermissionRequester _requestPermission;
  final PositionStreamFactory _positionStream;

  StreamSubscription<Position>? _positions;
  DateTime? _lastSent;
  var _session = 0;
  var _intervalSec = 15;
  var _consentAccepted = false;
  var _permissionAllowed = false;
  LocationSendStatus status = LocationSendStatus.idle;

  LocationBuffer get buffer => _buffer;
  bool get isRunning => _positions != null;
  int get intervalSec => _intervalSec;
  bool get consentAccepted => _consentAccepted;

  void markConsentAccepted() {
    _consentAccepted = true;
    if (status == LocationSendStatus.needsConsent) {
      status = LocationSendStatus.idle;
      notifyListeners();
    }
  }

  /// Start or retune the stream. No-op when [onShift] is false (always stops).
  Future<void> sync({
    required bool onShift,
    required bool bookingActive,
  }) async {
    if (!onShift) {
      stop();
      return;
    }
    final nextInterval = intervalSecondsFor(bookingActive: bookingActive);
    if (isRunning && _intervalSec == nextInterval) return;
    await _start(intervalSec: nextInterval);
  }

  Future<void> start({required int intervalSec}) =>
      _start(intervalSec: intervalSec);

  Future<void> _start({required int intervalSec}) async {
    if (!_consentAccepted) {
      // Cold start / process death: OS may already hold When In Use from a
      // prior disclosure. Do not re-prompt consent; do not request permission.
      final existing = await _checkPermission();
      final alreadyGranted =
          existing == LocationPermission.whileInUse ||
          existing == LocationPermission.always;
      if (!alreadyGranted) {
        status = LocationSendStatus.needsConsent;
        notifyListeners();
        return;
      }
      _consentAccepted = true;
      _permissionAllowed = true;
    }
    final session = ++_session;
    final granted = await _ensurePermission();
    if (session != _session) return;
    if (!granted) return;

    _positions?.cancel();
    _positions = null;
    _intervalSec = intervalSec;
    _positions = _positionStream(
      locationSettings: settingsFor(intervalSec),
    ).listen(_onPosition);
    status = LocationSendStatus.sending;
    notifyListeners();
  }

  void stop() {
    _session++;
    _positions?.cancel();
    _positions = null;
    _lastSent = null;
    if (status != LocationSendStatus.idle &&
        status != LocationSendStatus.needsConsent) {
      status = LocationSendStatus.idle;
      notifyListeners();
    }
  }

  /// Flush buffered pings after the socket reconnects (oldest first).
  Future<void> flushBuffer() async {
    await _buffer.flush((chunk) async {
      await _dio.post<dynamic>(
        '/driver/location/batch',
        data: {'points': chunk},
      );
    });
  }

  Future<bool> _ensurePermission() async {
    if (_permissionAllowed) return true;
    var permission = await _checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _requestPermission();
    }
    final granted =
        permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
    _permissionAllowed = granted;
    if (!granted) {
      status = LocationSendStatus.denied;
      notifyListeners();
    }
    return granted;
  }

  void _onPosition(Position position) => _emit(position);

  void _emit(Position position) {
    final now = DateTime.now();
    final last = _lastSent;
    if (last != null &&
        now.difference(last) < Duration(seconds: _intervalSec)) {
      return;
    }
    final ping = locationPing(
      lat: position.latitude,
      lng: position.longitude,
      heading: position.heading,
      speedMps: position.speed,
      accuracyM: position.accuracy,
      recordedAt: now,
    );
    final batchPoint = <String, dynamic>{
      'lat': position.latitude,
      'lng': position.longitude,
      'accuracy': position.accuracy.isFinite ? position.accuracy : 0,
      'recordedAt': now.toUtc().toIso8601String(),
    };

    if (_socket.isConnected) {
      final sent = _socket.emit('driver:location', ping);
      if (sent) {
        _lastSent = now;
        return;
      }
    }
    _buffer.add(batchPoint);
    _lastSent = now;
  }
}
