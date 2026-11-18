import 'package:driver_app/features/trip_summary/trip_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriverTripSummaryBloc Tests', () {
    late FakeDriverTripSummaryRepository repository;
    late DriverTripSummaryBloc bloc;

    setUp(() {
      repository = FakeDriverTripSummaryRepository();
      bloc = DriverTripSummaryBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state defaults to Card Auto-Settled with \$22.10 and \$18.78 net', () {
      expect(bloc.state.status, DriverTripSummaryStatus.cardSettled);
      expect(bloc.state.isCardSettled, isTrue);
      expect(bloc.state.summary.grossMeteredFare, 22.10);
      expect(bloc.state.summary.netPayout, 18.78);
      expect(bloc.state.summary.cardBrand, 'VISA');
      expect(bloc.state.summary.cardEnding, '•••• 8842');
      expect(bloc.state.summary.passengerName, 'Alex M.');
    });

    test('DriverTripSummaryStarted loads summary from repository', () async {
      bloc.add(const DriverTripSummaryStarted(tripId: 'BC-123456'));
      await Future.delayed(const Duration(milliseconds: 150));

      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.summary.tripId, 'BC-123456');
    });

    test('Cash collected records cash and emits toast confirmation', () async {
      bloc.add(const DriverTripSummaryStateForced(DriverTripSummaryStatus.cashDue));
      expect(bloc.state.isCashDue, isTrue);
      expect(bloc.state.summary.isCashCollected, isFalse);

      bloc.add(const DriverTripSummaryCashCollectedPressed());
      await Future.delayed(const Duration(milliseconds: 200));

      expect(bloc.state.summary.isCashCollected, isTrue);
      expect(bloc.state.summary.isPaid, isTrue);
      expect(bloc.state.toastMessage, contains('\$18.78 credited to shift balance'));
    });

    test('Rating experience, tags and dispatcher notes flow', () async {
      bloc.add(const DriverTripSummaryStateForced(DriverTripSummaryStatus.ratePassenger));
      expect(bloc.state.isRatePassenger, isTrue);

      // Change rating to 5.0
      bloc.add(const DriverTripSummaryRatingChanged(5.0));
      expect(bloc.state.summary.ratingModel.rating, 5.0);
      expect(bloc.state.summary.ratingModel.ratingLabel, contains('5.0 - Excellent passenger'));

      // Toggle tags
      bloc.add(const DriverTripSummaryTagToggled('Clean'));
      expect(bloc.state.summary.ratingModel.selectedTags, contains('Clean'));

      // Dispatcher feedback
      bloc.add(const DriverTripSummaryFeedbackNotesChanged('Smooth pickup at University'));
      expect(bloc.state.summary.ratingModel.dispatcherFeedbackNotes, 'Smooth pickup at University');

      // Submit rating
      bloc.add(const DriverTripSummaryRatingSubmitted());
      await Future.delayed(const Duration(milliseconds: 200));

      expect(bloc.state.summary.ratingModel.isSubmitted, isTrue);
      expect(bloc.state.toastMessage, contains('Rating submitted to Lethbridge fleet log'));
    });

    test('Skipping rating transitions back to cardSettled', () {
      bloc.add(const DriverTripSummaryStateForced(DriverTripSummaryStatus.ratePassenger));
      bloc.add(const DriverTripSummaryRatingSkipped());
      expect(bloc.state.status, DriverTripSummaryStatus.cardSettled);
    });

    test('Selecting edge state updates activeEdgeState', () {
      bloc.add(const DriverTripSummaryEdgeStateSelected(DriverEdgeStateType.networkError));
      expect(bloc.state.summary.activeEdgeState, DriverEdgeStateType.networkError);
    });

    test('Retry payment sync triggers repository call and emits toast', () async {
      bloc.add(const DriverTripSummaryRetryPaymentPressed());
      await Future.delayed(const Duration(milliseconds: 200));
      expect(bloc.state.toastMessage, contains('Re-syncing with terminal batch #84'));
    });

    test('Done return button triggers isReturnedToDispatch', () {
      bloc.add(const DriverTripSummaryDoneReturnPressed());
      expect(bloc.state.isReturnedToDispatch, isTrue);
      expect(bloc.state.toastMessage, contains('Returning to Lethbridge Fleet Dispatch'));
    });

    test('State forced switches smoothly between all 4 visual screens', () {
      // 1. Cash Due (Screenshot 4)
      bloc.add(const DriverTripSummaryStateForced(DriverTripSummaryStatus.cashDue));
      expect(bloc.state.status, DriverTripSummaryStatus.cashDue);
      expect(bloc.state.summary.paymentStatusLabel, 'CASH PAYMENT DUE');
      expect(bloc.state.summary.changeOptions.length, 2);

      // 2. Rate Passenger (Screenshot 5 top)
      bloc.add(const DriverTripSummaryStateForced(DriverTripSummaryStatus.ratePassenger));
      expect(bloc.state.status, DriverTripSummaryStatus.ratePassenger);
      expect(bloc.state.summary.ratingModel.passengerName, 'Alex M.');

      // 3. 6 Edge States (Screenshot 5 bottom)
      bloc.add(const DriverTripSummaryStateForced(DriverTripSummaryStatus.edgeStatesGallery));
      expect(bloc.state.status, DriverTripSummaryStatus.edgeStatesGallery);

      // 4. Card Settled (Screenshot 3)
      bloc.add(const DriverTripSummaryStateForced(DriverTripSummaryStatus.cardSettled));
      expect(bloc.state.status, DriverTripSummaryStatus.cardSettled);
      expect(bloc.state.summary.grossMeteredFare, 22.10);
    });
  });
}
