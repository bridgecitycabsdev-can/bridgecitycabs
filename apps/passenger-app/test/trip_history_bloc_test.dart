import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/trip_history/trip_history.dart';

void main() {
  group('TripHistoryBloc Unit Tests', () {
    late MockTripHistoryRepository repository;
    late TripHistoryBloc bloc;

    setUp(() {
      repository = MockTripHistoryRepository();
      bloc = TripHistoryBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state loads last trip from repository', () async {
      bloc.add(const TripHistoryStarted());
      await pumpEventQueue();

      expect(bloc.state.status, TripHistoryStatus.loaded);
      expect(bloc.state.lastTrip.tripId, 'BC-123456');
      expect(bloc.state.lastTrip.dateTimeLabel, 'Sat, 22 Aug • 2:48 PM');
      expect(bloc.state.lastTrip.totalCad, 20.16);
      expect(bloc.state.lastTrip.driverName, 'Marcus V.');
      expect(bloc.state.selectedScenario, TripPaymentScenario.cardPaid);
      expect(bloc.state.isCardPaid, isTrue);
    });

    test('TripHistoryScenarioChanged switches between Card, Cash, and Pending', () async {
      bloc.add(const TripHistoryStarted());
      await pumpEventQueue();

      bloc.add(const TripHistoryScenarioChanged(TripPaymentScenario.cashPaid));
      await pumpEventQueue();

      expect(bloc.state.selectedScenario, TripPaymentScenario.cashPaid);
      expect(bloc.state.isCashPaid, isTrue);
      expect(bloc.state.currentTrip.paymentMethod, 'Cash Payment');
      expect(bloc.state.currentTrip.paymentStatus, 'Paid in Cash');

      bloc.add(const TripHistoryScenarioChanged(TripPaymentScenario.cashPending));
      await pumpEventQueue();

      expect(bloc.state.selectedScenario, TripPaymentScenario.cashPending);
      expect(bloc.state.isCashPending, isTrue);
      expect(bloc.state.currentTrip.paymentStatus, contains('Awaiting Driver'));
    });

    test('download tax receipt updates state and downloads receipt', () async {
      bloc.add(const TripHistoryStarted());
      await pumpEventQueue();

      bloc.add(const TripHistoryDownloadReceiptTapped('BC-123456'));
      await pumpEventQueue();

      expect(bloc.state.status, TripHistoryStatus.downloadSuccess);
      expect(bloc.state.isDownloadingReceipt, isFalse);
      expect(bloc.state.feedbackMessage, contains('CRA compliant'));
    });

    test('action callbacks emit expected feedback messages', () async {
      bloc.add(const TripHistoryStarted());
      await pumpEventQueue();

      bloc.add(const TripHistoryOpenNotificationsTapped());
      expect(bloc.state.feedbackMessage, contains('Notifications'));

      bloc.add(const TripHistoryContactSupportTapped());
      expect(bloc.state.feedbackMessage, contains('Support'));

      bloc.add(const TripHistoryRateDriverTapped('BC-123456'));
      expect(bloc.state.feedbackMessage, contains('rating'));

      bloc.add(const TripHistoryReportProblemTapped('BC-123456'));
      expect(bloc.state.feedbackMessage, contains('support ticket'));
    });
  });
}
