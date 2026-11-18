import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/reviews/reviews.dart';

void main() {
  group('DriverReviewsPage Widget Tests', () {
    late FakeDriverReviewsRepository repository;

    setUp(() {
      repository = FakeDriverReviewsRepository(latency: Duration.zero);
    });

    Widget createWidget({
      DriverReviewsStatus initialStatus = DriverReviewsStatus.list,
    }) {
      return MaterialApp(
        home: DriverReviewsPage(
          repository: repository,
          initialStatus: initialStatus,
        ),
      );
    }

    testWidgets('Renders Screen 1 (Image 1): Driver Reviews List properly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverReviewsStatus.list));
      await tester.pumpAndSettle();

      // AppBar
      expect(find.text('Driver Reviews List'), findsOneWidget);

      // Hero Rating Summary Card
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('120 reviews'), findsOneWidget);

      // Filter Chips
      expect(find.text('All (120)'), findsOneWidget);
      expect(find.text('5 ★ (98)'), findsOneWidget);
      expect(find.text('4 ★ (14)'), findsOneWidget);
      expect(find.text('3 ★ (5)'), findsOneWidget);

      // Review Items
      expect(find.text('Marcus T.'), findsOneWidget);
      expect(find.text('18 Jul 2026'), findsOneWidget);
      expect(find.textContaining('Fantastic driver! Clean car'), findsOneWidget);

      expect(find.text('Sarah K.'), findsOneWidget);
      expect(find.text('15 Jul 2026'), findsOneWidget);
      expect(find.textContaining('Very polite and smooth ride'), findsOneWidget);

      expect(find.text('David L.'), findsOneWidget);
      expect(find.text('11 Jul 2026'), findsOneWidget);

      expect(find.text('Anonymous Passenger'), findsOneWidget);
      expect(find.text('Low rating'), findsOneWidget);
      expect(find.text('03 Jul 2026'), findsOneWidget);
      expect(find.textContaining('Driver took a slightly longer route'), findsOneWidget);

      // Tip Card
      expect(find.textContaining('Pro Tip: Drivers with clean cars'), findsOneWidget);
    });

    testWidgets('Renders Screen 2 (Image 2): Review Detail & Report Modal properly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverReviewsStatus.detailModal));
      await tester.pumpAndSettle();

      // Top trip specs
      expect(find.text('4.52 km'), findsOneWidget);
      expect(find.text('14 mins'), findsOneWidget);
      expect(find.text('Sedan Medium'), findsOneWidget);

      // Passenger comment
      expect(find.text('PASSENGER COMMENT'), findsOneWidget);
      expect(find.textContaining('Fantastic driver! Clean car'), findsOneWidget);

      // Audit info & regulatory note
      expect(find.text('TRIP ID: BC-123456'), findsOneWidget);
      expect(find.text('REVIEW: REV-88421'), findsOneWidget);
      expect(find.textContaining('Lethbridge Taxi Commission guidelines'), findsOneWidget);

      // Actions
      expect(find.text('Report this review'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('Renders Screen 3 (Image 3): Edge States Gallery properly', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverReviewsStatus.edgeStatesGallery));
      await tester.pumpAndSettle();

      expect(find.text('Driver Reviews States'), findsOneWidget);
      expect(find.textContaining("You're offline. Showing saved reviews"), findsOneWidget);

      // Inspector Header & Chips
      expect(find.text('UI STATE INSPECTOR'), findsOneWidget);
      expect(find.text('Interactive Preview'), findsOneWidget);
      expect(find.text('Showcase All'), findsOneWidget);
      expect(find.text('Filtered Empty (1 ★)'), findsOneWidget);
      expect(find.text('New Driver'), findsOneWidget);
      expect(find.text('Service Failure'), findsOneWidget);
      expect(find.text('Feed Loading'), findsOneWidget);

      // Edge State: No Matching Filter Results
      expect(find.text('State: No Matching Filter Results'), findsOneWidget);
      expect(find.text('1 ★ active'), findsOneWidget);
      expect(find.text('No reviews with this rating'), findsOneWidget);
      expect(find.text('Reset filter'), findsOneWidget);

      // Edge State: First-Time Onboarding Driver
      expect(find.text('State: First-Time Onboarding Driver'), findsOneWidget);
      expect(find.text('New Account'), findsOneWidget);
      expect(find.text('No reviews yet'), findsOneWidget);
      expect(find.textContaining('High Demand: Downtown & West Lethbridge'), findsOneWidget);
      expect(find.text('Go online to get rides'), findsOneWidget);

      // Edge State: Service Failure
      expect(find.text('State: Service Failure / Sync Timeout'), findsOneWidget);
      expect(find.text('504 Gateway'), findsOneWidget);
      expect(find.text("Couldn't load reviews"), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);

      // Edge State: Feed Loading
      expect(find.text('State: Feed & Infinite Scroll Loading'), findsOneWidget);
      expect(find.text('Page 1 of 4'), findsOneWidget);
      expect(find.text('Sarah M.'), findsOneWidget);
      expect(find.text('Liam K.'), findsOneWidget);
      expect(find.text('Loading more reviews...'), findsOneWidget);
      expect(find.text('Skeleton Cache Sync State'), findsOneWidget);
    });

    testWidgets('QA switcher switches states interactively in widget tree', (tester) async {
      await tester.pumpWidget(createWidget(initialStatus: DriverReviewsStatus.list));
      await tester.pumpAndSettle();

      expect(find.text('Driver Reviews List'), findsOneWidget);

      // Switch to Detail Modal via QA chip
      await tester.tap(find.text('2. Review Detail & Report'));
      await tester.pumpAndSettle();
      expect(find.text('Report this review'), findsOneWidget);

      // Switch to Edge States Gallery via QA chip
      await tester.tap(find.text('3. Edge States Gallery'));
      await tester.pumpAndSettle();
      expect(find.text('Driver Reviews States'), findsOneWidget);
      expect(find.text('UI STATE INSPECTOR'), findsOneWidget);

      // Switch to 1★ No Filter Matches
      await tester.tap(find.text('4. 1★ No Filter Matches'));
      await tester.pumpAndSettle();
      expect(find.text('No reviews with this rating'), findsOneWidget);

      // Switch to New Driver
      await tester.tap(find.text('5. New Driver (Zero Reviews)'));
      await tester.pumpAndSettle();
      expect(find.text('No reviews yet'), findsOneWidget);

      // Switch to 504 Failure
      await tester.tap(find.text('6. 504 Gateway Failure'));
      await tester.pumpAndSettle();
      expect(find.text("Couldn't load reviews"), findsOneWidget);
    });
  });
}
