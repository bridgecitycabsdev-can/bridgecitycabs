import 'package:equatable/equatable.dart';
import '../../data/models/home_mode.dart';
import '../../data/models/waypoint.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched on page initialization to load profile, verify GPS, and seed default waypoints.
class HomeStarted extends HomeEvent {
  final HomeMode initialMode;

  const HomeStarted({this.initialMode = HomeMode.whereTo});

  @override
  List<Object?> get props => [initialMode];
}

/// Changes between whereTo, readyToRide, bookRide, and planRide modes.
class HomeModeChanged extends HomeEvent {
  final HomeMode mode;

  const HomeModeChanged(this.mode);

  @override
  List<Object?> get props => [mode];
}

/// Updates pickup location waypoint.
class HomePickupUpdated extends HomeEvent {
  final Waypoint pickup;

  const HomePickupUpdated(this.pickup);

  @override
  List<Object?> get props => [pickup];
}

/// Updates dropoff destination waypoint.
class HomeDropoffUpdated extends HomeEvent {
  final Waypoint? dropoff;

  const HomeDropoffUpdated(this.dropoff);

  @override
  List<Object?> get props => [dropoff];
}

/// Appends an intermediate stop to the itinerary (e.g., Safeway West).
class HomeStopAdded extends HomeEvent {
  final Waypoint stop;

  const HomeStopAdded(this.stop);

  @override
  List<Object?> get props => [stop];
}

/// Removes an intermediate stop by waypoint ID.
class HomeStopRemoved extends HomeEvent {
  final String waypointId;

  const HomeStopRemoved(this.waypointId);

  @override
  List<Object?> get props => [waypointId];
}

/// Reorders stops in the itinerary.
class HomeWaypointsReordered extends HomeEvent {
  final int oldIndex;
  final int newIndex;

  const HomeWaypointsReordered(this.oldIndex, this.newIndex);

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

/// Selects a category chip (Schedule, Airport, Long distance, etc.).
class HomeCategorySelected extends HomeEvent {
  final String categoryId;

  const HomeCategorySelected(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// Opens device settings to enable GPS when location is off.
class HomeGpsEnableTapped extends HomeEvent {
  const HomeGpsEnableTapped();
}

/// Centers the map on the user's location.
class HomeRecenterMapTapped extends HomeEvent {
  const HomeRecenterMapTapped();
}

/// Toggles the passenger navigation drawer.
class HomeDrawerToggled extends HomeEvent {
  final bool isOpen;

  const HomeDrawerToggled(this.isOpen);

  @override
  List<Object?> get props => [isOpen];
}

/// Triggered when passenger taps "Continue" or "Continue to Ride Options".
class HomeContinueTapped extends HomeEvent {
  const HomeContinueTapped();
}

/// Triggered when passenger taps "Log out" in drawer.
class HomeLogoutTapped extends HomeEvent {
  const HomeLogoutTapped();
}
