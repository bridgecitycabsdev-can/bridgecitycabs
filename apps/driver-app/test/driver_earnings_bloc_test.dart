import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/earnings/earnings.dart';

void main() {
  group('DriverEarningsBloc Tests', () {
    late FakeDriverEarningsRepository repository;
    late DriverEarningsBloc bloc;

    setUp(() {
      repository = FakeDriverEarningsRepository(
        latency: const Duration(milliseconds: 10),
      );
      bloc = DriverEarningsBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state defaults to overview with Shajil, \$53.93 and 2 rides', () {
      expect(bloc.state.status, DriverEarningsStatus.overview);
      expect(bloc.state.isOverview, isTrue);
      expect(bloc.state.summary.driverName, 'Shajil');
      expect(bloc.state.summary.totalEarnings, 53.93);
      expect(bloc.state.summary.totalRides, 2);
      expect(bloc.state.summary.split.cashAmount, 29.43);
      expect(bloc.state.summary.split.cardAmount, 24.50);
      expect(bloc.state.summary.bankDetails.maskedAccount, '•••• 4821');
      expect(bloc.state.summary.recentStatements.length, 2);
    });

    test('Tab switched updates activeTabIndex', () {
      bloc.add(const DriverEarningsTabSwitched(1));
      expect(bloc.state.activeTabIndex, 1);
    });

    test('Period selected updates selectedPeriod and expands custom range when selected', () {
      bloc.add(const DriverEarningsPeriodSelected(DriverEarningsPeriod.today));
      expect(bloc.state.selectedPeriod, DriverEarningsPeriod.today);
      expect(bloc.state.isCustomRangeExpanded, isFalse);

      bloc.add(const DriverEarningsPeriodSelected(DriverEarningsPeriod.customRange));
      expect(bloc.state.selectedPeriod, DriverEarningsPeriod.customRange);
      expect(bloc.state.isCustomRangeExpanded, isTrue);
    });

    test('Custom range configuration updates start and end dates', () {
      bloc.add(const DriverEarningsCustomRangeConfigured(
        startDate: '01 May 2024',
        endDate: '15 May 2024',
      ));
      expect(bloc.state.customStartDate, '01 May 2024');
      expect(bloc.state.customEndDate, '15 May 2024');
    });

    test('Applying period filter calls repository and returns to overview', () async {
      bloc.add(const DriverEarningsPeriodSelected(DriverEarningsPeriod.today));
      bloc.add(const DriverEarningsPeriodFilterApplied());

      expect(bloc.state.isActionLoading, isTrue);

      await Future.delayed(const Duration(milliseconds: 25));

      expect(bloc.state.isActionLoading, isFalse);
      expect(bloc.state.status, DriverEarningsStatus.overview);
      expect(bloc.state.summary.totalEarnings, 41.77);
      expect(bloc.state.feedbackMessage, contains('Applied period: Today'));
    });

    test('Banking card tap navigates to banking form', () {
      bloc.add(const DriverEarningsBankingCardTapped());
      expect(bloc.state.status, DriverEarningsStatus.bankingForm);
      expect(bloc.state.isBankingForm, isTrue);
    });

    test('Updating and saving bank details updates summary and returns to overview', () async {
      const updatedBank = DriverBankDetails(
        accountHolderName: 'Marcus Vance',
        institutionNumber: '004',
        bankName: 'TD Canada Trust',
        transitNumber: '12345',
        accountNumber: '7654321',
        maskedAccount: '•••• 4321',
        isVerified: true,
        isConfirmed: true,
      );

      bloc.add(const DriverEarningsBankDetailsUpdated(updatedBank));
      expect(bloc.state.bankForm.bankName, 'TD Canada Trust');

      bloc.add(const DriverEarningsBankDetailsSaved());
      expect(bloc.state.isActionLoading, isTrue);

      await Future.delayed(const Duration(milliseconds: 25));

      expect(bloc.state.isActionLoading, isFalse);
      expect(bloc.state.status, DriverEarningsStatus.overview);
      expect(bloc.state.summary.bankDetails.bankName, 'TD Canada Trust');
      expect(bloc.state.summary.bankDetails.maskedAccount, '•••• 4321');
      expect(bloc.state.feedbackMessage, contains('saved successfully'));
    });

    test('Selecting a statement navigates to statement detail view', () async {
      bloc.add(const DriverEarningsStatementSelected('stmt_jun_30'));
      expect(bloc.state.isActionLoading, isTrue);

      await Future.delayed(const Duration(milliseconds: 25));

      expect(bloc.state.isActionLoading, isFalse);
      expect(bloc.state.status, DriverEarningsStatus.statementDetail);
      expect(bloc.state.isStatementDetail, isTrue);
      expect(bloc.state.activeStatement?.netPayout, 341.49);
      expect(bloc.state.activeStatement?.trips.length, 4);
    });

    test('Download PDF requests feedback message', () {
      bloc.add(const DriverEarningsDownloadPdfRequested('stmt_jun_30'));
      expect(bloc.state.feedbackMessage, contains('Downloading official tax invoice PDF'));
    });

    test('Back to overview pressed resets status to overview', () {
      bloc.add(const DriverEarningsBankingCardTapped());
      expect(bloc.state.status, DriverEarningsStatus.bankingForm);

      bloc.add(const DriverEarningsBackToOverviewPressed());
      expect(bloc.state.status, DriverEarningsStatus.overview);
    });

    test('State forced sets corresponding preset and status', () {
      // 1. Overview
      bloc.add(const DriverEarningsStateForced(DriverEarningsStatus.overview));
      expect(bloc.state.status, DriverEarningsStatus.overview);
      expect(bloc.state.summary.totalEarnings, 53.93);

      // 2. Banking Form
      bloc.add(const DriverEarningsStateForced(DriverEarningsStatus.bankingForm));
      expect(bloc.state.status, DriverEarningsStatus.bankingForm);
      expect(bloc.state.bankForm.institutionNumber, '003');

      // 3. Statement Detail
      bloc.add(const DriverEarningsStateForced(DriverEarningsStatus.statementDetail));
      expect(bloc.state.status, DriverEarningsStatus.statementDetail);
      expect(bloc.state.activeStatement?.netPayout, 341.49);

      // 4. Period Filter Sheet
      bloc.add(const DriverEarningsStateForced(DriverEarningsStatus.periodFilterSheet));
      expect(bloc.state.status, DriverEarningsStatus.periodFilterSheet);
      expect(bloc.state.isPeriodFilterVisible, isTrue);
    });
  });
}
