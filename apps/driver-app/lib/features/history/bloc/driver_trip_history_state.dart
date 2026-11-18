import 'package:equatable/equatable.dart';
import '../data/models/driver_trip_filter_period.dart';
import '../data/models/driver_trip_history_config.dart';
import '../data/models/driver_trip_history_status.dart';
import '../data/models/driver_trip_record.dart';

class DriverTripHistoryState extends Equatable {
  final DriverTripHistoryStatus status;
  final bool isOnline;
  final bool isOfflineWarningVisible;
  final bool isZeroActiveDispatches;
  final bool hasFilteredEmptyNotice;
  final String filteredPeriodNoticeText;
  final List<DriverTripRecord> trips;
  final DriverTripRecord? selectedTrip;
  final DriverTripFilterPeriod selectedPeriod;
  final String customStartDate;
  final String customEndDate;
  final bool isCustomRangeExpanded;
  final bool isSyncingRecent;
  final bool isActionLoading;
  final String? feedbackMessage;
  final bool shouldNavigateToDispatch;

  const DriverTripHistoryState({
    required this.status,
    this.isOnline = true,
    this.isOfflineWarningVisible = true,
    this.isZeroActiveDispatches = true,
    this.hasFilteredEmptyNotice = true,
    this.filteredPeriodNoticeText = 'May 2024. Try adjusting your filter.',
    this.trips = const [],
    this.selectedTrip,
    this.selectedPeriod = DriverTripFilterPeriod.thisWeek,
    this.customStartDate = '10 Jun 2024',
    this.customEndDate = '24 Jun 2024',
    this.isCustomRangeExpanded = true,
    this.isSyncingRecent = true,
    this.isActionLoading = false,
    this.feedbackMessage,
    this.shouldNavigateToDispatch = false,
  });

  factory DriverTripHistoryState.initial() {
    return DriverTripHistoryState(
      status: DriverTripHistoryStatus.gallery,
      isOnline: true,
      isOfflineWarningVisible: true,
      isZeroActiveDispatches: true,
      hasFilteredEmptyNotice: true,
      filteredPeriodNoticeText: 'May 2024. Try adjusting your filter.',
      trips: [
        DriverTripHistoryConfig.sampleCancelledTrip(),
      ],
      selectedTrip: DriverTripHistoryConfig.sampleCompletedTrip(),
      selectedPeriod: DriverTripFilterPeriod.thisWeek,
      customStartDate: '10 Jun 2024',
      customEndDate: '24 Jun 2024',
      isCustomRangeExpanded: true,
      isSyncingRecent: true,
      isActionLoading: false,
      feedbackMessage: null,
      shouldNavigateToDispatch: false,
    );
  }

  DriverTripHistoryState copyWith({
    DriverTripHistoryStatus? status,
    bool? isOnline,
    bool? isOfflineWarningVisible,
    bool? isZeroActiveDispatches,
    bool? hasFilteredEmptyNotice,
    String? filteredPeriodNoticeText,
    List<DriverTripRecord>? trips,
    DriverTripRecord? selectedTrip,
    DriverTripFilterPeriod? selectedPeriod,
    String? customStartDate,
    String? customEndDate,
    bool? isCustomRangeExpanded,
    bool? isSyncingRecent,
    bool? isActionLoading,
    String? feedbackMessage,
    bool? shouldNavigateToDispatch,
  }) {
    return DriverTripHistoryState(
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      isOfflineWarningVisible:
          isOfflineWarningVisible ?? this.isOfflineWarningVisible,
      isZeroActiveDispatches:
          isZeroActiveDispatches ?? this.isZeroActiveDispatches,
      hasFilteredEmptyNotice:
          hasFilteredEmptyNotice ?? this.hasFilteredEmptyNotice,
      filteredPeriodNoticeText:
          filteredPeriodNoticeText ?? this.filteredPeriodNoticeText,
      trips: trips ?? this.trips,
      selectedTrip: selectedTrip ?? this.selectedTrip,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      isCustomRangeExpanded:
          isCustomRangeExpanded ?? this.isCustomRangeExpanded,
      isSyncingRecent: isSyncingRecent ?? this.isSyncingRecent,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      feedbackMessage: feedbackMessage,
      shouldNavigateToDispatch:
          shouldNavigateToDispatch ?? this.shouldNavigateToDispatch,
    );
  }

  bool get isGallery => status == DriverTripHistoryStatus.gallery;
  bool get isTripDetail => status == DriverTripHistoryStatus.tripDetail;
  bool get isFilterSheetVisible =>
      status == DriverTripHistoryStatus.filterSheet;
  bool get isEmptyNoRides => status == DriverTripHistoryStatus.emptyNoRides;

  @override
  List<Object?> get props => [
    status,
    isOnline,
    isOfflineWarningVisible,
    isZeroActiveDispatches,
    hasFilteredEmptyNotice,
    filteredPeriodNoticeText,
    trips,
    selectedTrip,
    selectedPeriod,
    customStartDate,
    customEndDate,
    isCustomRangeExpanded,
    isSyncingRecent,
    isActionLoading,
    feedbackMessage,
    shouldNavigateToDispatch,
  ];
}
