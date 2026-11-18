import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/live_tracking/live_tracking.dart';

void main() {
  group('LiveTrackingPage Widget Tests', () {
    testWidgets('renders Screen 1 Driver Assigned State accurately', (tester) async {
      final repo = MockLiveTrackingRepository();
      final bloc = LiveTrackingBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<LiveTrackingBloc>.value(
            value: bloc,
            child: const LiveTrackingPage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Driver assigned'), findsOneWidget);
      expect(find.text('Michael is assigned to your ride'), findsOneWidget);
      expect(find.text('Heading to pickup point shortly'), findsOneWidget);
      expect(find.text('3 MIN'), findsOneWidget);
      expect(find.text('Michael'), findsOneWidget);
      expect(find.text('White Toyota Corolla'), findsOneWidget);
      expect(find.text('BCC • 892'), findsOneWidget);
      expect(find.text('GPS Synchronized'), findsOneWidget);
      expect(find.text('GUARANTEED'), findsOneWidget);
      expect(find.text('\$22.10 CAD'), findsOneWidget);
      expect(find.text('✕ Cancel ride'), findsOneWidget);

      bloc.close();
      repo.dispose();
    });

    testWidgets('renders Screen 2 Driver Arrived State accurately', (tester) async {
      final repo = MockLiveTrackingRepository();
      final bloc = LiveTrackingBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<LiveTrackingBloc>.value(
            value: bloc,
            child: const LiveTrackingPage(
              initialStatus: LiveTrackingStatus.driverArrived,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Driver has arrived'), findsOneWidget);
      expect(find.text('Your driver is waiting at the pickup'), findsOneWidget);
      expect(find.text('Parking hazard lights blinking near entrance'), findsOneWidget);
      expect(find.text('Michael has arrived'), findsOneWidget);
      expect(find.text('Look for White Toyota Corolla (BCC • 892)'), findsOneWidget);
      expect(find.text('✕ Cancel ride'), findsOneWidget);

      bloc.close();
      repo.dispose();
    });

    testWidgets('renders Screen 3 Driver Arriving State accurately', (tester) async {
      final repo = MockLiveTrackingRepository();
      final bloc = LiveTrackingBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<LiveTrackingBloc>.value(
            value: bloc,
            child: const LiveTrackingPage(
              initialStatus: LiveTrackingStatus.driverArriving,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Driver arriving • 3 min'), findsOneWidget);
      expect(find.text('Your driver is arriving in 3 min'), findsOneWidget);
      expect(find.text('Please make your way to the pickup spot'), findsOneWidget);
      expect(find.text('✕ Cancel ride'), findsOneWidget);

      bloc.close();
      repo.dispose();
    });

    testWidgets('renders Screen 4 SOS Alert Triggered State accurately', (tester) async {
      final repo = MockLiveTrackingRepository();
      final bloc = LiveTrackingBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<LiveTrackingBloc>.value(
            value: bloc,
            child: const LiveTrackingPage(
              initialStatus: LiveTrackingStatus.sosTriggered,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Alert sent. Our team has been notified.'), findsOneWidget);
      expect(find.text('Emergency dispatch and support are actively monitoring this trip.'), findsOneWidget);
      expect(find.text('SOS Emergency Alert Triggered'), findsOneWidget);
      expect(find.text('Live GPS & audio telemetry shared with Lethbridge dispatch.'), findsOneWidget);
      expect(find.text('PRIORITY PROTOCOL'), findsOneWidget);
      expect(find.text('Safety team contacting local authorities and emergency contacts.'), findsOneWidget);
      expect(find.text('Cancel SOS alert'), findsOneWidget);
      expect(find.text('In an emergency, also call 911.'), findsOneWidget);

      bloc.close();
      repo.dispose();
    });

    testWidgets('renders Screen 5 Trip in Progress State accurately', (tester) async {
      final repo = MockLiveTrackingRepository();
      const trip = TrackingTripDetails(
        tripProgress: 0.45,
        etaMinutes: 8,
        estimatedArrivalTime: '3:38 PM',
      );
      final bloc = LiveTrackingBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<LiveTrackingBloc>.value(
            value: bloc,
            child: const LiveTrackingPage(
              trip: trip,
              initialStatus: LiveTrackingStatus.tripInProgress,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Trip in progress'), findsOneWidget);
      expect(find.text('On the way to Park Place Mall'), findsOneWidget);
      expect(find.text('Estimated arrival in 8 min (3:38 PM)'), findsOneWidget);
      expect(find.text('45% completed'), findsOneWidget);
      expect(find.text('SOS Emergency'), findsOneWidget);
      expect(find.text('In an emergency, also call 911.'), findsOneWidget);

      bloc.close();
      repo.dispose();
    });

    testWidgets('renders Screen 6 Telemetry Syncing State accurately', (tester) async {
      final repo = MockLiveTrackingRepository();
      const trip = TrackingTripDetails(
        etaMinutes: 8,
      );
      final bloc = LiveTrackingBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<LiveTrackingBloc>.value(
            value: bloc,
            child: const LiveTrackingPage(
              trip: trip,
              initialStatus: LiveTrackingStatus.telemetrySyncing,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Updating driver location...'), findsOneWidget);
      expect(find.text('GPS telemetry reconnecting. Trip is ongoing.'), findsOneWidget);
      expect(find.text('Real-time position syncing...'), findsOneWidget);
      expect(find.text('~8 min'), findsOneWidget);

      bloc.close();
      repo.dispose();
    });
  });
}
