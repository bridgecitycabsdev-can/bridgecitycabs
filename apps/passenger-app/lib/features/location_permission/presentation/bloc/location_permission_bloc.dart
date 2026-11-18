import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/repositories/location_permission_repository.dart';
import 'location_permission_event.dart';
import 'location_permission_state.dart';

class LocationPermissionBloc
    extends Bloc<LocationPermissionEvent, LocationPermissionState> {
  final LocationPermissionRepository _repository;

  LocationPermissionBloc({required LocationPermissionRepository repository})
      : _repository = repository,
        super(const LocationPermissionPromptState()) {
    on<LocationPermissionCheckRequested>(_onCheckRequested);
    on<LocationPermissionAllowTapped>(_onAllowTapped);
    on<LocationPermissionOpenSettingsTapped>(_onOpenSettingsTapped);
    on<LocationPermissionSearchAddressTapped>(_onSearchAddressTapped);
    on<LocationPermissionManualPickupTapped>(_onManualPickupTapped);
    on<LocationPermissionHubSelected>(_onHubSelected);
    on<LocationPermissionSkipTapped>(_onSkipTapped);
  }

  Future<void> _onCheckRequested(
    LocationPermissionCheckRequested event,
    Emitter<LocationPermissionState> emit,
  ) async {
    final serviceEnabled = await _repository.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(const LocationPermissionUnavailableState(isGpsDisabled: true));
      return;
    }

    final permission = await _repository.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      final position = await _repository.getCurrentPosition();
      emit(LocationPermissionGrantedState(
        position: position,
        targetRoute: '/home',
      ));
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      emit(const LocationPermissionUnavailableState());
      return;
    }

    emit(const LocationPermissionPromptState());
  }

  Future<void> _onAllowTapped(
    LocationPermissionAllowTapped event,
    Emitter<LocationPermissionState> emit,
  ) async {
    final serviceEnabled = await _repository.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(const LocationPermissionUnavailableState(isGpsDisabled: true));
      return;
    }

    final permission = await _repository.requestPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      final position = await _repository.getCurrentPosition();
      emit(LocationPermissionGrantedState(
        position: position,
        targetRoute: '/home',
      ));
    } else {
      emit(const LocationPermissionUnavailableState());
    }
  }

  Future<void> _onOpenSettingsTapped(
    LocationPermissionOpenSettingsTapped event,
    Emitter<LocationPermissionState> emit,
  ) async {
    if (state is LocationPermissionUnavailableState &&
        (state as LocationPermissionUnavailableState).isGpsDisabled) {
      await _repository.openLocationSettings();
    } else {
      await _repository.openAppSettings();
    }
  }

  void _onSearchAddressTapped(
    LocationPermissionSearchAddressTapped event,
    Emitter<LocationPermissionState> emit,
  ) {
    emit(const LocationPermissionManualSearchState(targetRoute: '/home'));
  }

  void _onManualPickupTapped(
    LocationPermissionManualPickupTapped event,
    Emitter<LocationPermissionState> emit,
  ) {
    emit(const LocationPermissionManualSearchState(targetRoute: '/home'));
  }

  void _onHubSelected(
    LocationPermissionHubSelected event,
    Emitter<LocationPermissionState> emit,
  ) {
    emit(LocationPermissionManualSearchState(
      selectedHub: event.hub,
      targetRoute: '/home',
    ));
  }

  void _onSkipTapped(
    LocationPermissionSkipTapped event,
    Emitter<LocationPermissionState> emit,
  ) {
    emit(const LocationPermissionManualSearchState(targetRoute: '/home'));
  }
}
