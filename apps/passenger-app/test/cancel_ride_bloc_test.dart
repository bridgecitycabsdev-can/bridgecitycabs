import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/cancel_ride/cancel_ride.dart';

void main() {
  group('CancelRideBloc Tests', () {
    late MockCancelRideRepository repository;
    late CancelRideBloc bloc;

    setUp(() {
      repository = MockCancelRideRepository(
        delay: const Duration(milliseconds: 10),
      );
      bloc = CancelRideBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state defaults to confirm when trip not started', () {
      expect(bloc.state.status, CancelRideStatus.confirm);
      expect(bloc.state.isConfirm, isTrue);
      expect(bloc.state.title, 'Cancel this ride?');
      expect(bloc.state.details.selectedReason, 'Changed my plans');
      expect(bloc.state.details.feeAmountCad, 0.0);
    });

    test('initial state defaults to cannotCancel when trip is already started', () {
      const startedDetails = CancellationDetails(isTripStarted: true);
      bloc.add(const CancelRideStarted(details: startedDetails));

      expect(bloc.state.status, CancelRideStatus.cannotCancel);
      expect(bloc.state.isCannotCancel, isTrue);
      expect(bloc.state.title, 'Cannot cancel ride');
      expect(bloc.state.subtitle, 'Your ride is currently in progress.');
    });

    test('selecting cancellation reason updates state', () async {
      bloc.add(const CancelRideStarted());
      await pumpEventQueue();

      bloc.add(const CancelRideReasonSelected('Driver taking too long'));

      await expectLater(
        bloc.stream,
        emits(predicate<CancelRideState>((s) {
          return s.details.selectedReason == 'Driver taking too long';
        })),
      );
    });

    test('cancellation confirmation transitions through cancelling to cancelledSuccess with zero fee', () async {
      bloc.add(const CancelRideStarted());
      await pumpEventQueue();

      bloc.add(const CancelRideConfirmed());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<CancelRideState>((s) {
            return s.status == CancelRideStatus.cancelling &&
                s.isCancelling &&
                s.isSubmitting;
          }),
          predicate<CancelRideState>((s) {
            return s.status == CancelRideStatus.cancelledSuccess &&
                s.isCancelledSuccess &&
                s.showSuccessBanner &&
                s.navigateToHome &&
                s.details.feeAmountCad == 0.0;
          }),
        ]),
      );
    });

    test('cancellation confirmation emits cannotCancel if trip has started on server', () async {
      final ongoingRepo = MockCancelRideRepository(isTripOngoing: true);
      final ongoingBloc = CancelRideBloc(repository: ongoingRepo);

      ongoingBloc.add(const CancelRideStarted());
      await pumpEventQueue();

      ongoingBloc.add(const CancelRideConfirmed());

      await expectLater(
        ongoingBloc.stream,
        emits(predicate<CancelRideState>((s) {
          return s.status == CancelRideStatus.cannotCancel &&
              s.isCannotCancel &&
              s.details.isTripStarted;
        })),
      );

      ongoingBloc.close();
    });

    test('dismissing cancellation sets navigateBack', () async {
      bloc.add(const CancelRideStarted());
      await pumpEventQueue();

      bloc.add(const CancelRideDismissed());
      expect(bloc.state.navigateBack, isTrue);
    });

    test('tapping back to trip sets navigateToTrip', () async {
      bloc.add(const CancelRideStarted(isTripStarted: true));
      await pumpEventQueue();

      bloc.add(const CancelRideBackToTripTapped());
      expect(bloc.state.navigateToTrip, isTrue);
    });
  });
}
