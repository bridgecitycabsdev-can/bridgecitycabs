import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/no_driver/no_driver.dart';

void main() {
  group('NoDriverPage Widget Tests', () {
    testWidgets('renders Screen 1 Idle State accurately', (tester) async {
      final repo = MockNoDriverRepository();
      final bloc = NoDriverBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<NoDriverBloc>.value(
            value: bloc,
            child: const NoDriverPage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Bridge City Cabs • Lethbridge Dispatch'),
          findsOneWidget);
      expect(find.text('No drivers nearby right now'), findsOneWidget);
      expect(
        find.text(
            'All our drivers are busy. You can try again or cancel this ride.'),
        findsOneWidget,
      );
      expect(find.text('Tracking ID • BC-123456'), findsOneWidget);
      expect(find.text('515 5th Ave S, Downtown'), findsOneWidget);
      expect(find.text('Park Place Mall'), findsOneWidget);
      expect(find.text('SUV • Big'), findsOneWidget);
      expect(find.text('\$22.10 CAD'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Cancel ride'), findsOneWidget);
      expect(
        find.text('Need urgent travel? Call dispatch 403-328-8888'),
        findsOneWidget,
      );

      bloc.close();
    });

    testWidgets('renders Screen 2 Still No Driver Error Alert State accurately',
        (tester) async {
      final repo = MockNoDriverRepository(
        retryDelay: const Duration(milliseconds: 1),
      );
      final bloc = NoDriverBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<NoDriverBloc>.value(
            value: bloc,
            child: const NoDriverPage(),
          ),
        ),
      );
      await tester.pump();

      bloc.add(const NoDriverRetryTapped());
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('No drivers nearby right now'), findsOneWidget);
      expect(
        find.text('Still no drivers available. Please try again shortly.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Call Dispatch (403-328-8888)'), findsOneWidget);

      bloc.close();
    });

    testWidgets('renders Screen 3 Searching in Progress State accurately',
        (tester) async {
      final repo = MockNoDriverRepository(
        retryDelay: const Duration(seconds: 10),
      );
      final bloc = NoDriverBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<NoDriverBloc>.value(
            value: bloc,
            child: const NoDriverPage(),
          ),
        ),
      );
      await tester.pump();

      bloc.add(const NoDriverRetryTapped());
      await tester.pump();

      expect(find.text('Auto-reconnecting'), findsOneWidget);
      expect(find.text('Searching...'), findsOneWidget);
      expect(
        find.text('Searching available fleet in Lethbridge corridor...'),
        findsOneWidget,
      );

      bloc.close();
    });

    testWidgets('renders Screen 4 Cancelling Request State accurately',
        (tester) async {
      final repo = MockNoDriverRepository(
        cancelDelay: const Duration(seconds: 10),
      );
      final bloc = NoDriverBloc(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<NoDriverBloc>.value(
            value: bloc,
            child: const NoDriverPage(),
          ),
        ),
      );
      await tester.pump();

      bloc.add(const NoDriverCancelConfirmed());
      await tester.pump();

      expect(find.text('Cancelling ride request...'), findsOneWidget);
      expect(
        find.text('Releasing your dispatch booking and stopping driver search.'),
        findsOneWidget,
      );
      expect(find.text('No cancellation fee applies'), findsOneWidget);
      expect(
        find.text('Your payment method was not charged for this request.'),
        findsOneWidget,
      );
      expect(find.text('Cancelling ride...'), findsOneWidget);
      expect(
        find.text('Returning to home screen shortly...'),
        findsOneWidget,
      );

      bloc.close();
    });
  });
}
