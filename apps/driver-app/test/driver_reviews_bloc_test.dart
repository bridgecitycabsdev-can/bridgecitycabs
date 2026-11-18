import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/reviews/reviews.dart';

void main() {
  group('DriverReviewsBloc Tests', () {
    late FakeDriverReviewsRepository repository;
    late DriverReviewsBloc bloc;

    setUp(() {
      repository = FakeDriverReviewsRepository(
        latency: const Duration(milliseconds: 10),
      );
      bloc = DriverReviewsBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state defaults to list with 4.8 rating and 4 reviews', () {
      expect(bloc.state.status, DriverReviewsStatus.list);
      expect(bloc.state.isList, isTrue);
      expect(bloc.state.distribution.overallRating, 4.8);
      expect(bloc.state.distribution.totalReviews, 120);
      expect(bloc.state.distribution.star5Count, 98);
      expect(bloc.state.reviews.length, 4);
      expect(bloc.state.reviews.first.passengerName, 'Marcus T.');
      expect(bloc.state.reviews.last.isLowRating, isTrue);
    });

    test('Filter star selection updates selectedFilter and filters reviews', () async {
      bloc.add(const DriverReviewsFilterStarSelected(DriverReviewFilterStar.star5));
      expect(bloc.state.isActionLoading, isTrue);

      await Future.delayed(const Duration(milliseconds: 25));

      expect(bloc.state.isActionLoading, isFalse);
      expect(bloc.state.selectedFilter, DriverReviewFilterStar.star5);
      expect(bloc.state.reviews.every((r) => r.rating == 5), isTrue);
    });

    test('Selecting 1 star filter triggers noMatchingFilter state', () async {
      bloc.add(const DriverReviewsFilterStarSelected(DriverReviewFilterStar.star1));
      await Future.delayed(const Duration(milliseconds: 25));

      expect(bloc.state.status, DriverReviewsStatus.noMatchingFilter);
      expect(bloc.state.isNoMatchingFilter, isTrue);
      expect(bloc.state.reviews.isEmpty, isTrue);
    });

    test('Resetting filter sets filter back to All (120)', () async {
      bloc.add(const DriverReviewsFilterStarSelected(DriverReviewFilterStar.star1));
      await Future.delayed(const Duration(milliseconds: 25));
      expect(bloc.state.isNoMatchingFilter, isTrue);

      bloc.add(const DriverReviewsFilterReset());
      await Future.delayed(const Duration(milliseconds: 25));

      expect(bloc.state.status, DriverReviewsStatus.list);
      expect(bloc.state.selectedFilter, DriverReviewFilterStar.all);
      expect(bloc.state.reviews.length, 4);
    });

    test('Selecting a review opens detailModal and populates selectedReview', () {
      bloc.add(const DriverReviewsReviewSelected('REV-88421'));
      expect(bloc.state.status, DriverReviewsStatus.detailModal);
      expect(bloc.state.isDetailModalVisible, isTrue);
      expect(bloc.state.selectedReview?.id, 'REV-88421');
      expect(bloc.state.selectedReview?.passengerName, 'Marcus T.');
    });

    test('Dismissing modal returns status to list', () {
      bloc.add(const DriverReviewsReviewSelected('REV-88421'));
      expect(bloc.state.isDetailModalVisible, isTrue);

      bloc.add(const DriverReviewsModalDismissed());
      expect(bloc.state.status, DriverReviewsStatus.list);
      expect(bloc.state.isList, isTrue);
    });

    test('Reporting a review triggers audit feedback and closes modal', () async {
      bloc.add(const DriverReviewsReportReviewPressed('REV-88421'));
      expect(bloc.state.isActionLoading, isTrue);

      await Future.delayed(const Duration(milliseconds: 25));

      expect(bloc.state.isActionLoading, isFalse);
      expect(bloc.state.status, DriverReviewsStatus.list);
      expect(bloc.state.feedbackMessage, contains('submitted for Lethbridge Taxi Commission audit'));
    });

    test('Sync retry calls repository and hides offline banner', () async {
      bloc.add(const DriverReviewsStateForced(DriverReviewsStatus.edgeStatesGallery));
      expect(bloc.state.isOfflineWarningVisible, isTrue);

      bloc.add(const DriverReviewsSyncRetryPressed());
      expect(bloc.state.isActionLoading, isTrue);

      await Future.delayed(const Duration(milliseconds: 25));

      expect(bloc.state.isActionLoading, isFalse);
      expect(bloc.state.isOfflineWarningVisible, isFalse);
      expect(bloc.state.feedbackMessage, contains('synced with Bridge City dispatch'));
    });

    test('Go online emits navigation to dispatch', () {
      bloc.add(const DriverReviewsGoOnlinePressed());
      expect(bloc.state.shouldNavigateToDispatch, isTrue);
      expect(bloc.state.feedbackMessage, contains('Navigating to dispatch shift'));
    });

    test('State forced sets corresponding preset states', () {
      // 1. List
      bloc.add(const DriverReviewsStateForced(DriverReviewsStatus.list));
      expect(bloc.state.status, DriverReviewsStatus.list);
      expect(bloc.state.reviews.length, 4);

      // 2. Detail Modal
      bloc.add(const DriverReviewsStateForced(DriverReviewsStatus.detailModal));
      expect(bloc.state.status, DriverReviewsStatus.detailModal);
      expect(bloc.state.selectedReview?.id, 'REV-88421');

      // 3. Edge States Gallery
      bloc.add(const DriverReviewsStateForced(DriverReviewsStatus.edgeStatesGallery));
      expect(bloc.state.status, DriverReviewsStatus.edgeStatesGallery);
      expect(bloc.state.isOfflineWarningVisible, isTrue);

      // 4. No Matching Filter
      bloc.add(const DriverReviewsStateForced(DriverReviewsStatus.noMatchingFilter));
      expect(bloc.state.status, DriverReviewsStatus.noMatchingFilter);
      expect(bloc.state.reviews.isEmpty, isTrue);

      // 5. New Driver Empty
      bloc.add(const DriverReviewsStateForced(DriverReviewsStatus.newDriverEmpty));
      expect(bloc.state.status, DriverReviewsStatus.newDriverEmpty);
      expect(bloc.state.distribution.totalReviews, 0);

      // 6. Service Failure
      bloc.add(const DriverReviewsStateForced(DriverReviewsStatus.serviceFailure));
      expect(bloc.state.status, DriverReviewsStatus.serviceFailure);
    });
  });
}
