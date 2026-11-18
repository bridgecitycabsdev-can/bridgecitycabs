import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/home/home.dart';

class MockHomePageRepo implements HomeRepository {
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
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<bool> openLocationSettings() async => true;

  @override
  Future<List<RideTierEstimate>> getEstimates({required List<Waypoint> waypoints}) async {
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
  Future<void> logout() async {}
}

void main() {
  group('HomePage Widget Tests', () {
    testWidgets('renders Screen 1 Where to? initial mode correctly', (tester) async {
      final repository = MockHomePageRepo();
      final bloc = HomeBloc(repository: repository)
        ..add(const HomeStarted(initialMode: HomeMode.whereTo));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<HomeBloc>.value(
            value: bloc,
            child: const HomePage(initialMode: HomeMode.whereTo),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Where to?'), findsWidgets);
      expect(find.text('Your perfect ride is just a tap away.'), findsOneWidget);
      expect(find.text('PICKUP'), findsOneWidget);
      expect(find.text('Current location'), findsOneWidget);
      expect(find.text('Add stop'), findsOneWidget);
      expect(find.text('Schedule'), findsOneWidget);
      expect(find.text('Airport'), findsOneWidget);
      expect(find.text('Long distance'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      bloc.close();
    });

    testWidgets('renders Screen 5 Ready to ride mode correctly', (tester) async {
      final repository = MockHomePageRepo();
      final bloc = HomeBloc(repository: repository)
        ..add(const HomeStarted(initialMode: HomeMode.readyToRide));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<HomeBloc>.value(
            value: bloc,
            child: const HomePage(initialMode: HomeMode.readyToRide),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ready to ride'), findsOneWidget);
      expect(find.text('Trip distance: 3.4 km • ~6 mins'), findsOneWidget);
      expect(find.text('Downtown'), findsOneWidget);
      expect(find.text('Downtown (515 5th Ave S)'), findsOneWidget);
      expect(find.text('Park Place Mall (Main Entrance)'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      bloc.close();
    });

    testWidgets('renders Screen 2 Book a Ride mode with Location Off warning correctly', (tester) async {
      final repository = MockHomePageRepo();
      final bloc = HomeBloc(repository: repository)
        ..add(const HomeStarted(initialMode: HomeMode.bookRide));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<HomeBloc>.value(
            value: bloc,
            child: const HomePage(initialMode: HomeMode.bookRide),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Book a Ride'), findsOneWidget);
      expect(find.text('440 University Dr, Lethbridge'), findsOneWidget);
      expect(find.text('Location is off • Tap to enable in Settings'), findsOneWidget);
      expect(find.text('Enable'), findsOneWidget);
      expect(find.text('Standard Ride'), findsOneWidget);
      expect(find.text('City Red Cruiser'), findsOneWidget);
      expect(find.text('\$14.20'), findsOneWidget);
      expect(find.text('Secure booking • Lethbridge Transit Verified'), findsOneWidget);

      bloc.close();
    });

    testWidgets('renders Screen 3 Plan Ride multi-stop itinerary correctly', (tester) async {
      final repository = MockHomePageRepo();
      final bloc = HomeBloc(repository: repository)
        ..add(const HomeStarted(initialMode: HomeMode.planRide));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<HomeBloc>.value(
            value: bloc,
            child: const HomePage(initialMode: HomeMode.planRide),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Plan Ride'), findsOneWidget);
      expect(find.text('LETHBRIDGE, ALBERTA'), findsOneWidget);
      expect(find.text('Campus Express'), findsOneWidget);
      expect(find.text('Park Place Mall'), findsOneWidget);
      expect(find.text('TRIP ITINERARY'), findsOneWidget);
      expect(find.text('3 Waypoints'), findsOneWidget);
      expect(find.text('Univ of Lethbridge'), findsOneWidget);
      expect(find.text('Safeway West'), findsOneWidget);
      expect(find.text('4th Ave S'), findsOneWidget);
      expect(find.text('Add another stop'), findsOneWidget);
      expect(find.text('Crimson Standard'), findsOneWidget);
      expect(find.text('\$21.40'), findsOneWidget);
      expect(find.text('Continue to Ride Options'), findsOneWidget);

      bloc.close();
    });

    testWidgets('renders Screen 4 Home Drawer with profile and items', (tester) async {
      final repository = MockHomePageRepo();
      final bloc = HomeBloc(repository: repository)
        ..add(const HomeStarted(initialMode: HomeMode.whereTo));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<HomeBloc>.value(
            value: bloc,
            child: const HomePage(initialMode: HomeMode.whereTo),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open drawer using hamburger icon
      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pumpAndSettle();

      expect(find.text('BRIDGE CITY'), findsOneWidget);
      expect(find.text('Sarah Mitchell'), findsOneWidget);
      expect(find.text('4.96 • Lethbridge Rider'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Trips'), findsOneWidget);
      expect(find.text('Soon'), findsOneWidget);
      expect(find.text('Payment Methods'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
      expect(find.text('Safety & Emergency'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);
      expect(find.text('Follow Bridge City Cabs'), findsOneWidget);

      bloc.close();
    });
  });
}
