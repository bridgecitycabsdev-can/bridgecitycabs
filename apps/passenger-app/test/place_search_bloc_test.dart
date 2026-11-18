import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/place_search/place_search.dart';

class MockTestPlaceSearchRepository implements PlaceSearchRepository {
  bool simulateOffline = false;

  @override
  Future<List<LethbridgePlace>> searchPlaces(String query) async {
    if (simulateOffline) {
      throw TimeoutException('Simulated offline failure');
    }

    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return const [];

    if (trimmed.contains('xyz99') || trimmed.contains('nonexistent')) {
      return const [];
    }

    if (trimmed.contains('park')) {
      return LethbridgePlace.parkPlaceResults;
    }

    return LethbridgePlace.popularLandmarks;
  }

  @override
  Future<List<LethbridgePlace>> getRecentPlaces() async {
    return LethbridgePlace.parkPlaceResults.take(2).toList();
  }

  @override
  Future<List<LethbridgePlace>> getPopularLandmarks() async {
    return LethbridgePlace.popularLandmarks;
  }
}

void main() {
  group('PlaceSearchBloc Tests', () {
    late MockTestPlaceSearchRepository repository;
    late PlaceSearchBloc bloc;

    setUp(() {
      repository = MockTestPlaceSearchRepository();
      bloc = PlaceSearchBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is PlaceSearchStatus.initial with empty query', () {
      expect(bloc.state.status, PlaceSearchStatus.initial);
      expect(bloc.state.query, isEmpty);
      expect(bloc.state.suggestions, isEmpty);
      expect(bloc.state.isOffline, isFalse);
    });

    test('PlaceSearchStarted without query keeps status initial', () async {
      bloc.add(const PlaceSearchStarted(
        initialPickup: '515 5th Ave S, Downtown',
      ));

      await expectLater(
        bloc.stream,
        emits(predicate<PlaceSearchState>((s) {
          return s.status == PlaceSearchStatus.initial &&
              s.pickup == '515 5th Ave S, Downtown' &&
              s.query.isEmpty;
        })),
      );
    });

    test('PlaceSearchQueryChanged with "Park Place" emits searching then success with 4 results', () async {
      bloc.add(const PlaceSearchQueryChanged('Park Place'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<PlaceSearchState>((s) => s.status == PlaceSearchStatus.searching),
          predicate<PlaceSearchState>((s) {
            return s.status == PlaceSearchStatus.success &&
                s.suggestions.length == 4 &&
                s.suggestions.first.title == 'Park Place Mall' &&
                s.isOffline == false;
          }),
        ]),
      );
    });

    test('PlaceSearchQueryChanged with "Xyz99" emits searching then empty (0 results)', () async {
      bloc.add(const PlaceSearchQueryChanged('Xyz99 Lethbridge Road'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<PlaceSearchState>((s) => s.status == PlaceSearchStatus.searching),
          predicate<PlaceSearchState>((s) {
            return s.status == PlaceSearchStatus.empty &&
                s.suggestions.isEmpty &&
                s.isOffline == false;
          }),
        ]),
      );
    });

    test('PlaceSearchQueryChanged when offline emits searching then failure', () async {
      repository.simulateOffline = true;
      bloc.add(const PlaceSearchQueryChanged('Enmax Centre'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<PlaceSearchState>((s) => s.status == PlaceSearchStatus.searching),
          predicate<PlaceSearchState>((s) {
            return s.status == PlaceSearchStatus.failure &&
                s.suggestions.isEmpty &&
                s.isOffline == true;
          }),
        ]),
      );
    });

    test('PlaceSearchCleared resets state to initial and clears query', () async {
      bloc.add(const PlaceSearchQueryChanged('Park'));
      await Future.delayed(const Duration(milliseconds: 20));

      bloc.add(const PlaceSearchCleared());

      await expectLater(
        bloc.stream,
        emits(predicate<PlaceSearchState>((s) {
          return s.status == PlaceSearchStatus.initial &&
              s.query.isEmpty &&
              s.suggestions.isEmpty;
        })),
      );
    });

    test('PlaceSearchRetryTapped re-executes search when connection restores', () async {
      repository.simulateOffline = true;
      bloc.add(const PlaceSearchQueryChanged('Park'));
      await Future.delayed(const Duration(milliseconds: 20));

      expect(bloc.state.status, PlaceSearchStatus.failure);

      repository.simulateOffline = false;
      bloc.add(const PlaceSearchRetryTapped());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<PlaceSearchState>((s) => s.status == PlaceSearchStatus.searching && !s.isOffline),
          predicate<PlaceSearchState>((s) => s.status == PlaceSearchStatus.success && s.suggestions.isNotEmpty),
        ]),
      );
    });

    test('PlaceSearchPlaceSelected sets selectedPlace and targetRoute to /home', () async {
      final place = LethbridgePlace.parkPlaceResults.first;
      bloc.add(PlaceSearchPlaceSelected(place));

      await expectLater(
        bloc.stream,
        emits(predicate<PlaceSearchState>((s) {
          return s.selectedPlace == place &&
              s.targetRoute == '/home' &&
              s.query == 'Park Place Mall';
        })),
      );
    });

    test('PlaceSearchSwapLocationsTapped swaps pickup and destination', () async {
      bloc.add(const PlaceSearchStarted(
        initialPickup: '515 5th Ave S, Downtown',
        initialQuery: 'Park Place',
      ));
      await Future.delayed(const Duration(milliseconds: 20));

      bloc.add(const PlaceSearchSwapLocationsTapped());

      await expectLater(
        bloc.stream,
        emits(predicate<PlaceSearchState>((s) {
          return s.pickup == 'Park Place' &&
              s.query == '515 5th Ave S, Downtown';
        })),
      );
    });

    test('PlaceSearchPinOnMapTapped navigates to /home', () async {
      bloc.add(const PlaceSearchPinOnMapTapped());

      await expectLater(
        bloc.stream,
        emits(predicate<PlaceSearchState>((s) => s.targetRoute == '/home')),
      );
    });

    test('PlaceSearchCloseTapped navigates back to /home', () async {
      bloc.add(const PlaceSearchCloseTapped());

      await expectLater(
        bloc.stream,
        emits(predicate<PlaceSearchState>((s) => s.targetRoute == '/home')),
      );
    });
  });
}
