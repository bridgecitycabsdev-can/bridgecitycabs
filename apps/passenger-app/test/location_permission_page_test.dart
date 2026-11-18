import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:passenger_app/features/location_permission/location_permission.dart';

class MockTestLocationRepo implements LocationPermissionRepository {
  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.denied;

  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.whileInUse;

  @override
  Future<Position?> getCurrentPosition() async => null;

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;
}

void main() {
  group('LocationPermissionPage Widget Tests', () {
    testWidgets('renders Screen 2 Prompt state elements accurately',
        (tester) async {
      final repository = MockTestLocationRepo();
      final bloc = LocationPermissionBloc(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<LocationPermissionBloc>.value(
            value: bloc,
            child: const LocationPermissionPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top Bar & Badges
      expect(find.text('Location Permission'), findsOneWidget);
      expect(find.text('Lethbridge Service Area'), findsOneWidget);
      expect(find.text('Skip for now'), findsOneWidget);

      // Map card overlays
      expect(find.text('Accurate to 5m'), findsOneWidget);
      expect(find.text('Downtown / Scenic Dr'), findsOneWidget);
      expect(find.text('3 mins average pickup'), findsOneWidget);

      // Prompt Content & Value Props
      expect(find.text('Find your pickup spot'), findsOneWidget);
      expect(find.text('Used only while actively using the app'), findsOneWidget);
      expect(find.text('1-Tap Booking'), findsOneWidget);
      expect(find.text('No street typing required'), findsOneWidget);
      expect(find.text('Driver Meetup'), findsOneWidget);
      expect(find.text('Guides driver straight to curb'), findsOneWidget);

      // Action Buttons
      expect(find.text('Allow location'), findsOneWidget);
      expect(find.text('Enter pickup manually'), findsOneWidget);

      bloc.close();
    });

    testWidgets('renders Screen 1 Unavailable state elements accurately',
        (tester) async {
      final repository = MockTestLocationRepo();
      final bloc = LocationPermissionBloc(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<LocationPermissionBloc>.value(
            value: bloc,
            child: const LocationPermissionPage(),
          ),
        ),
      );

      bloc.emit(const LocationPermissionUnavailableState());
      await tester.pumpAndSettle();

      // Top Bar & Fleet Status
      expect(find.text('Location Permission'), findsOneWidget);
      expect(find.text('Bridge City Fleet • Lethbridge'), findsOneWidget);
      expect(find.text('GPS Inactive'), findsOneWidget);

      // Map overlay
      expect(find.text('Awaiting coordinates • Coulee Corridor'), findsOneWidget);

      // Permission Unavailable Warning & Content
      expect(find.text('PERMISSION UNAVAILABLE'), findsOneWidget);
      expect(
        find.text('Location is off. You can still type your pickup address.'),
        findsOneWidget,
      );
      expect(find.text('Common hubs nearby'), findsOneWidget);

      // Hub options
      expect(find.text('Park Place'), findsOneWidget);
      expect(find.text('Downtown Hub'), findsOneWidget);
      expect(find.text('Westside / ULeth'), findsOneWidget);

      // Action Buttons & Footnote
      expect(find.text('Search address'), findsOneWidget);
      expect(find.text('Open settings'), findsOneWidget);
      expect(
        find.text(
          'You can change permission settings anytime in your device Settings.',
        ),
        findsOneWidget,
      );

      bloc.close();
    });
  });
}
