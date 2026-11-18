import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../../../data/datasources/sos_remote_datasource.dart';
import '../models/sos_alert_config.dart';
import '../models/sos_alert_model.dart';

abstract class SosAlertRepository {
  Future<SosRideTelemetry> getRideTelemetry({String? tripId});
  Future<bool> sendEmergencyAlert({
    required SosRideTelemetry telemetry,
    bool forceOffline = false,
  });
  Future<void> updateEmergencyLocation({required String address});
  Future<void> cancelAlert();
  Future<LocationServiceStatus> checkLocationService();
}

class MockSosAlertRepository implements SosAlertRepository {
  final SosRideTelemetry _telemetry;
  final Duration delay;
  bool _simulateNetworkFailure;
  bool _locationEnabled;

  MockSosAlertRepository({
    SosRideTelemetry? telemetry,
    this.delay = const Duration(milliseconds: 50),
    bool simulateNetworkFailure = false,
    bool locationEnabled = true,
  })  : _telemetry = telemetry ?? SosAlertConfig.defaultTelemetry,
        _simulateNetworkFailure = simulateNetworkFailure,
        _locationEnabled = locationEnabled;

  void setSimulateNetworkFailure(bool fail) {
    _simulateNetworkFailure = fail;
  }

  void setLocationEnabled(bool enabled) {
    _locationEnabled = enabled;
  }

  @override
  Future<SosRideTelemetry> getRideTelemetry({String? tripId}) async {
    await Future.delayed(delay);
    return _telemetry;
  }

  @override
  Future<bool> sendEmergencyAlert({
    required SosRideTelemetry telemetry,
    bool forceOffline = false,
  }) async {
    await Future.delayed(delay);
    if (forceOffline || _simulateNetworkFailure) {
      throw Exception(
        'Cellular handshake failed near Whoop-Up Dr corridor. Packet queued locally.',
      );
    }
    return true;
  }

  @override
  Future<void> updateEmergencyLocation({required String address}) async {
    await Future.delayed(delay);
  }

  @override
  Future<void> cancelAlert() async {
    await Future.delayed(delay);
  }

  @override
  Future<LocationServiceStatus> checkLocationService() async {
    await Future.delayed(delay);
    return _locationEnabled
        ? LocationServiceStatus.enabled
        : LocationServiceStatus.disabled;
  }
}

class ApiSosAlertRepository implements SosAlertRepository {
  ApiSosAlertRepository(this._remote, {this.bookingId});

  final SosRemoteDataSource _remote;
  final String? bookingId;

  @override
  Future<SosRideTelemetry> getRideTelemetry({String? tripId}) async {
    return SosAlertConfig.defaultTelemetry;
  }

  @override
  Future<bool> sendEmergencyAlert({
    required SosRideTelemetry telemetry,
    bool forceOffline = false,
  }) async {
    if (forceOffline) {
      throw Exception('No network. Stay on the line if you can call.');
    }
    final position = await Geolocator.getCurrentPosition();
    await _remote.trigger(
      bookingId: bookingId,
      lat: position.latitude,
      lng: position.longitude,
    );
    return true;
  }

  @override
  Future<void> updateEmergencyLocation({required String address}) async {
    await sendEmergencyAlert(
      telemetry: SosAlertConfig.defaultTelemetry,
    );
  }

  @override
  Future<void> cancelAlert() async {}

  @override
  Future<LocationServiceStatus> checkLocationService() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    return enabled
        ? LocationServiceStatus.enabled
        : LocationServiceStatus.disabled;
  }
}
