import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/history/history.dart';

void main() {
  group('DriverTripHistoryBloc Tests', () {
    late FakeDriverTripHistoryRepository repository;
    late DriverTripHistoryBloc bloc;

    setUp(() {
      repository = FakeDriverTripHistoryRepository(
        latency: const Duration(milliseconds: 10),
      );
      bloc = DriverTripHistoryBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state defaults to gallery with offline alert and edge state cards', () {
      expect(bloc.state.status, DriverTripHistoryStatus.gallery);
      expect(bloc.state.isGallery, isTrue);
      expect(bloc.state.isOnline, isTrue);
      expect(bloc.state.isOfflineWarningVisible, isTrue);
      expect(bloc.state.isZeroActiveDispatches, isTrue);
      expect(bloc.state.hasFilteredEmptyNotice, isTrue);
      expect(bloc.state.trips.length, 1);
      expect(bloc.state.trips.first.status, 'CANCELLED');
      expect(bloc.state.trips.first.fare, 0.00);
      expect(bloc.state.isSyncingRecent, isTrue);
    });

    test('Period selected updates selectedPeriod and expands custom range on demand', () {
      bloc.add(const DriverTripHistoryPeriodSelected(DriverTripFilterPeriod.today));
      expect(bloc.state.selectedPeriod, DriverTripFilterPeriod.today);
      expect(bloc.state.isCustomRangeExpanded, isFalse);

      bloc.add(const DriverTripHistoryPeriodSelected(DriverTripFilterPeriod.customRange));
      expect(bloc.state.selectedPeriod, DriverTripFilterPeriod.customRange);
      expect(bloc.state.isCustomRangeExpanded, isTrue);
    });

    test('Custom range configuration updates start and end dates', () {
      bloc.add(const DriverTripHistoryCustomRangeConfigured(
        startDate: '01 May 2024',
        endDate: '15 May 2024',
      ));
      expect(bloc.state.customStartDate, '01 May 2024');
      expect(bloc.state.customEndDate, '15 May 2024');
    });

    test('Applying period filter queries repository and returns to gallery', () async {
      bloc.add(const DriverTripHistoryPeriodSelected(DriverTripFilterPeriod.thisWeek));
      bloc.add(const DriverTripHistoryFilterApplied());

      expect(bloc.state.isActionLoading, isTrue);

      await Future.delayed(const Duration(milliseconds: 25));

      expect(bloc.state.isActionLoading, isFalse);
      expect(bloc.state.status, DriverTripHistoryStatus.gallery);
      expect(bloc.state.trips.length, 2);
      expect(bloc.state.feedbackMessage, contains('Applied filter: This week'));
    });

    test('Selecting a trip loads detail manifest and sets status to tripDetail', () async {
      bloc.add(const DriverTripHistoryTripSelected('BC-123456'));
      expect(bloc.state.isActionLoading, isTrue);

      await Future.delayed(const Duration(milliseconds: 25));

      expect(bloc.state.isActionLoading, isFalse);
      expect(bloc.state.status, DriverTripHistoryStatus.tripDetail);
      expect(bloc.state.isTripDetail, isTrue);
      expect(bloc.state.selectedTrip?.id, 'BC-123456');
      expect(bloc.state.selectedTrip?.passenger.name, 'Jordan S.');
      expect(bloc.state.selectedTrip?.fareBreakdown?.netEarning, 20.19);
    });

    test('Back to gallery resets status to gallery', () {
      bloc.add(const DriverTripHistoryStateForced(DriverTripHistoryStatus.tripDetail));
      expect(bloc.state.status, DriverTripHistoryStatus.tripDetail);

      bloc.add(const DriverTripHistoryBackToGalleryPressed());
      expect(bloc.state.status, DriverTripHistoryStatus.gallery);
    });

    test('Sync retry calls repository and hides offline banner', () async {
      bloc.add(const DriverTripHistorySyncRetryPressed());
      expect(bloc.state.isActionLoading, isTrue);

      await Future.delayed(const Duration(milliseconds: 25));

      expect(bloc.state.isActionLoading, isFalse);
      expect(bloc.state.isOfflineWarningVisible, isFalse);
      expect(bloc.state.isSyncingRecent, isFalse);
      expect(bloc.state.feedbackMessage, contains('synced successfully'));
    });

    test('Go online triggers dispatch navigation flag', () {
      bloc.add(const DriverTripHistoryGoOnlinePressed());
      expect(bloc.state.shouldNavigateToDispatch, isTrue);
      expect(bloc.state.feedbackMessage, contains('Going online'));
    });

    test('Reporting an issue calls repository and sets feedback message', () async {
      bloc.add(const DriverTripHistoryIssueReported('BC-123456'));
      expect(bloc.state.isActionLoading, isTrue);

      await Future.delayed(const Duration(milliseconds: 25));

      expect(bloc.state.isActionLoading, isFalse);
      expect(bloc.state.feedbackMessage, contains('submitted to fleet dispatch'));
    });

    test('State forced switches properly between all 4 preset states', () {
      // 1. Gallery
      bloc.add(const DriverTripHistoryStateForced(DriverTripHistoryStatus.gallery));
      expect(bloc.state.status, DriverTripHistoryStatus.gallery);
      expect(bloc.state.isZeroActiveDispatches, isTrue);

      // 2. Trip Detail
      bloc.add(const DriverTripHistoryStateForced(DriverTripHistoryStatus.tripDetail));
      expect(bloc.state.status, DriverTripHistoryStatus.tripDetail);
      expect(bloc.state.selectedTrip?.id, 'BC-123456');

      // 3. Filter Sheet
      bloc.add(const DriverTripHistoryStateForced(DriverTripHistoryStatus.filterSheet));
      expect(bloc.state.status, DriverTripHistoryStatus.filterSheet);
      expect(bloc.state.isFilterSheetVisible, isTrue);

      // 4. Empty State
      bloc.add(const DriverTripHistoryStateForced(DriverTripHistoryStatus.emptyNoRides));
      expect(bloc.state.status, DriverTripHistoryStatus.emptyNoRides);
      expect(bloc.state.isEmptyNoRides, isTrue);
      expect(bloc.state.trips.isEmpty, isTrue);
    });
  });
}
