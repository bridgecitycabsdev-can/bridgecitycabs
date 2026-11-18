import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/home_config.dart';
import '../../data/models/home_mode.dart';
import '../../data/models/waypoint.dart';
import '../../data/repositories/home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _repository;

  HomeBloc({required HomeRepository repository})
      : _repository = repository,
        super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeModeChanged>(_onModeChanged);
    on<HomePickupUpdated>(_onPickupUpdated);
    on<HomeDropoffUpdated>(_onDropoffUpdated);
    on<HomeStopAdded>(_onStopAdded);
    on<HomeStopRemoved>(_onStopRemoved);
    on<HomeWaypointsReordered>(_onWaypointsReordered);
    on<HomeCategorySelected>(_onCategorySelected);
    on<HomeGpsEnableTapped>(_onGpsEnableTapped);
    on<HomeRecenterMapTapped>(_onRecenterMapTapped);
    on<HomeDrawerToggled>(_onDrawerToggled);
    on<HomeContinueTapped>(_onContinueTapped);
    on<HomeLogoutTapped>(_onLogoutTapped);
  }

  Future<void> _onStarted(
    HomeStarted event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading));

    final profile = await _repository.getUserProfile();
    final isGpsOn = await _repository.isLocationServiceEnabled();

    final defaultWaypoints = _getWaypointsForMode(event.initialMode);
    final estimates = await _repository.getEstimates(waypoints: defaultWaypoints);

    emit(state.copyWith(
      status: HomeStatus.ready,
      mode: event.initialMode,
      profile: profile,
      isLocationServiceEnabled:
          event.initialMode == HomeMode.bookRide ? false : isGpsOn,
      waypoints: defaultWaypoints,
      estimates: estimates,
      selectedEstimate: estimates.isNotEmpty ? estimates.first : null,
    ));
  }

  Future<void> _onModeChanged(
    HomeModeChanged event,
    Emitter<HomeState> emit,
  ) async {
    final waypoints = _getWaypointsForMode(event.mode);
    final estimates = await _repository.getEstimates(waypoints: waypoints);

    emit(state.copyWith(
      mode: event.mode,
      waypoints: waypoints,
      estimates: estimates,
      selectedEstimate: estimates.isNotEmpty ? estimates.first : null,
      isLocationServiceEnabled: event.mode != HomeMode.bookRide,
    ));
  }

  void _onPickupUpdated(
    HomePickupUpdated event,
    Emitter<HomeState> emit,
  ) {
    final updated = List<Waypoint>.from(state.waypoints);
    final index = updated.indexWhere((w) => w.isPickup);
    if (index >= 0) {
      updated[index] = event.pickup;
    } else {
      updated.insert(0, event.pickup);
    }
    emit(state.copyWith(waypoints: updated));
  }

  void _onDropoffUpdated(
    HomeDropoffUpdated event,
    Emitter<HomeState> emit,
  ) {
    final updated = List<Waypoint>.from(state.waypoints);
    final index = updated.indexWhere((w) => w.isDropoff);
    if (event.dropoff == null) {
      if (index >= 0) updated.removeAt(index);
    } else {
      if (index >= 0) {
        updated[index] = event.dropoff!;
      } else {
        updated.add(event.dropoff!);
      }
    }
    emit(state.copyWith(waypoints: updated));
  }

  void _onStopAdded(
    HomeStopAdded event,
    Emitter<HomeState> emit,
  ) {
    final updated = List<Waypoint>.from(state.waypoints);
    // Insert before dropoff if dropoff exists, else append
    final dropoffIndex = updated.indexWhere((w) => w.isDropoff);
    if (dropoffIndex >= 0) {
      updated.insert(dropoffIndex, event.stop);
    } else {
      updated.add(event.stop);
    }
    emit(state.copyWith(waypoints: updated));
  }

  void _onStopRemoved(
    HomeStopRemoved event,
    Emitter<HomeState> emit,
  ) {
    final updated = state.waypoints.where((w) => w.id != event.waypointId).toList();
    emit(state.copyWith(waypoints: updated));
  }

  void _onWaypointsReordered(
    HomeWaypointsReordered event,
    Emitter<HomeState> emit,
  ) {
    final updated = List<Waypoint>.from(state.waypoints);
    var newIndex = event.newIndex;
    if (newIndex > event.oldIndex) {
      newIndex -= 1;
    }
    final item = updated.removeAt(event.oldIndex);
    updated.insert(newIndex, item);
    emit(state.copyWith(waypoints: updated));
  }

  void _onCategorySelected(
    HomeCategorySelected event,
    Emitter<HomeState> emit,
  ) {
    final newCategory =
        state.selectedCategory == event.categoryId ? null : event.categoryId;
    emit(state.copyWith(selectedCategory: newCategory));
  }

  Future<void> _onGpsEnableTapped(
    HomeGpsEnableTapped event,
    Emitter<HomeState> emit,
  ) async {
    await _repository.openLocationSettings();
  }

  void _onRecenterMapTapped(
    HomeRecenterMapTapped event,
    Emitter<HomeState> emit,
  ) {
    // Map recenters to Lethbridge center
  }

  void _onDrawerToggled(
    HomeDrawerToggled event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(isDrawerOpen: event.isOpen));
  }

  void _onContinueTapped(
    HomeContinueTapped event,
    Emitter<HomeState> emit,
  ) {
    if (state.mode == HomeMode.planRide ||
        state.mode == HomeMode.bookRide ||
        state.mode == HomeMode.readyToRide) {
      emit(state.copyWith(targetRoute: '/search'));
    }
  }

  Future<void> _onLogoutTapped(
    HomeLogoutTapped event,
    Emitter<HomeState> emit,
  ) async {
    await _repository.logout();
    emit(state.copyWith(targetRoute: '/phone'));
  }

  List<Waypoint> _getWaypointsForMode(HomeMode mode) {
    switch (mode) {
      case HomeMode.whereTo:
        return const [
          Waypoint(
            id: 'wp_pickup',
            type: WaypointType.pickup,
            title: HomeConfig.currentLocation,
            subtitle: 'Lethbridge, AB',
            lat: HomeConfig.lethbridgeCenterLat,
            lng: HomeConfig.lethbridgeCenterLng,
            tag: 'Now',
          ),
        ];

      case HomeMode.readyToRide:
        return const [
          Waypoint(
            id: 'wp_pickup',
            type: WaypointType.pickup,
            title: HomeConfig.downtownPickupName,
            subtitle: '515 5th Ave S, Lethbridge',
            lat: 49.6950,
            lng: -112.8390,
            tag: 'Now',
          ),
          Waypoint(
            id: 'wp_dropoff',
            type: WaypointType.dropoff,
            title: HomeConfig.parkPlaceDropoffName,
            subtitle: '501 1 Ave S, Lethbridge',
            lat: 49.6990,
            lng: -112.8420,
            tag: 'Est. 6m',
          ),
        ];

      case HomeMode.bookRide:
        return const [
          Waypoint(
            id: 'wp_pickup',
            type: WaypointType.pickup,
            title: 'Enter pickup',
            subtitle: 'Lethbridge, AB',
            lat: 49.6956,
            lng: -112.8451,
          ),
          Waypoint(
            id: 'wp_dropoff',
            type: WaypointType.dropoff,
            title: '440 University Dr, Lethbridge',
            subtitle: 'West Lethbridge',
            lat: 49.6780,
            lng: -112.8650,
          ),
        ];

      case HomeMode.planRide:
        return const [
          Waypoint(
            id: 'wp_pickup',
            type: WaypointType.pickup,
            title: 'Univ of Lethbridge',
            subtitle: '4401 University Dr W, Lethbridge',
            lat: 49.6780,
            lng: -112.8650,
            tag: 'Now',
          ),
          Waypoint(
            id: 'wp_stop_1',
            type: WaypointType.stop,
            title: 'Safeway West',
            subtitle: '2750 University Dr W, Lethbridge',
            lat: 49.6890,
            lng: -112.8550,
            tag: '+5 min wait',
            waitTimeMinutes: 5,
          ),
          Waypoint(
            id: 'wp_dropoff',
            type: WaypointType.dropoff,
            title: '4th Ave S',
            subtitle: 'Downtown Commercial Area, Lethbrid...',
            lat: 49.6960,
            lng: -112.8390,
            tag: 'Est. 16m',
          ),
        ];
    }
  }
}
