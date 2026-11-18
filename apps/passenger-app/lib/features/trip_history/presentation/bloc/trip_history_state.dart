import 'package:equatable/equatable.dart';
import '../../data/models/trip_history_config.dart';
import '../../data/models/trip_history_model.dart';

enum TripHistoryStatus {
  initial,
  loading,
  loaded,
  downloadingReceipt,
  downloadSuccess,
  error,
}

class TripHistoryState extends Equatable {
  final TripHistoryStatus status;
  final TripPaymentScenario selectedScenario;
  final TripRecord lastTrip;
  final TripRecord? activeTrip;
  final bool isDownloadingReceipt;
  final String? feedbackMessage;
  final String? errorMessage;

  // Fields for Full Trip History & Filter Screens
  final TripHistoryFilter activeFilter;
  final List<GroupedTripDate> groupedTrips;
  final TripSummaryData tripSummary;
  final TripRecord? selectedTripForActions;
  final bool isQuickActionsOpen;
  final bool isDateRangeFilterOpen;
  final CustomDateRange? customDateRange;
  final int qaStateIndex;
  final bool isLiveTripActive;
  final bool isLoadingMore;

  const TripHistoryState({
    this.status = TripHistoryStatus.initial,
    this.selectedScenario = TripPaymentScenario.cardPaid,
    this.lastTrip = TripHistoryConfig.defaultLastTrip,
    this.activeTrip,
    this.isDownloadingReceipt = false,
    this.feedbackMessage,
    this.errorMessage,
    this.activeFilter = TripHistoryFilter.thisMonth,
    this.groupedTrips = const [],
    this.tripSummary = TripHistoryConfig.defaultSummary,
    this.selectedTripForActions,
    this.isQuickActionsOpen = false,
    this.isDateRangeFilterOpen = false,
    this.customDateRange,
    this.qaStateIndex = 1,
    this.isLiveTripActive = false,
    this.isLoadingMore = false,
  });

  bool get isLoading => status == TripHistoryStatus.loading;
  bool get hasLastTrip => true;

  bool get isCardPaid => selectedScenario == TripPaymentScenario.cardPaid;
  bool get isCashPaid => selectedScenario == TripPaymentScenario.cashPaid;
  bool get isCashPending => selectedScenario == TripPaymentScenario.cashPending;

  TripRecord get currentTrip => activeTrip ?? lastTrip;

  TripHistoryState copyWith({
    TripHistoryStatus? status,
    TripPaymentScenario? selectedScenario,
    TripRecord? lastTrip,
    TripRecord? Function()? activeTrip,
    bool? isDownloadingReceipt,
    String? Function()? feedbackMessage,
    String? Function()? errorMessage,
    TripHistoryFilter? activeFilter,
    List<GroupedTripDate>? groupedTrips,
    TripSummaryData? tripSummary,
    TripRecord? Function()? selectedTripForActions,
    bool? isQuickActionsOpen,
    bool? isDateRangeFilterOpen,
    CustomDateRange? Function()? customDateRange,
    int? qaStateIndex,
    bool? isLiveTripActive,
    bool? isLoadingMore,
  }) {
    return TripHistoryState(
      status: status ?? this.status,
      selectedScenario: selectedScenario ?? this.selectedScenario,
      lastTrip: lastTrip ?? this.lastTrip,
      activeTrip: activeTrip != null ? activeTrip() : this.activeTrip,
      isDownloadingReceipt: isDownloadingReceipt ?? this.isDownloadingReceipt,
      feedbackMessage: feedbackMessage != null ? feedbackMessage() : this.feedbackMessage,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      activeFilter: activeFilter ?? this.activeFilter,
      groupedTrips: groupedTrips ?? this.groupedTrips,
      tripSummary: tripSummary ?? this.tripSummary,
      selectedTripForActions: selectedTripForActions != null
          ? selectedTripForActions()
          : this.selectedTripForActions,
      isQuickActionsOpen: isQuickActionsOpen ?? this.isQuickActionsOpen,
      isDateRangeFilterOpen: isDateRangeFilterOpen ?? this.isDateRangeFilterOpen,
      customDateRange: customDateRange != null ? customDateRange() : this.customDateRange,
      qaStateIndex: qaStateIndex ?? this.qaStateIndex,
      isLiveTripActive: isLiveTripActive ?? this.isLiveTripActive,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedScenario,
        lastTrip,
        activeTrip,
        isDownloadingReceipt,
        feedbackMessage,
        errorMessage,
        activeFilter,
        groupedTrips,
        tripSummary,
        selectedTripForActions,
        isQuickActionsOpen,
        isDateRangeFilterOpen,
        customDateRange,
        qaStateIndex,
        isLiveTripActive,
        isLoadingMore,
      ];
}
