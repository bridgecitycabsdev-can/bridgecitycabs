import 'package:equatable/equatable.dart';
import '../data/models/driver_bank_details.dart';
import '../data/models/driver_earnings_period.dart';
import '../data/models/driver_earnings_status.dart';

abstract class DriverEarningsEvent extends Equatable {
  const DriverEarningsEvent();

  @override
  List<Object?> get props => [];
}

class DriverEarningsStarted extends DriverEarningsEvent {
  final DriverEarningsStatus initialStatus;

  const DriverEarningsStarted({
    this.initialStatus = DriverEarningsStatus.overview,
  });

  @override
  List<Object?> get props => [initialStatus];
}

class DriverEarningsPeriodFilterRequested extends DriverEarningsEvent {
  const DriverEarningsPeriodFilterRequested();
}

class DriverEarningsPeriodSelected extends DriverEarningsEvent {
  final DriverEarningsPeriod period;

  const DriverEarningsPeriodSelected(this.period);

  @override
  List<Object?> get props => [period];
}

class DriverEarningsCustomRangeConfigured extends DriverEarningsEvent {
  final String startDate;
  final String endDate;

  const DriverEarningsCustomRangeConfigured({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class DriverEarningsPeriodFilterApplied extends DriverEarningsEvent {
  const DriverEarningsPeriodFilterApplied();
}

class DriverEarningsPeriodFilterDismissed extends DriverEarningsEvent {
  const DriverEarningsPeriodFilterDismissed();
}

class DriverEarningsTabSwitched extends DriverEarningsEvent {
  final int tabIndex;

  const DriverEarningsTabSwitched(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

class DriverEarningsBankingCardTapped extends DriverEarningsEvent {
  const DriverEarningsBankingCardTapped();
}

class DriverEarningsBankDetailsUpdated extends DriverEarningsEvent {
  final DriverBankDetails bankDetails;

  const DriverEarningsBankDetailsUpdated(this.bankDetails);

  @override
  List<Object?> get props => [bankDetails];
}

class DriverEarningsBankDetailsSaved extends DriverEarningsEvent {
  const DriverEarningsBankDetailsSaved();
}

class DriverEarningsStatementSelected extends DriverEarningsEvent {
  final String statementId;

  const DriverEarningsStatementSelected(this.statementId);

  @override
  List<Object?> get props => [statementId];
}

class DriverEarningsDownloadPdfRequested extends DriverEarningsEvent {
  final String statementId;

  const DriverEarningsDownloadPdfRequested(this.statementId);

  @override
  List<Object?> get props => [statementId];
}

class DriverEarningsBackToOverviewPressed extends DriverEarningsEvent {
  const DriverEarningsBackToOverviewPressed();
}

class DriverEarningsStateForced extends DriverEarningsEvent {
  final DriverEarningsStatus status;

  const DriverEarningsStateForced(this.status);

  @override
  List<Object?> get props => [status];
}
