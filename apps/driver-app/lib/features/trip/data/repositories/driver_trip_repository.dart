import 'package:url_launcher/url_launcher.dart';
import '../models/driver_cancel_reason.dart';
import '../models/driver_trip_config.dart';
import '../models/driver_trip_model.dart';

abstract class DriverTripRepository {
  Future<DriverTripModel> fetchActiveTrip();
  Future<void> markArrived(String tripId);
  Future<void> startTrip(String tripId);
  Future<void> cancelTrip({
    required String tripId,
    required DriverCancelReason reason,
  });
  Future<void> launchNavigation({required String address});
}

class FakeDriverTripRepository implements DriverTripRepository {
  DriverTripModel _currentTrip;

  FakeDriverTripRepository({DriverTripModel? initialTrip})
      : _currentTrip = initialTrip ?? DriverTripConfig.headingToPickupPreset;

  @override
  Future<DriverTripModel> fetchActiveTrip() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _currentTrip;
  }

  @override
  Future<void> markArrived(String tripId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _currentTrip = _currentTrip.copyWith(
      distanceAwayMeters: 0,
      distanceKm: 0.0,
      etaMinutes: 0,
      currentSpeedKmh: 0,
      nextTurnGuidance: 'Arrived at pickup location',
    );
  }

  @override
  Future<void> startTrip(String tripId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _currentTrip = _currentTrip.copyWith(
      nextTurnGuidance: 'Heading to dropoff destination',
    );
  }

  @override
  Future<void> cancelTrip({
    required String tripId,
    required DriverCancelReason reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _currentTrip = _currentTrip.copyWith(
      selectedCancelReason: reason,
    );
  }

  @override
  Future<void> launchNavigation({required String address}) async {
    final query = Uri.encodeComponent(address);
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // In tests or headless environments, fallback silently.
    }
  }
}
