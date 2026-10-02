import 'dart:async';
import 'dart:io' show Platform;

import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'location_ping.dart';

enum LocationSendStatus { idle, sending, denied }

/// Foreground fixes only, sent on `driver:location` every five seconds while
/// the shift is open. Background tracking needs a foreground service, iOS
/// background modes, and store review notes, so it is left for a later day.
class LocationPublisher extends ChangeNotifier {
  LocationPublisher(this._socket);

  final BridgeSocket _socket;
  StreamSubscription<Position>? _positions;
  Timer? _timer;
  Position? _latest;
  DateTime? _lastSent;
  var _session = 0;
  LocationSendStatus status = LocationSendStatus.idle;

  Future<void> start() async {
    if (_timer != null) return;
    final session = ++_session;
    final granted = await _ensurePermission();
    if (session != _session || _timer != null) return;
    if (!granted) return;
    _positions = Geolocator.getPositionStream(
      locationSettings: _settings(),
    ).listen(_onPosition);
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      final latest = _latest;
      if (latest != null) _emit(latest);
    });
    status = LocationSendStatus.sending;
    notifyListeners();
  }

  void stop() {
    _session++;
    _timer?.cancel();
    _timer = null;
    _positions?.cancel();
    _positions = null;
    _latest = null;
    _lastSent = null;
    if (status != LocationSendStatus.idle) {
      status = LocationSendStatus.idle;
      notifyListeners();
    }
  }

  Future<bool> _ensurePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    final granted =
        permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
    if (!granted) {
      status = LocationSendStatus.denied;
      notifyListeners();
    }
    return granted;
  }

  void _onPosition(Position position) {
    _latest = position;
    _emit(position);
  }

  void _emit(Position position) {
    final now = DateTime.now();
    final last = _lastSent;
    if (last != null && now.difference(last) < const Duration(seconds: 5)) {
      return;
    }
    final sent = _socket.emit(
      'driver:location',
      locationPing(
        lat: position.latitude,
        lng: position.longitude,
        heading: position.heading,
        speedMps: position.speed,
        accuracyM: position.accuracy,
        recordedAt: now,
      ),
    );
    if (sent) _lastSent = now;
  }

  LocationSettings _settings() {
    if (!kIsWeb && Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 5),
      );
    }
    if (!kIsWeb && Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: 0,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );
  }
}
