import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/driver_trip_history_status.dart';
import '../../data/repositories/driver_trip_history_repository.dart';
import '../bloc/driver_trip_history_bloc.dart';
import '../bloc/driver_trip_history_event.dart';
import '../bloc/driver_trip_history_state.dart';
import 'widgets/driver_history_bottom_bar.dart';
import 'widgets/driver_history_detail_view.dart';
import 'widgets/driver_history_empty_today_card.dart';
import 'widgets/driver_history_filter_sheet.dart';
import 'widgets/driver_history_period_notice_card.dart';
import 'widgets/driver_history_qa_bar.dart';
import 'widgets/driver_history_skeleton_card.dart';
import 'widgets/driver_history_top_bar.dart';
import 'widgets/driver_history_trip_card.dart';

class DriverTripHistoryPage extends StatelessWidget {
  final DriverTripHistoryStatus initialStatus;
  final DriverTripHistoryRepository? repository;

  const DriverTripHistoryPage({
    super.key,
    this.initialStatus = DriverTripHistoryStatus.gallery,
    this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DriverTripHistoryBloc>(
      create: (_) => DriverTripHistoryBloc(
        repository: repository ?? FakeDriverTripHistoryRepository(),
      )..add(DriverTripHistoryStarted(initialStatus: initialStatus)),
      child: const _DriverTripHistoryContent(),
    );
  }
}

class _DriverTripHistoryContent extends StatelessWidget {
  const _DriverTripHistoryContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverTripHistoryBloc, DriverTripHistoryState>(
      listenWhen: (prev, curr) =>
          prev.feedbackMessage != curr.feedbackMessage &&
          curr.feedbackMessage != null,
      listener: (context, state) {
        if (state.feedbackMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.feedbackMessage!),
              duration: const Duration(seconds: 2),
              backgroundColor: const Color(0xFF222831),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        if (state.shouldNavigateToDispatch && context.mounted) {
          context.go('/home');
        }
      },
      builder: (context, state) {
        final bloc = context.read<DriverTripHistoryBloc>();

        Widget body;
        if (state.isTripDetail && state.selectedTrip != null) {
          body = DriverHistoryDetailView(
            trip: state.selectedTrip!,
            onBack: () =>
                bloc.add(const DriverTripHistoryBackToGalleryPressed()),
            onReportIssue: () => bloc.add(
              DriverTripHistoryIssueReported(state.selectedTrip!.id),
            ),
          );
        } else {
          body = Scaffold(
            backgroundColor: const Color(0xFFFBF8F8),
            body: SafeArea(
              child: Column(
                children: [
                  // Top Portal Bar & Yellow Offline Banner
                  DriverHistoryTopBar(
                    isOnline: state.isOnline,
                    showOfflineWarning: state.isOfflineWarningVisible,
                    onSyncRetry: () =>
                        bloc.add(const DriverTripHistorySyncRetryPressed()),
                    onProfileTap: () {
                      if (context.mounted) {
                        context.go('/profile');
                      }
                    },
                  ),

                  // Header row with Back, Title, and Filter button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF1E1E1E),
                            size: 22,
                          ),
                          onPressed: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            } else {
                              context.go('/home');
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'History & States',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E1E1E),
                                ),
                              ),
                              SizedBox(height: 1),
                              Text(
                                'Showcase & edge state gallery',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF757575),
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => bloc.add(
                            const DriverTripHistoryFilterRequested(),
                          ),
                          icon: const Icon(
                            Icons.calendar_month_outlined,
                            size: 15,
                            color: Color(0xFF424242),
                          ),
                          label: const Text(
                            'Filter',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF424242),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE0E0E0)),
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quick Action Chips Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        ActionChip(
                          avatar: const Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: Color(0xFFB71C1C),
                          ),
                          label: const Text(
                            'Demo Fare Modal',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB71C1C),
                            ),
                          ),
                          backgroundColor: const Color(0xFFFFEBEE),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          onPressed: () => bloc.add(
                            const DriverTripHistoryTripSelected('BC-123456'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ActionChip(
                          avatar: const Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: Color(0xFF424242),
                          ),
                          label: const Text(
                            'Demo Date Picker',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF424242),
                            ),
                          ),
                          backgroundColor: const Color(0xFFF5F5F5),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          onPressed: () => bloc.add(
                            const DriverTripHistoryFilterRequested(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Scrollable Content
                  Expanded(
                    child: Stack(
                      children: [
                        RefreshIndicator(
                          onRefresh: () async {
                            bloc.add(const DriverTripHistoryFilterApplied());
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Edge State 1: Zero Active Dispatches / No rides for today
                                if (state.isZeroActiveDispatches) ...[
                                  DriverHistoryEmptyTodayCard(
                                    onGoOnline: () => bloc.add(
                                      const DriverTripHistoryGoOnlinePressed(),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                ],

                                // Edge State 2: No rides found in selected period notice
                                if (state.hasFilteredEmptyNotice) ...[
                                  DriverHistoryPeriodNoticeCard(
                                    periodText: state.filteredPeriodNoticeText,
                                    onChange: () => bloc.add(
                                      const DriverTripHistoryFilterRequested(),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                ],

                                // Trips List (Cancelled & Completed)
                                ...state.trips.map(
                                  (trip) => DriverHistoryTripCard(
                                    trip: trip,
                                    onViewDetails: () => bloc.add(
                                      DriverTripHistoryTripSelected(trip.id),
                                    ),
                                  ),
                                ),

                                // Syncing Recent Trips Skeleton Section
                                if (state.isSyncingRecent) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'RECENT TRIPS (SYNCING)',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF616161),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFC62828),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'Fetching records',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFFC62828),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const DriverHistorySkeletonCard(),
                                  const DriverHistorySkeletonCard(),
                                ],
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),

                        // Filter Modal Sheet Overlay
                        if (state.isFilterSheetVisible) ...[
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: () => bloc.add(
                                const DriverTripHistoryFilterDismissed(),
                              ),
                              child: Container(
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: DriverHistoryFilterSheet(
                              selectedPeriod: state.selectedPeriod,
                              customStartDate: state.customStartDate,
                              customEndDate: state.customEndDate,
                              isCustomExpanded: state.isCustomRangeExpanded,
                              onPeriodSelected: (period) => bloc.add(
                                DriverTripHistoryPeriodSelected(period),
                              ),
                              onStartDateChanged: (start) => bloc.add(
                                DriverTripHistoryCustomRangeConfigured(
                                  startDate: start,
                                  endDate: state.customEndDate,
                                ),
                              ),
                              onEndDateChanged: (end) => bloc.add(
                                DriverTripHistoryCustomRangeConfigured(
                                  startDate: state.customStartDate,
                                  endDate: end,
                                ),
                              ),
                              onApply: () => bloc.add(
                                const DriverTripHistoryFilterApplied(),
                              ),
                              onClose: () => bloc.add(
                                const DriverTripHistoryFilterDismissed(),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Bottom Navigation Bar
                  DriverHistoryBottomBar(
                    activeIndex: 2,
                    onIndexChanged: (index) {
                      switch (index) {
                        case 0:
                          context.go('/home');
                          break;
                        case 1:
                          context.go('/earnings');
                          break;
                        case 2:
                          // Current page
                          break;
                        case 3:
                          context.go('/profile');
                          break;
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            // Top QA Switcher Bar
            DriverHistoryQABar(
              currentStatus: state.status,
              onStatusSelected: (status) =>
                  bloc.add(DriverTripHistoryStateForced(status)),
            ),
            Expanded(child: body),
          ],
        );
      },
    );
  }
}
