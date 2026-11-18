import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/rate_driver/rate_driver.dart';

void main() {
  group('RateDriverBloc Tests', () {
    late MockRateDriverRepository repository;
    late RateDriverBloc bloc;

    setUp(() {
      repository = MockRateDriverRepository(
        delay: const Duration(milliseconds: 10),
      );
      bloc = RateDriverBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state defaults to initial unrated state', () {
      expect(bloc.state.status, RateDriverStatus.initial);
      expect(bloc.state.isUnrated, isTrue);
      expect(bloc.state.selectedStars, 0);
      expect(bloc.state.sentimentLabel, 'Tap a star to rate');
      expect(bloc.state.canSubmit, isFalse);
      expect(bloc.state.driver.name, 'Michael K.');
      expect(bloc.state.driver.rating, 4.8);
      expect(bloc.state.trip.tripId, 'BC-84920');
    });

    test('selecting 1 or 2 stars transitions to lowRating with negative tags', () async {
      bloc.add(const RateDriverStarted());
      await pumpEventQueue();

      bloc.add(const RateDriverStarsSelected(2));

      await expectLater(
        bloc.stream,
        emits(predicate<RateDriverState>((s) {
          return s.status == RateDriverStatus.lowRating &&
              s.isLowRating &&
              s.selectedStars == 2 &&
              s.sentimentLabel == 'FAIR' &&
              s.tagsSectionTitle == 'What went wrong?' &&
              s.canSubmit == true;
        })),
      );
    });

    test('selecting 4 or 5 stars transitions to highRating with positive tags', () async {
      bloc.add(const RateDriverStarted());
      await pumpEventQueue();

      bloc.add(const RateDriverStarsSelected(5));

      await expectLater(
        bloc.stream,
        emits(predicate<RateDriverState>((s) {
          return s.status == RateDriverStatus.highRating &&
              s.isHighRating &&
              s.selectedStars == 5 &&
              s.sentimentLabel == '🔥 Excellent!' &&
              s.tagsSectionTitle == 'WHAT WENT WELL?' &&
              s.canSubmit == true;
        })),
      );
    });

    test('toggling tags correctly adds and removes tags', () async {
      bloc.add(const RateDriverStarted());
      await pumpEventQueue();

      bloc.add(const RateDriverStarsSelected(2));
      await pumpEventQueue();

      const lateTag = RatingTag(id: 'late', label: 'Late pickup', isNegative: true);

      bloc.add(const RateDriverTagToggled(lateTag));
      await expectLater(
        bloc.stream,
        emits(predicate<RateDriverState>((s) {
          return s.selectedTags.contains(lateTag);
        })),
      );

      // Untoggle
      bloc.add(const RateDriverTagToggled(lateTag));
      await expectLater(
        bloc.stream,
        emits(predicate<RateDriverState>((s) {
          return !s.selectedTags.contains(lateTag);
        })),
      );
    });

    test('comment changed updates comment', () async {
      bloc.add(const RateDriverStarted());
      await pumpEventQueue();

      bloc.add(const RateDriverCommentChanged('Driver arrived right on time and car was spotless.'));

      await expectLater(
        bloc.stream,
        emits(predicate<RateDriverState>((s) {
          return s.comment == 'Driver arrived right on time and car was spotless.';
        })),
      );
    });

    test('submitting review transitions through submitting to success', () async {
      bloc.add(const RateDriverStarted());
      await pumpEventQueue();

      bloc.add(const RateDriverStarsSelected(5));
      await pumpEventQueue();

      bloc.add(const RateDriverReviewSubmitted());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<RateDriverState>((s) => s.status == RateDriverStatus.submitting && s.isSubmitting),
          predicate<RateDriverState>((s) => s.status == RateDriverStatus.success && !s.isSubmitting),
        ]),
      );
    });

    test('alreadyRated and windowExpired statuses block star selection', () async {
      bloc.add(const RateDriverStarted(
        initialStatus: RateDriverStatus.alreadyRated,
        initialStars: 5,
      ));
      await pumpEventQueue();

      expect(bloc.state.status, RateDriverStatus.alreadyRated);
      expect(bloc.state.isAlreadyRated, isTrue);

      // Try selecting 1 star
      bloc.add(const RateDriverStarsSelected(1));
      await pumpEventQueue();

      // State remains alreadyRated and 5 stars
      expect(bloc.state.status, RateDriverStatus.alreadyRated);
      expect(bloc.state.selectedStars, 5);
    });

    test('skip, back to home, back to receipt, and report issue events update navigation flags', () async {
      bloc.add(const RateDriverStarted());
      await pumpEventQueue();

      bloc.add(const RateDriverSkipTapped());
      expect(bloc.state.navigateToHome, isTrue);

      bloc.add(const RateDriverBackToReceiptTapped());
      expect(bloc.state.navigateToReceipt, isTrue);

      bloc.add(const RateDriverReportIssueTapped());
      expect(bloc.state.showReportIssueSheet, isTrue);
    });
  });
}
