import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/driver_earnings_config.dart';
import '../data/models/driver_earnings_period.dart';
import '../data/models/driver_earnings_status.dart';
import '../data/repositories/driver_earnings_repository.dart';
import 'driver_earnings_event.dart';
import 'driver_earnings_state.dart';

class DriverEarningsBloc
    extends Bloc<DriverEarningsEvent, DriverEarningsState> {
  final DriverEarningsRepository repository;

  DriverEarningsBloc({required this.repository})
      : super(DriverEarningsState.initial()) {
    on<DriverEarningsStarted>(_onStarted);
    on<DriverEarningsPeriodFilterRequested>(_onPeriodFilterRequested);
    on<DriverEarningsPeriodSelected>(_onPeriodSelected);
    on<DriverEarningsCustomRangeConfigured>(_onCustomRangeConfigured);
    on<DriverEarningsPeriodFilterApplied>(_onPeriodFilterApplied);
    on<DriverEarningsPeriodFilterDismissed>(_onPeriodFilterDismissed);
    on<DriverEarningsTabSwitched>(_onTabSwitched);
    on<DriverEarningsBankingCardTapped>(_onBankingCardTapped);
    on<DriverEarningsBankDetailsUpdated>(_onBankDetailsUpdated);
    on<DriverEarningsBankDetailsSaved>(_onBankDetailsSaved);
    on<DriverEarningsStatementSelected>(_onStatementSelected);
    on<DriverEarningsDownloadPdfRequested>(_onDownloadPdfRequested);
    on<DriverEarningsBackToOverviewPressed>(_onBackToOverviewPressed);
    on<DriverEarningsStateForced>(_onStateForced);
  }

  void _onStarted(
    DriverEarningsStarted event,
    Emitter<DriverEarningsState> emit,
  ) {
    add(DriverEarningsStateForced(event.initialStatus));
  }

  void _onPeriodFilterRequested(
    DriverEarningsPeriodFilterRequested event,
    Emitter<DriverEarningsState> emit,
  ) {
    emit(state.copyWith(status: DriverEarningsStatus.periodFilterSheet));
  }

  void _onPeriodSelected(
    DriverEarningsPeriodSelected event,
    Emitter<DriverEarningsState> emit,
  ) {
    emit(
      state.copyWith(
        selectedPeriod: event.period,
        isCustomRangeExpanded: event.period == DriverEarningsPeriod.customRange,
      ),
    );
  }

  void _onCustomRangeConfigured(
    DriverEarningsCustomRangeConfigured event,
    Emitter<DriverEarningsState> emit,
  ) {
    emit(
      state.copyWith(
        customStartDate: event.startDate,
        customEndDate: event.endDate,
      ),
    );
  }

  Future<void> _onPeriodFilterApplied(
    DriverEarningsPeriodFilterApplied event,
    Emitter<DriverEarningsState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true));
    try {
      final updatedSummary = await repository.fetchEarningsSummary(
        state.selectedPeriod,
      );
      emit(
        state.copyWith(
          status: DriverEarningsStatus.overview,
          summary: updatedSummary,
          isActionLoading: false,
          feedbackMessage: 'Applied period: ${state.selectedPeriod.label}',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isActionLoading: false,
          status: DriverEarningsStatus.overview,
          feedbackMessage: 'Filter error: $e',
        ),
      );
    }
  }

  void _onPeriodFilterDismissed(
    DriverEarningsPeriodFilterDismissed event,
    Emitter<DriverEarningsState> emit,
  ) {
    emit(state.copyWith(status: DriverEarningsStatus.overview));
  }

  void _onTabSwitched(
    DriverEarningsTabSwitched event,
    Emitter<DriverEarningsState> emit,
  ) {
    emit(state.copyWith(activeTabIndex: event.tabIndex));
  }

  void _onBankingCardTapped(
    DriverEarningsBankingCardTapped event,
    Emitter<DriverEarningsState> emit,
  ) {
    emit(state.copyWith(status: DriverEarningsStatus.bankingForm));
  }

  void _onBankDetailsUpdated(
    DriverEarningsBankDetailsUpdated event,
    Emitter<DriverEarningsState> emit,
  ) {
    emit(state.copyWith(bankForm: event.bankDetails));
  }

  Future<void> _onBankDetailsSaved(
    DriverEarningsBankDetailsSaved event,
    Emitter<DriverEarningsState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true));
    try {
      await repository.saveBankDetails(state.bankForm);
      final updatedSummary = state.summary.copyWith(
        bankDetails: state.bankForm,
      );
      emit(
        state.copyWith(
          isActionLoading: false,
          status: DriverEarningsStatus.overview,
          summary: updatedSummary,
          feedbackMessage:
              'Direct deposit account ${state.bankForm.maskedAccount} saved successfully.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isActionLoading: false,
          feedbackMessage: 'Failed to save bank details: $e',
        ),
      );
    }
  }

  Future<void> _onStatementSelected(
    DriverEarningsStatementSelected event,
    Emitter<DriverEarningsState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true));
    try {
      final stmt = await repository.fetchStatementDetail(event.statementId);
      emit(
        state.copyWith(
          isActionLoading: false,
          status: DriverEarningsStatus.statementDetail,
          activeStatement: stmt,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isActionLoading: false,
          feedbackMessage: 'Failed to load statement: $e',
        ),
      );
    }
  }

  Future<void> _onDownloadPdfRequested(
    DriverEarningsDownloadPdfRequested event,
    Emitter<DriverEarningsState> emit,
  ) async {
    emit(
      state.copyWith(
        feedbackMessage:
            'Downloading official tax invoice PDF for ${event.statementId}...',
      ),
    );
  }

  void _onBackToOverviewPressed(
    DriverEarningsBackToOverviewPressed event,
    Emitter<DriverEarningsState> emit,
  ) {
    emit(state.copyWith(status: DriverEarningsStatus.overview));
  }

  void _onStateForced(
    DriverEarningsStateForced event,
    Emitter<DriverEarningsState> emit,
  ) {
    switch (event.status) {
      case DriverEarningsStatus.overview:
        emit(
          state.copyWith(
            status: DriverEarningsStatus.overview,
            summary: DriverEarningsConfig.overviewPreset(),
            activeTabIndex: 0,
            isActionLoading: false,
          ),
        );
        break;
      case DriverEarningsStatus.bankingForm:
        emit(
          state.copyWith(
            status: DriverEarningsStatus.bankingForm,
            bankForm: DriverEarningsConfig.bankingFormPreset(),
            isActionLoading: false,
          ),
        );
        break;
      case DriverEarningsStatus.statementDetail:
        emit(
          state.copyWith(
            status: DriverEarningsStatus.statementDetail,
            activeStatement: DriverEarningsConfig.statementDetailPreset(),
            isActionLoading: false,
          ),
        );
        break;
      case DriverEarningsStatus.periodFilterSheet:
        emit(
          state.copyWith(
            status: DriverEarningsStatus.periodFilterSheet,
            summary: DriverEarningsConfig.overviewPreset(),
            selectedPeriod: DriverEarningsPeriod.thisWeek,
            isActionLoading: false,
          ),
        );
        break;
    }
  }
}
