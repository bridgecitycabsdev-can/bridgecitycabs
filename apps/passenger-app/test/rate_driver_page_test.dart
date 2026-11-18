import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/rate_driver/rate_driver.dart';

void main() {
  group('RateDriverPage Widget Tests', () {
    testWidgets('renders Screen 1 Low Rating (2 Stars - FAIR) State accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RateDriverPage(
            initialStars: 2,
            initialStatus: RateDriverStatus.lowRating,
            initialComment:
                'Driver arrived 10 minutes past the estimated arrival time and took Mayor Magrath instead of Scenic Dr.',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rate Your Trip'), findsOneWidget);
      expect(find.text('How was your ride with Michael?'), findsOneWidget);
      expect(find.text('FAIR'), findsOneWidget);
      expect(find.text('What went wrong?'), findsOneWidget);
      expect(find.text('Select all that apply'), findsOneWidget);
      expect(find.text('Unsafe driving'), findsOneWidget);
      expect(find.text('Late pickup'), findsOneWidget);
      expect(find.text('Bridge City Guarantee'), findsOneWidget);
      expect(
        find.text('Trip fare under automatic review for route discrepancies.'),
        findsOneWidget,
      );
      expect(find.text('Shared anonymously'), findsOneWidget);
      expect(find.text('Submit Review'), findsOneWidget);
    });

    testWidgets('renders Screen 2 High Rating (5 Stars - Excellent) State accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RateDriverPage(
            initialStars: 5,
            initialStatus: RateDriverStatus.highRating,
            initialComment:
                'Michael was fantastic! Took the coulee route smoothly and had great AC on a hot Lethbridge afternoon.',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('How was your ride with Michael?'), findsOneWidget);
      expect(find.text('🔥 Excellent!'), findsOneWidget);
      expect(find.text('WHAT WENT WELL?'), findsOneWidget);
      expect(find.text('Great driving'), findsOneWidget);
      expect(find.text('Clean car'), findsOneWidget);
      expect(find.text('Friendly'), findsOneWidget);
      expect(find.text('Silver Toyota RAV4'), findsOneWidget);
      expect(find.text(r'$16.40 CAD'), findsOneWidget);
      expect(find.text('Submit Review'), findsOneWidget);
    });

    testWidgets('renders Screen 3 Initial / Unrated (0 Stars) State accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RateDriverPage(
            initialStars: 0,
            initialStatus: RateDriverStatus.initial,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rate Your Trip'), findsOneWidget);
      expect(find.text('How was your ride with Michael?'), findsOneWidget);
      expect(find.text('Tap a star to rate'), findsOneWidget);
      expect(find.text('Leave a note'), findsOneWidget);
      expect(find.text('Trip ID: #BC-84920 • Lethbridge Transit Zone'), findsOneWidget);

      // Submit Review button is disabled when unrated
      final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Submit Review'));
      expect(button.onPressed, isNull);
    });

    testWidgets('renders Screen 4 Rating Success State accurately',
        (tester) async {
      const positiveTag = RatingTag(id: 'great_driving', label: 'Great driving');

      await tester.pumpWidget(
        const MaterialApp(
          home: RateDriverPage(
            initialStatus: RateDriverStatus.success,
            initialStars: 5,
            initialTags: [positiveTag],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RatingSuccessView), findsOneWidget);
      expect(find.text('Thanks for your feedback!'), findsOneWidget);
      expect(find.text('Michael K.'), findsOneWidget);
      expect(find.text('BCC • Vehicle #892'), findsOneWidget);
      expect(find.text('5.0'), findsOneWidget);
      expect(find.text('High Five for Southern Alberta!'), findsOneWidget);
      expect(
        find.text("Tip & feedback forwarded to Michael's driver dashboard."),
        findsOneWidget,
      );
      expect(
        find.text('Ratings cannot be edited after submitting.'),
        findsOneWidget,
      );
      expect(find.text('Back to home'), findsOneWidget);
    });

    testWidgets('renders Screen 5 Submitting / Syncing State accurately',
        (tester) async {
      final repo = MockRateDriverRepository(
        delay: const Duration(seconds: 10),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RateDriverPage(
            initialStars: 5,
            initialStatus: RateDriverStatus.submitting,
            repository: repo,
            initialComment: 'Thanks Michael!',
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(RatingSyncBanner), findsOneWidget);
      expect(find.text('Connecting to Bridge City dispatch'), findsOneWidget);
      expect(
        find.text('Syncing driver commendations and ride history'),
        findsOneWidget,
      );
      expect(find.text('Sending securely'), findsOneWidget);
    });

    testWidgets('renders Screen 6 Already Rated State accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RateDriverPage(
            initialStatus: RateDriverStatus.alreadyRated,
            initialStars: 5,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RatingAlreadyRatedView), findsOneWidget);
      expect(find.text("You've already rated this trip."), findsOneWidget);
      expect(
        find.text(
          'Each ride can only be rated once to preserve driver evaluation integrity.',
        ),
        findsOneWidget,
      );
      expect(find.text('Submitted Record'), findsOneWidget);
      expect(find.text('Trip Rating Submitted'), findsOneWidget);
      expect(find.text('5.0 Star Experience'), findsOneWidget);
      expect(find.text('TAGS INCLUDED'), findsOneWidget);
      expect(find.text('Great Conversation'), findsOneWidget);
      expect(find.text('Back to receipt'), findsOneWidget);
    });

    testWidgets('renders Screen 7 Rating Window Expired State accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RateDriverPage(
            initialStatus: RateDriverStatus.windowExpired,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RatingExpiredView), findsOneWidget);
      expect(
        find.text('The rating window for this trip has closed.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Ratings must be submitted within 48 hours of trip completion.',
        ),
        findsOneWidget,
      );
      expect(find.text('Rating Window Expired'), findsOneWidget);
      expect(
        find.text('Feedback is no longer accepted for this past booking.'),
        findsOneWidget,
      );
      expect(
        find.text('Need to report an issue with this trip?'),
        findsOneWidget,
      );
      expect(find.text('Trip Fare & Route'), findsOneWidget);
      expect(find.text(r'$18.40 CAD'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });
  });
}
