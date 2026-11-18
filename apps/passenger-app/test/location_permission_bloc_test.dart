import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:passenger_app/features/location_permission/location_permission.dart';

class MockLocationPermissionRepository implements LocationPermissionRepository {
  bool serviceEnabled = true;
  LocationPermission permission = LocationPermission.denied;
  Position? currentPosition;
  bool openedAppSettings = false;
  bool openedLocationSettings = false;

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<LocationPermission> requestPermission() async => permission;

  @override
  Future<Position?> getCurrentPosition() async => currentPosition;

  @override
  Future<bool> openAppSettings() async {
    openedAppSettings = true;
    return true;
  }

  @override
  Future<bool> openLocationSettings() async {
    openedLocationSettings = true;
    return true;
  }
}

void main() {
  group('LocationPermissionBloc Tests', () {
    late MockLocationPermissionRepository repository;
    late LocationPermissionBloc bloc;

    setUp(() {
      repository = MockLocationPermissionRepository();
      bloc = LocationPermissionBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is LocationPermissionPromptState', () {
      expect(bloc.state, isA<LocationPermissionPromptState>());
      expect(bloc.state.status, LocationPermissionStatus.prompt);
      expect(bloc.state.isPrompt, isTrue);
      expect(bloc.state.isUnavailable, isFalse);
    });

    test('CheckRequested emits Unavailable when GPS is disabled', () async {
      repository.serviceEnabled = false;

      bloc.add(const LocationPermissionCheckRequested());

      await expectLater(
        bloc.stream,
        emits(predicate<LocationPermissionState>((state) {
          return state is LocationPermissionUnavailableState &&
              state.isGpsDisabled == true;
        })),
      );
    });

    test('CheckRequested emits Unavailable when permission is deniedForever', () async {
      repository.serviceEnabled = true;
      repository.permission = LocationPermission.deniedForever;

      bloc.add(const LocationPermissionCheckRequested());

      await expectLater(
        bloc.stream,
        emits(predicate<LocationPermissionState>((state) {
          return state is LocationPermissionUnavailableState &&
              state.isGpsDisabled == false;
        })),
      );
    });

    test('CheckRequested emits Granted when permission is already whileInUse', () async {
      repository.serviceEnabled = true;
      repository.permission = LocationPermission.whileInUse;
      repository.currentPosition = Position(
        longitude: -112.8451,
        latitude: 49.6956,
        timestamp: DateTime(2026, 11, 16),
        accuracy: 5.0,
        altitude: 910.0,
        altitudeAccuracy: 1.0,
        heading: 0.0,
        headingAccuracy: 1.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      bloc.add(const LocationPermissionCheckRequested());

      await expectLater(
        bloc.stream,
        emits(predicate<LocationPermissionState>((state) {
          return state is LocationPermissionGrantedState &&
              state.targetRoute == '/home' &&
              state.position?.latitude == 49.6956;
        })),
      );
    });

    test('AllowTapped emits Granted when user accepts permission', () async {
      repository.serviceEnabled = true;
      repository.permission = LocationPermission.whileInUse;

      bloc.add(const LocationPermissionAllowTapped());

      await expectLater(
        bloc.stream,
        emits(predicate<LocationPermissionState>((state) {
          return state is LocationPermissionGrantedState &&
              state.targetRoute == '/home';
        })),
      );
    });

    test('AllowTapped emits Unavailable when user denies permission', () async {
      repository.serviceEnabled = true;
      repository.permission = LocationPermission.denied;

      bloc.add(const LocationPermissionAllowTapped());

      await expectLater(
        bloc.stream,
        emits(predicate<LocationPermissionState>((state) {
          return state is LocationPermissionUnavailableState;
        })),
      );
    });

    test('OpenSettingsTapped invokes openAppSettings when permission is denied', () async {
      bloc.add(const LocationPermissionOpenSettingsTapped());
      await Future.delayed(const Duration(milliseconds: 20));

      expect(repository.openedAppSettings, isTrue);
    });

    test('SearchAddressTapped emits ManualSearch state', () async {
      bloc.add(const LocationPermissionSearchAddressTapped());

      await expectLater(
        bloc.stream,
        emits(predicate<LocationPermissionState>((state) {
          return state is LocationPermissionManualSearchState &&
              state.targetRoute == '/home';
        })),
      );
    });

    test('ManualPickupTapped emits ManualSearch state', () async {
      bloc.add(const LocationPermissionManualPickupTapped());

      await expectLater(
        bloc.stream,
        emits(predicate<LocationPermissionState>((state) {
          return state is LocationPermissionManualSearchState &&
              state.targetRoute == '/home';
        })),
      );
    });

    test('HubSelected emits ManualSearch state with selected hub', () async {
      final hub = LocationHub.predefinedHubs.first; // Park Place
      bloc.add(LocationPermissionHubSelected(hub));

      await expectLater(
        bloc.stream,
        emits(predicate<LocationPermissionState>((state) {
          return state is LocationPermissionManualSearchState &&
              state.selectedHub?.id == 'park_place' &&
              state.targetRoute == '/home';
        })),
      );
    });

    test('SkipTapped emits ManualSearch state to proceed to /home', () async {
      bloc.add(const LocationPermissionSkipTapped());

      await expectLater(
        bloc.stream,
        emits(predicate<LocationPermissionState>((state) {
          return state is LocationPermissionManualSearchState &&
              state.targetRoute == '/home';
        })),
      );
    });
  });
}
