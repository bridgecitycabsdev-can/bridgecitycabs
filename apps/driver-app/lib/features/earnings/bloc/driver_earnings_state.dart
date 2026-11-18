import 'package:equatable/equatable.dart';
import '../data/models/driver_bank_details.dart';
import '../data/models/driver_earnings_config.dart';
import '../data/models/driver_earnings_period.dart';
import '../data/models/driver_earnings_status.dart';
import '../data/models/driver_earnings_summary.dart';
import '../data/models/driver_payout_statement.dart';

class DriverEarningsState extends Equatable {
  final DriverEarningsStatus status;
  final int activeTabIndex;
  final DriverEarningsSummary summary;
  final DriverEarningsPeriod selectedPeriod;
  final String customStartDate;
  final String customEndDate;
  final bool isCustomRangeExpanded;
  final DriverBankDetails bankForm;
  final DriverPayoutStatement? activeStatement;
  final bool isActionLoading;
  final String? feedbackMessage;

  const DriverEarningsState({
    required this.status,
    this.activeTabIndex = 0,
    required this.summary,
    this.selectedPeriod = DriverEarningsPeriod.thisWeek,
    this.customStartDate = '10 Jun 2024',
    this.customEndDate = '24 Jun 2024',
    this.isCustomRangeExpanded = true,
    required this.bankForm,
    this.activeStatement,
    this.isActionLoading = false,
    this.feedbackMessage,
  });

  factory DriverEarningsState.initial() {
    return DriverEarningsState(
      status: DriverEarningsStatus.overview,
      activeTabIndex: 0,
      summary: DriverEarningsConfig.overviewPreset(),
      selectedPeriod: DriverEarningsPeriod.thisWeek,
      customStartDate: '10 Jun 2024',
      customEndDate: '24 Jun 2024',
      isCustomRangeExpanded: true,
      bankForm: DriverEarningsConfig.bankingFormPreset(),
      activeStatement: DriverEarningsConfig.statementDetailPreset(),
      isActionLoading: false,
      feedbackMessage: null,
    );
  }

  DriverEarningsState copyWith({
    DriverEarningsStatus? status,
    int? activeTabIndex,
    DriverEarningsSummary? summary,
    DriverEarningsPeriod? selectedPeriod,
    String? customStartDate,
    String? customEndDate,
    bool? isCustomRangeExpanded,
    DriverBankDetails? bankForm,
    DriverPayoutStatement? activeStatement,
    bool clearStatement = false,
    bool? isActionLoading,
    String? feedbackMessage,
  }) {
    return DriverEarningsState(
      status: status ?? this.status,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      summary: summary ?? this.summary,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      isCustomRangeExpanded:
          isCustomRangeExpanded ?? this.isCustomRangeExpanded,
      bankForm: bankForm ?? this.bankForm,
      activeStatement: clearStatement
          ? null
          : (activeStatement ?? this.activeStatement),
      isActionLoading: isActionLoading ?? this.isActionLoading,
      feedbackMessage: feedbackMessage,
    );
  }

  bool get isOverview => status == DriverEarningsStatus.overview;
  bool get isBankingForm => status == DriverEarningsStatus.bankingForm;
  bool get isStatementDetail => status == DriverEarningsStatus.statementDetail;
  bool get isPeriodFilterVisible =>
      status == DriverEarningsStatus.periodFilterSheet;

  @override
  List<Object?> get props => [
    status,
    activeTabIndex,
    summary,
    selectedPeriod,
    customStartDate,
    customEndDate,
    isCustomRangeExpanded,
    bankForm,
    activeStatement,
    isActionLoading,
    feedbackMessage,
  ];
}
