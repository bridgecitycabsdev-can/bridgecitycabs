import 'package:equatable/equatable.dart';
import '../../data/models/home_mode.dart';
import '../../data/models/ride_tier_estimate.dart';
import '../../data/models/user_profile_summary.dart';
import '../../data/models/waypoint.dart';

enum HomeStatus {
  initial,
  loading,
  ready,
  navigating,
}

class HomeState extends Equatable {
  final HomeStatus status;
  final HomeMode mode;
  final List<Waypoint> waypoints;
  final List<RideTierEstimate> estimates;
  final RideTierEstimate? selectedEstimate;
  final String? selectedCategory;
  final bool isLocationServiceEnabled;
  final bool isDrawerOpen;
  final UserProfileSummary profile;
  final String? targetRoute;

  const HomeState({
    this.status = HomeStatus.initial,
    this.mode = HomeMode.whereTo,
    this.waypoints = const [],
    this.estimates = const [],
    this.selectedEstimate,
    this.selectedCategory,
    this.isLocationServiceEnabled = true,
    this.isDrawerOpen = false,
    this.profile = const UserProfileSummary(
      name: 'Sarah Mitchell',
      rating: 4.96,
      riderStatus: 'Lethbridge Rider',
      unreadNotifications: 2,
    ),
    this.targetRoute,
  });

  Waypoint? get pickup {
    try {
      return waypoints.firstWhere((w) => w.isPickup);
    } catch (_) {
      return null;
    }
  }

  Waypoint? get dropoff {
    try {
      return waypoints.firstWhere((w) => w.isDropoff);
    } catch (_) {
      return null;
    }
  }

  List<Waypoint> get stops => waypoints.where((w) => w.isStop).toList();

  bool get hasDropoff => dropoff != null;
  bool get canContinue => dropoff != null;

  String get distanceText {
    if (mode == HomeMode.planRide) {
      return '11.4 km • 16 min';
    }
    return 'Trip distance: 3.4 km • ~6 mins';
  }

  HomeState copyWith({
    HomeStatus? status,
    HomeMode? mode,
    List<Waypoint>? waypoints,
    List<RideTierEstimate>? estimates,
    RideTierEstimate? selectedEstimate,
    String? selectedCategory,
    bool? isLocationServiceEnabled,
    bool? isDrawerOpen,
    UserProfileSummary? profile,
    String? targetRoute,
  }) {
    return HomeState(
      status: status ?? this.status,
      mode: mode ?? this.mode,
      waypoints: waypoints ?? this.waypoints,
      estimates: estimates ?? this.estimates,
      selectedEstimate: selectedEstimate ?? this.selectedEstimate,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLocationServiceEnabled:
          isLocationServiceEnabled ?? this.isLocationServiceEnabled,
      isDrawerOpen: isDrawerOpen ?? this.isDrawerOpen,
      profile: profile ?? this.profile,
      targetRoute: targetRoute,
    );
  }

  @override
  List<Object?> get props => [
        status,
        mode,
        waypoints,
        estimates,
        selectedEstimate,
        selectedCategory,
        isLocationServiceEnabled,
        isDrawerOpen,
        profile,
        targetRoute,
      ];
}
