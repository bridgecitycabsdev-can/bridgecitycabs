import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/searching_driver/searching_driver.dart';

void main() {
  group('SearchingDriverPage Widget Tests', () {
    testWidgets('renders Screen 1 Searching State accurately', (tester) async {
      final repo = MockSearchingDriverRepository();
      final bloc = SearchingDriverBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SearchingDriverBloc>.value(
            value: bloc,
            child: const SearchingDriverPage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Bridge City Cabs • YQL'), findsOneWidget);
      expect(find.text('Finding your driver...'), findsOneWidget);
      expect(find.text('This usually takes a minute.'), findsOneWidget);
      expect(find.text('Live Radar Active'), findsOneWidget);
      expect(find.text('Tracking ID • BC-123456'), findsOneWidget);
      expect(find.text('515 5th Ave S, Downtown'), findsOneWidget);
      expect(find.text('Park Place Mall (Main Entrance (North Bay))'),
          findsOneWidget);
      expect(find.text('SUV • Big'), findsOneWidget);
      expect(find.text('\$22.10 CAD'), findsOneWidget);
      expect(find.text('✕ Cancel ride'), findsOneWidget);
      expect(
        find.text('Serving Southern Alberta with licensed local operators'),
        findsOneWidget,
      );

      bloc.close();
      repo.dispose();
    });

    testWidgets('renders Screen 2 Driver Found State accurately', (tester) async {
      final repo = MockSearchingDriverRepository();
      final bloc = SearchingDriverBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SearchingDriverBloc>.value(
            value: bloc,
            child: const SearchingDriverPage(),
          ),
        ),
      );
      await tester.pump();

      bloc.add(const SearchingDriverDriverFoundSimulated());
      await tester.pump();

      expect(find.text('Driver found!'), findsOneWidget);
      expect(find.text('Getting details'), findsOneWidget);
      expect(find.text('... Connecting in 2s'), findsOneWidget);
      expect(find.text('Agreed Fare'), findsOneWidget);
      expect(find.text('\$22.10 CAD'), findsOneWidget);
      expect(
        find.text('Matching dispatch server • Securing vehicle tel...'),
        findsOneWidget,
      );

      bloc.close();
      repo.dispose();
    });

    testWidgets('renders Screen 3 Cancelling Booking State accurately',
        (tester) async {
      final repo = MockSearchingDriverRepository();
      final bloc = SearchingDriverBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SearchingDriverBloc>.value(
            value: bloc,
            child: const SearchingDriverPage(),
          ),
        ),
      );
      await tester.pump();

      bloc.add(const SearchingDriverCancelConfirmed());
      await tester.pump();

      expect(find.text('Cancelling booking...'), findsOneWidget);
      expect(find.text('Stopping search across Lethbridge dispatch.'),
          findsOneWidget);
      expect(find.text('Cancelling ride...'), findsOneWidget);
      expect(
        find.text(
            "You won't be charged. Free cancellation before driver accepts."),
        findsOneWidget,
      );

      bloc.close();
      repo.dispose();
    });

    testWidgets('renders Screen 4 Scheduled Ride State accurately',
        (tester) async {
      final repo = MockSearchingDriverRepository();
      const scheduledBooking = SearchBookingDetails(
        isScheduled: true,
        scheduledDateTime: 'Fri, 3:30 PM',
        scheduledDayText: 'Confirmed for Friday afternoon',
        scheduledDispatchNotice:
            'Driver dispatch begins 15 mins prior (3:15 PM)',
      );
      final bloc = SearchingDriverBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SearchingDriverBloc>.value(
            value: bloc,
            child: const SearchingDriverPage(booking: scheduledBooking),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Ride scheduled'), findsOneWidget);
      expect(find.text('Fri, 3:30 PM'), findsOneWidget);
      expect(find.text("We'll find your driver before pickup."), findsOneWidget);
      expect(find.text('Confirmed for Friday afternoon'), findsOneWidget);
      expect(
        find.text('Driver dispatch begins 15 mins prior (3:15 PM)'),
        findsOneWidget,
      );
      expect(find.text('✕ Cancel scheduled ride'), findsOneWidget);

      bloc.close();
      repo.dispose();
    });

    testWidgets('renders Screen 5 Reconnecting State accurately', (tester) async {
      final repo = MockSearchingDriverRepository();
      final bloc = SearchingDriverBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SearchingDriverBloc>.value(
            value: bloc,
            child: const SearchingDriverPage(),
          ),
        ),
      );
      await tester.pump();

      bloc.add(const SearchingDriverConnectionChanged(
        isOnline: false,
        signalStrength: 1,
      ));
      await tester.pump();

      expect(find.text('Reconnecting... Checking network'), findsOneWidget);
      expect(
        find.text(
            'Lethbridge dispatch queue active. Your search request is safely held on our servers.'),
        findsOneWidget,
      );
      expect(find.text('Signal 1/4'), findsOneWidget);
      expect(find.text('Syncing connection with Lethbridge ...'), findsOneWidget);
      expect(find.text('• Re-establishing secure telemetry...'), findsOneWidget);
      expect(find.text('Bridge City Cabs'), findsOneWidget);
      expect(find.text('Fixed rate locked'), findsOneWidget);
      expect(
        find.text('Need help? Call dispatch 403-328-8888'),
        findsOneWidget,
      );

      bloc.close();
      repo.dispose();
    });
  });
}
