import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/driver_reviews_status.dart';
import '../../data/repositories/driver_reviews_repository.dart';
import '../bloc/driver_reviews_bloc.dart';
import '../bloc/driver_reviews_event.dart';
import '../bloc/driver_reviews_state.dart';
import 'widgets/driver_rating_summary_card.dart';
import 'widgets/driver_review_card.dart';
import 'widgets/driver_review_detail_modal.dart';
import 'widgets/driver_review_filter_chips.dart';
import 'widgets/driver_reviews_edge_cards.dart';
import 'widgets/driver_reviews_offline_banner.dart';
import 'widgets/driver_reviews_qa_bar.dart';
import 'widgets/driver_reviews_tip_card.dart';

class DriverReviewsPage extends StatelessWidget {
  final DriverReviewsStatus initialStatus;
  final DriverReviewsRepository? repository;

  const DriverReviewsPage({
    super.key,
    this.initialStatus = DriverReviewsStatus.list,
    this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DriverReviewsBloc>(
      create: (_) => DriverReviewsBloc(
        repository: repository ?? FakeDriverReviewsRepository(),
      )..add(DriverReviewsStarted(initialStatus: initialStatus)),
      child: const _DriverReviewsContent(),
    );
  }
}

class _DriverReviewsContent extends StatelessWidget {
  const _DriverReviewsContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverReviewsBloc, DriverReviewsState>(
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
        final bloc = context.read<DriverReviewsBloc>();
        final isEdgeGallery = state.isEdgeStatesGallery ||
            state.isNoMatchingFilter ||
            state.isNewDriverEmpty ||
            state.isServiceFailure;

        final title = isEdgeGallery ? 'Driver Reviews States' : 'Driver Reviews List';

        return Column(
          children: [
            // Top QA Switcher Bar
            DriverReviewsQABar(
              currentStatus: state.status,
              onStatusSelected: (status) =>
                  bloc.add(DriverReviewsStateForced(status)),
            ),

            Expanded(
              child: Scaffold(
                backgroundColor: const Color(0xFFFBF8F8),
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        context.go('/profile');
                      }
                    },
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: false,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: GestureDetector(
                        onTap: () {
                          if (context.mounted) {
                            context.go('/profile');
                          }
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFF8B0000),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                body: Stack(
                  children: [
                    Column(
                      children: [
                        // Offline Warning Banner
                        if (state.isOfflineWarningVisible)
                          DriverReviewsOfflineBanner(
                            onRetry: () =>
                                bloc.add(const DriverReviewsSyncRetryPressed()),
                          ),

                        // Main Content
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              bloc.add(const DriverReviewsFilterReset());
                            },
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: isEdgeGallery
                                  ? DriverReviewsEdgeCards(
                                      activeInspectorIndex:
                                          state.isNoMatchingFilter
                                              ? 1
                                              : state.isNewDriverEmpty
                                                  ? 2
                                                  : state.isServiceFailure
                                                      ? 3
                                                      : state.inspectorTabIndex,
                                      onInspectorTabChanged: (index) =>
                                          bloc.add(
                                        DriverReviewsInspectorTabSwitched(
                                          index,
                                        ),
                                      ),
                                      onResetFilter: () => bloc.add(
                                        const DriverReviewsFilterReset(),
                                      ),
                                      onGoOnline: () => bloc.add(
                                        const DriverReviewsGoOnlinePressed(),
                                      ),
                                      onRetry: () => bloc.add(
                                        const DriverReviewsSyncRetryPressed(),
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // Hero Rating & Breakdown Card
                                        DriverRatingSummaryCard(
                                          distribution: state.distribution,
                                        ),
                                        const SizedBox(height: 16),

                                        // Filter Chips
                                        DriverReviewFilterChips(
                                          selectedFilter: state.selectedFilter,
                                          distribution: state.distribution,
                                          onFilterSelected: (filter) =>
                                              bloc.add(
                                            DriverReviewsFilterStarSelected(
                                              filter,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Reviews List
                                        ...state.reviews.map(
                                          (review) => DriverReviewCard(
                                            review: review,
                                            onTap: () => bloc.add(
                                              DriverReviewsReviewSelected(
                                                review.id,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 12),

                                        // Pro Tip Box
                                        const DriverReviewsTipCard(),
                                        const SizedBox(height: 24),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Detail / Report Modal Bottom Sheet Overlay
                    if (state.isDetailModalVisible &&
                        state.selectedReview != null) ...[
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () =>
                              bloc.add(const DriverReviewsModalDismissed()),
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: DriverReviewDetailModal(
                          review: state.selectedReview!,
                          onReport: () => bloc.add(
                            DriverReviewsReportReviewPressed(
                              state.selectedReview!.id,
                            ),
                          ),
                          onClose: () =>
                              bloc.add(const DriverReviewsModalDismissed()),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
