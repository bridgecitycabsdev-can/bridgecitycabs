import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/trip_history_bloc.dart';
import '../bloc/trip_history_event.dart';
import '../bloc/trip_history_state.dart';
import '../../data/models/trip_history_config.dart';
import '../../data/models/trip_history_model.dart';
import '../../data/repositories/trip_history_repository.dart';
import '../widgets/trips_list_app_bar.dart';
import '../widgets/trips_summary_header.dart';
import '../widgets/trips_date_filter_chips.dart';
import '../widgets/trip_history_item_card.dart';
import '../widgets/trip_quick_actions_sheet.dart';
import '../widgets/trip_date_range_filter_sheet.dart';
import '../widgets/trip_live_banner.dart';

class TripsHistoryHubPage extends StatelessWidget {
  final TripHistoryRepository? repository;
  final VoidCallback? onBack;

  const TripsHistoryHubPage({
    super.key,
    this.repository,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TripHistoryBloc(
        repository: repository ?? MockTripHistoryRepository(),
      )..add(const TripHistoryStarted()),
      child: TripsHistoryHubView(onBack: onBack),
    );
  }
}

class TripsHistoryHubView extends StatelessWidget {
  final VoidCallback? onBack;

  const TripsHistoryHubView({
    super.key,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TripHistoryBloc, TripHistoryState>(
      listener: (context, state) {
        if (state.feedbackMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.feedbackMessage!),
              duration: const Duration(seconds: 2),
              backgroundColor: const Color(0xFF1F2937),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: TripsListAppBar(
            onBack: () {
              if (onBack != null) {
                onBack!();
              } else {
                Navigator.of(context).maybePop();
              }
            },
            onCalendarTapped: () {
              context.read<TripHistoryBloc>().add(const TripHistoryCalendarTapped());
            },
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  // Optional live trip banner (as shown in Screen 3 background)
                  if (state.isLiveTripActive)
                    TripLiveBanner(
                      onTap: () {
                        context.read<TripHistoryBloc>().add(
                              const TripHistoryQaStateChanged(1),
                            );
                      },
                    ),

                  // Main scrollable list with pull-to-refresh
                  Expanded(
                    child: RefreshIndicator(
                      color: const Color(0xFFDC2626),
                      onRefresh: () async {
                        context.read<TripHistoryBloc>().add(const TripHistoryRefreshTriggered());
                        await Future.delayed(const Duration(milliseconds: 300));
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Pull to refresh hint
                            const Center(
                              child: Text(
                                '↓ Pull to refresh',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9CA3AF),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Date Filter Chips
                            TripsDateFilterChips(
                              selectedFilter: state.activeFilter,
                              onFilterSelected: (filter) {
                                context.read<TripHistoryBloc>().add(TripHistoryFilterSelected(filter));
                              },
                            ),
                            const SizedBox(height: 12),

                            // Trips Summary Header (Trips: 4, Total spent: $82.40 CAD)
                            TripsSummaryHeader(summary: state.tripSummary),
                            const SizedBox(height: 16),

                            // Grouped trips list
                            ...state.groupedTrips.map((group) => _buildGroupSection(context, group)),

                            const SizedBox(height: 16),

                            // Loading more trips...
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      state.isLoadingMore ? const Color(0xFFDC2626) : const Color(0xFFEF4444),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Loading more trips...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Bylaw Footer
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shield_outlined, size: 14, color: Color(0xFF9CA3AF)),
                                SizedBox(width: 6),
                                Text(
                                  TripHistoryConfig.bylawShortNotice,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF9CA3AF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Modal Sheet 1: Trip Quick Actions (Screen 2)
              if (state.isQuickActionsOpen && state.selectedTripForActions != null)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: TripQuickActionsSheet(
                        trip: state.selectedTripForActions!,
                        onViewReceipt: () {
                          context.read<TripHistoryBloc>().add(
                                TripHistoryDownloadReceiptTapped(state.selectedTripForActions!.tripId),
                              );
                        },
                        onReportProblem: () {
                          context.read<TripHistoryBloc>().add(
                                TripHistoryReportProblemTapped(state.selectedTripForActions!.tripId),
                              );
                        },
                        onRateDriver: () {
                          context.read<TripHistoryBloc>().add(
                                TripHistoryRateDriverTapped(state.selectedTripForActions!.tripId),
                              );
                        },
                        onClose: () {
                          context.read<TripHistoryBloc>().add(const TripHistoryQuickActionsClosed());
                        },
                      ),
                    ),
                  ),
                ),

              // Modal Sheet 2: Date Range Filter (Screen 3)
              if (state.isDateRangeFilterOpen)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: TripDateRangeFilterSheet(
                        initialStart: state.customDateRange?.startDate ?? DateTime(2026, 8, 15),
                        initialEnd: state.customDateRange?.endDate ?? DateTime(2026, 8, 22),
                        onApplyRange: (start, end) {
                          context.read<TripHistoryBloc>().add(
                                TripHistoryCustomDateRangeApplied(startDate: start, endDate: end),
                              );
                        },
                        onReset: () {
                          context.read<TripHistoryBloc>().add(
                                const TripHistoryFilterSelected(TripHistoryFilter.today),
                              );
                          context.read<TripHistoryBloc>().add(
                                const TripHistoryDateRangeFilterClosed(),
                              );
                        },
                        onClose: () {
                          context.read<TripHistoryBloc>().add(
                                const TripHistoryDateRangeFilterClosed(),
                              );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupSection(BuildContext context, GroupedTripDate group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Text(
            group.dateHeader,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ),
        ...group.trips.map(
          (trip) => TripHistoryItemCard(
            trip: trip,
            onTap: () {
              context.read<TripHistoryBloc>().add(TripHistoryCardTapped(trip));
            },
          ),
        ),
      ],
    );
  }
}
