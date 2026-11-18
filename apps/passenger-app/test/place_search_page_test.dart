import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/place_search/place_search.dart';

class MockTestPlaceSearchPageRepo implements PlaceSearchRepository {
  @override
  Future<List<LethbridgePlace>> searchPlaces(String query) async {
    return LethbridgePlace.parkPlaceResults;
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
  group('PlaceSearchPage Widget Tests', () {
    testWidgets('renders Screen 1 Suggestions Loaded state accurately', (tester) async {
      final repo = MockTestPlaceSearchPageRepo();
      final bloc = PlaceSearchBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PlaceSearchBloc>.value(
            value: bloc,
            child: const PlaceSearchPage(),
          ),
        ),
      );

      bloc.emit(const PlaceSearchState(
        status: PlaceSearchStatus.success,
        query: 'Park Place',
        suggestions: LethbridgePlace.parkPlaceResults,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Set Location'), findsOneWidget);
      expect(find.text('PICKUP'), findsOneWidget);
      expect(find.text('SUGGESTIONS'), findsOneWidget);
      expect(find.text('4 places'), findsOneWidget);
      expect(find.text('Park Place Mall'), findsOneWidget);
      expect(find.text('Park Place Dental Centre'), findsOneWidget);
      expect(find.text('Park Place Cineplex'), findsOneWidget);
      expect(find.text('Park Meadows Medical Clinic'), findsOneWidget);
      expect(find.text('1.8 km'), findsWidgets);
      expect(find.text('~4 min'), findsWidgets);

      bloc.close();
    });

    testWidgets('renders Screen 2 Initial Empty Prompt state accurately', (tester) async {
      final repo = MockTestPlaceSearchPageRepo();
      final bloc = PlaceSearchBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PlaceSearchBloc>.value(
            value: bloc,
            child: const PlaceSearchPage(),
          ),
        ),
      );

      bloc.emit(const PlaceSearchState(
        status: PlaceSearchStatus.initial,
        query: '',
        suggestions: [],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Set Location'), findsOneWidget);
      expect(find.text('Search address or place'), findsOneWidget);
      expect(
        find.text(
          'Type an address, business, or Lethbridge landmark to find your ride.',
        ),
        findsOneWidget,
      );
      expect(find.text('University of Lethbridge'), findsOneWidget);
      expect(find.text('Park Place Mall'), findsOneWidget);
      expect(find.text('Enmax Centre'), findsOneWidget);

      bloc.close();
    });

    testWidgets('renders Screen 3 Searching state with shimmers accurately', (tester) async {
      final repo = MockTestPlaceSearchPageRepo();
      final bloc = PlaceSearchBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PlaceSearchBloc>.value(
            value: bloc,
            child: const PlaceSearchPage(),
          ),
        ),
      );

      bloc.emit(const PlaceSearchState(
        status: PlaceSearchStatus.searching,
        query: 'University of L',
      ));
      await tester.pump();

      expect(find.text('• Searching Lethbridge...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      bloc.close();
    });

    testWidgets('renders Screen 4 No Places Found zero results state accurately', (tester) async {
      final repo = MockTestPlaceSearchPageRepo();
      final bloc = PlaceSearchBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PlaceSearchBloc>.value(
            value: bloc,
            child: const PlaceSearchPage(),
          ),
        ),
      );

      bloc.emit(const PlaceSearchState(
        status: PlaceSearchStatus.empty,
        query: 'Xyz99 Lethbridge Road',
        suggestions: [],
      ));
      await tester.pumpAndSettle();

      expect(find.text('0 results'), findsOneWidget);
      expect(find.text('No places found'), findsOneWidget);
      expect(
        find.text(
          'Try a different address, check spelling, or search for a nearby landmark in Lethbridge.',
        ),
        findsOneWidget,
      );
      expect(find.text('Set pin on map instead'), findsOneWidget);

      bloc.close();
    });

    testWidgets('renders Screen 5 Offline Connection Error state accurately', (tester) async {
      final repo = MockTestPlaceSearchPageRepo();
      final bloc = PlaceSearchBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PlaceSearchBloc>.value(
            value: bloc,
            child: const PlaceSearchPage(),
          ),
        ),
      );

      bloc.emit(const PlaceSearchState(
        status: PlaceSearchStatus.failure,
        query: 'Enmax Centre Lethbridge',
        isOffline: true,
        suggestions: [],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Offline mode'), findsOneWidget);
      expect(find.text('Unable to connect to place search'), findsOneWidget);
      expect(
        find.text(
          'Please check your mobile data or Wi-Fi connection in Lethbridge and try again.',
        ),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Choose on map instead'), findsOneWidget);
      expect(
        find.text(
          'Need a cab right away? Dispatch is available at 403-328-8888',
        ),
        findsOneWidget,
      );

      bloc.close();
    });
  });
}
