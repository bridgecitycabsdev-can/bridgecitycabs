import 'package:geolocator/geolocator.dart';
import '../models/ride_tier_estimate.dart';
import '../models/user_profile_summary.dart';
import '../models/waypoint.dart';

abstract class HomeRepository {
  Future<UserProfileSummary> getUserProfile();
  Future<bool> isLocationServiceEnabled();
  Future<bool> openLocationSettings();
  Future<List<RideTierEstimate>> getEstimates({required List<Waypoint> waypoints});
  Future<void> logout();
}

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<UserProfileSummary> getUserProfile() async {
    return const UserProfileSummary(
      name: 'Sarah Mitchell',
      rating: 4.96,
      riderStatus: 'Lethbridge Rider',
      unreadNotifications: 2,
      defaultPayment: 'Personal •••• 8842',
    );
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
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<RideTierEstimate>> getEstimates({
    required List<Waypoint> waypoints,
  }) async {
    final isMultiStop = waypoints.length > 2;

    if (isMultiStop) {
      return const [
        RideTierEstimate(
          id: 'crimson_standard',
          name: 'Crimson Standard',
          badge: 'Fastest',
          etaMinutes: 3,
          vehicleDetails: 'Toyota RAV4',
          priceCad: 21.40,
          originalPriceCad: 24.00,
        ),
      ];
    }

    return const [
      RideTierEstimate(
        id: 'city_red_cruiser',
        name: 'City Red Cruiser',
        badge: 'Fast',
        etaMinutes: 3,
        vehicleDetails: '4 seats',
        priceCad: 14.20,
        originalPriceCad: 17.50,
      ),
    ];
  }

  @override
  Future<void> logout() async {
    // Clear auth session
  }
}
