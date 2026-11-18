import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/home/home.dart';

class MockTestHomeRepository implements HomeRepository {
  bool gpsEnabled = true;
  bool openedSettings = false;
  bool loggedOut = false;

  @override
  Future<UserProfileSummary> getUserProfile() async {
    return const UserProfileSummary(
      name: 'Sarah Mitchell',
      rating: 4.96,
      riderStatus: 'Lethbridge Rider',
      unreadNotifications: 2,
    );
  }

  @override
  Future<bool> isLocationServiceEnabled() async => gpsEnabled;

  @override
  Future<bool> openLocationSettings() async {
    openedSettings = true;
    return true;
  }

  @override
  Future<List<RideTierEstimate>> getEstimates({required List<Waypoint> waypoints}) async {
    if (waypoints.length > 2) {
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
    loggedOut = true;
  }
}

void main() {
  group('HomeBloc Tests', () {
    late MockTestHomeRepository repository;
    late HomeBloc bloc;

    setUp(() {
      repository = MockTestHomeRepository();
      bloc = HomeBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state has default whereTo mode', () {
      expect(bloc.state.mode, HomeMode.whereTo);
      expect(bloc.state.status, HomeStatus.initial);
      expect(bloc.state.isLocationServiceEnabled, isTrue);
      expect(bloc.state.isDrawerOpen, isFalse);
    });

    test('HomeStarted in whereTo mode populates Current location pickup', () async {
      bloc.add(const HomeStarted(initialMode: HomeMode.whereTo));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<HomeState>((s) => s.status == HomeStatus.loading),
          predicate<HomeState>((s) {
            return s.status == HomeStatus.ready &&
                s.mode == HomeMode.whereTo &&
                s.pickup?.title == 'Current location' &&
                s.dropoff == null &&
                s.profile.name == 'Sarah Mitchell';
          }),
        ]),
      );
    });

    test('HomeStarted in readyToRide mode populates Downtown and Park Place', () async {
      bloc.add(const HomeStarted(initialMode: HomeMode.readyToRide));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<HomeState>((s) => s.status == HomeStatus.loading),
          predicate<HomeState>((s) {
            return s.status == HomeStatus.ready &&
                s.mode == HomeMode.readyToRide &&
                s.pickup?.title == 'Downtown (515 5th Ave S)' &&
                s.dropoff?.title == 'Park Place Mall (Main Entrance)' &&
                s.canContinue == true;
          }),
        ]),
      );
    });

    test('HomeStarted in planRide mode populates 3 waypoints and Crimson Standard estimate', () async {
      bloc.add(const HomeStarted(initialMode: HomeMode.planRide));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<HomeState>((s) => s.status == HomeStatus.loading),
          predicate<HomeState>((s) {
            return s.status == HomeStatus.ready &&
                s.mode == HomeMode.planRide &&
                s.waypoints.length == 3 &&
                s.selectedEstimate?.name == 'Crimson Standard' &&
                s.selectedEstimate?.priceCad == 21.40;
          }),
        ]),
      );
    });

    test('HomeModeChanged updates mode and waypoints accurately', () async {
      bloc.add(const HomeStarted(initialMode: HomeMode.whereTo));
      await Future.delayed(const Duration(milliseconds: 20));

      bloc.add(const HomeModeChanged(HomeMode.readyToRide));

      await expectLater(
        bloc.stream,
        emits(predicate<HomeState>((s) {
          return s.mode == HomeMode.readyToRide &&
              s.pickup?.title == 'Downtown (515 5th Ave S)' &&
              s.dropoff?.title == 'Park Place Mall (Main Entrance)';
        })),
      );
    });

    test('HomeStopAdded and HomeStopRemoved manage multi-stop itinerary', () async {
      bloc.add(const HomeStarted(initialMode: HomeMode.planRide));
      await Future.delayed(const Duration(milliseconds: 20));

      expect(bloc.state.waypoints.length, 3);

      // Add a 4th stop
      bloc.add(const HomeStopAdded(Waypoint(
        id: 'stop_custom',
        type: WaypointType.stop,
        title: 'Custom Stop',
        subtitle: 'Lethbridge',
        lat: 49.69,
        lng: -112.84,
      )));

      await expectLater(
        bloc.stream,
        emits(predicate<HomeState>((s) => s.waypoints.length == 4)),
      );

      // Remove the stop
      bloc.add(const HomeStopRemoved('stop_custom'));

      await expectLater(
        bloc.stream,
        emits(predicate<HomeState>((s) => s.waypoints.length == 3)),
      );
    });

    test('HomeCategorySelected toggles selected category', () async {
      bloc.add(const HomeCategorySelected('airport'));

      await expectLater(
        bloc.stream,
        emits(predicate<HomeState>((s) => s.selectedCategory == 'airport')),
      );

      bloc.add(const HomeCategorySelected('airport'));

      await expectLater(
        bloc.stream,
        emits(predicate<HomeState>((s) => s.selectedCategory == null)),
      );
    });

    test('HomeGpsEnableTapped calls openLocationSettings', () async {
      bloc.add(const HomeGpsEnableTapped());
      await Future.delayed(const Duration(milliseconds: 20));

      expect(repository.openedSettings, isTrue);
    });

    test('HomeContinueTapped navigates to /search', () async {
      bloc.add(const HomeStarted(initialMode: HomeMode.readyToRide));
      await Future.delayed(const Duration(milliseconds: 20));

      bloc.add(const HomeContinueTapped());

      await expectLater(
        bloc.stream,
        emits(predicate<HomeState>((s) => s.targetRoute == '/search')),
      );
    });

    test('HomeLogoutTapped calls logout and directs to /phone', () async {
      bloc.add(const HomeLogoutTapped());

      await expectLater(
        bloc.stream,
        emits(predicate<HomeState>((s) => s.targetRoute == '/phone')),
      );

      expect(repository.loggedOut, isTrue);
    });
  });
}
