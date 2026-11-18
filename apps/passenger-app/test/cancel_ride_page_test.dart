import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/cancel_ride/cancel_ride.dart';

void main() {
  group('CancelRidePage Widget Tests', () {
    testWidgets('renders Screen 3 Confirm Cancel Modal accurately',
        (tester) async {
      final repo = MockCancelRideRepository();
      final bloc = CancelRideBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CancelRideBloc>.value(
            value: bloc,
            child: const CancelRidePage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Cancel this ride?'), findsOneWidget);
      expect(
        find.text(
            'Your driver is on the way. If you cancel now, you can book again at any time.'),
        findsOneWidget,
      );
      expect(
        find.text(
            "If your trip was paid by card, you'll only be charged after the booking is created. Pre-authorizations release automatically."),
        findsOneWidget,
      );
      expect(find.text('Keep ride'), findsOneWidget);
      expect(find.text('Yes, cancel ride'), findsOneWidget);

      bloc.close();
    });

    testWidgets('renders Screen 2 Cancelling In Progress State accurately',
        (tester) async {
      final repo = MockCancelRideRepository(
        delay: const Duration(seconds: 10),
      );
      final bloc = CancelRideBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CancelRideBloc>.value(
            value: bloc,
            child: const CancelRidePage(),
          ),
        ),
      );
      await tester.pump();

      bloc.add(const CancelRideConfirmed());
      await tester.pump();

      expect(find.text('Cancel this ride?'), findsOneWidget);
      expect(find.text('Reason for cancelling'), findsOneWidget);
      expect(find.text('Changed my plans'), findsOneWidget);
      expect(find.text('Cancelling ride...'), findsOneWidget);
      expect(
        find.text('Processing cancellation with Lethbridge dispatch...'),
        findsOneWidget,
      );
      expect(find.text('BRIDGE CITY CABS • LETHBRIDGE, AB'), findsOneWidget);

      bloc.close();
    });

    testWidgets('renders Screen 1 Cancelled Success Toast accurately',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CancelSuccessBanner(
              onDismiss: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Ride cancelled'), findsOneWidget);
      expect(find.text('\$0.00 CAD'), findsOneWidget);
      expect(
        find.text('You were not charged for this trip. Zero penalty applied.'),
        findsOneWidget,
      );
    });

    testWidgets('renders Screen 4 Cannot Cancel State accurately',
        (tester) async {
      final repo = MockCancelRideRepository(isTripOngoing: true);
      final bloc = CancelRideBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CancelRideBloc>.value(
            value: bloc,
            child: const CancelRidePage(isTripStarted: true),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Cannot cancel ride'), findsOneWidget);
      expect(find.text('Your ride is currently in progress.'), findsOneWidget);
      expect(
        find.text("This trip has already started and can't be cancelled."),
        findsOneWidget,
      );
      expect(
        find.text(
            'Please speak with your driver Michael or contact dispatch if you need an emergency stop.'),
        findsOneWidget,
      );
      expect(find.text('Michael K.'), findsOneWidget);
      expect(find.text('Bridge City Cab #42 • Toyota Camry'), findsOneWidget);
      expect(find.text('Back to trip'), findsOneWidget);
      expect(
        find.text(
            'In an emergency, dial 911 or call Bridge City Dispatch (403-328-8888).'),
        findsOneWidget,
      );

      bloc.close();
    });
  });
}
