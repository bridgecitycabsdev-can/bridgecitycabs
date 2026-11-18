import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/past_trip_detail/past_trip_detail.dart';

void main() {
  group('PastTripDetailBloc Tests', () {
    late PastTripDetailBloc bloc;
    late PastTripDetailRepository repository;

    setUp(() {
      repository = PastTripDetailRepositoryImpl(latency: Duration.zero);
      bloc = PastTripDetailBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state defaults to initial status with Marcus trip', () {
      expect(bloc.state.status, PastTripDetailStatus.initial);
      expect(bloc.state.selectedSegment, TripDetailSegment.completedCard);
      expect(bloc.state.trip.driverName, 'Marcus V.');
      expect(bloc.state.formattedTotal, '\$20.16 CAD');
      expect(bloc.state.formattedTripId, 'BC-123456');
      expect(bloc.state.isInspectorMode, isFalse);
    });

    test('PastTripDetailStarted loads trip and enables inspector for Harpreet', () async {
      bloc.add(const PastTripDetailStarted(tripId: 'Trip #BCC-84920'));

      await expectLater(
        bloc.stream,
        emitsThrough(predicate<PastTripDetailState>((s) {
          return s.status == PastTripDetailStatus.loaded &&
              s.trip.driverName == 'Harpreet S.' &&
              s.trip.totalChargedCad == 22.10 &&
              s.isInspectorMode == true;
        })),
      );
    });

    test('PastTripDetailSegmentChanged updates scenario and trip payment mode', () async {
      bloc.add(const PastTripDetailSegmentChanged(TripDetailSegment.completedCash));

      await expectLater(
        bloc.stream,
        emits(predicate<PastTripDetailState>((s) {
          return s.selectedSegment == TripDetailSegment.completedCash &&
              s.trip.isCash == true &&
              s.trip.paymentMethodTitle == 'Cash Payment';
        })),
      );

      bloc.add(const PastTripDetailSegmentChanged(TripDetailSegment.inProgress));

      await expectLater(
        bloc.stream,
        emits(predicate<PastTripDetailState>((s) {
          return s.selectedSegment == TripDetailSegment.inProgress &&
              s.trip.isInProgress == true &&
              s.trip.statusLabel == 'In Progress';
        })),
      );
    });

    test('PastTripDetailQaScenarioSelected updates state for edge scenarios', () async {
      bloc.add(const PastTripDetailQaScenarioSelected(PastTripQaScenario.cancelledWithFee));

      await expectLater(
        bloc.stream,
        emits(predicate<PastTripDetailState>((s) {
          return s.selectedQaScenario == PastTripQaScenario.cancelledWithFee &&
              s.trip.statusLabel == 'Cancelled' &&
              s.trip.totalChargedCad == 5.25;
        })),
      );

      bloc.add(const PastTripDetailQaScenarioSelected(PastTripQaScenario.promoApplied));

      await expectLater(
        bloc.stream,
        emits(predicate<PastTripDetailState>((s) {
          return s.selectedQaScenario == PastTripQaScenario.promoApplied &&
              s.trip.totalChargedCad == 14.91;
        })),
      );
    });

    test('PastTripDetailCopyTripIdTapped triggers clipboard state', () async {
      bloc.add(const PastTripDetailCopyTripIdTapped('BC-123456'));

      await expectLater(
        bloc.stream,
        emits(predicate<PastTripDetailState>((s) {
          return s.isCopied &&
              s.feedbackMessage != null &&
              s.feedbackMessage!.contains('copied to clipboard');
        })),
      );
    });

    test('PastTripDetailDownloadReceiptTapped simulates PDF tax receipt download', () async {
      bloc.add(const PastTripDetailDownloadReceiptTapped('BC-123456'));

      await expectLater(
        bloc.stream,
        emitsThrough(predicate<PastTripDetailState>((s) {
          return !s.isDownloadingPdf &&
              s.feedbackMessage != null &&
              s.feedbackMessage!.contains('Downloaded');
        })),
      );
    });

    test('PastTripDetailBookReturnTapped initiates return ride booking', () async {
      bloc.add(PastTripDetailBookReturnTapped(bloc.state.trip));

      await expectLater(
        bloc.stream,
        emitsThrough(predicate<PastTripDetailState>((s) {
          return !s.isBookingReturn &&
              s.feedbackMessage != null &&
              s.feedbackMessage!.contains('Return ride booked');
        })),
      );
    });

    test('PastTripDetailToggleViewMode toggles between metered and inspector views', () async {
      bloc.add(const PastTripDetailToggleViewMode());

      await expectLater(
        bloc.stream,
        emits(predicate<PastTripDetailState>((s) => s.isInspectorMode == true)),
      );

      bloc.add(const PastTripDetailToggleViewMode());

      await expectLater(
        bloc.stream,
        emits(predicate<PastTripDetailState>((s) => s.isInspectorMode == false)),
      );
    });
  });
}
