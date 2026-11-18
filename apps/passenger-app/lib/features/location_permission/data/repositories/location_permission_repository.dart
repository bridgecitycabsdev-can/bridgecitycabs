import 'dart:async';
import 'package:geolocator/geolocator.dart';

abstract class LocationPermissionRepository {
  /// Checks current permission status.
  Future<LocationPermission> checkPermission();

  /// Prompts the system location permission dialog.
  Future<LocationPermission> requestPermission();

  /// Checks if device GPS location services are turned on.
  Future<bool> isLocationServiceEnabled();

  /// Opens system app settings so the passenger can manually toggle permissions.
  Future<bool> openAppSettings();

  /// Opens system location settings if GPS is switched off.
  Future<bool> openLocationSettings();

  /// Fetches the passenger's current position if permission is granted.
  Future<Position?> getCurrentPosition();
}

class LocationPermissionRepositoryImpl implements LocationPermissionRepository {
  @override
  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (_) {
      return LocationPermission.denied;
    }
  }

  @override
  Future<LocationPermission> requestPermission() async {
    try {
      return await Geolocator.requestPermission();
    } catch (_) {
      return LocationPermission.denied;
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (_) {
      return null;
    }
  }
}
