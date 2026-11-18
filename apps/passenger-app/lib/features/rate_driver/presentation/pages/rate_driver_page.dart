import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/rate_driver_bloc.dart';
import '../bloc/rate_driver_event.dart';
import '../bloc/rate_driver_state.dart';
import '../../data/models/rate_driver_models.dart';
import '../../data/repositories/rate_driver_repository.dart';
import '../widgets/rating_already_rated_view.dart';
import '../widgets/rating_comment_box.dart';
import '../widgets/rating_driver_hero.dart';
import '../widgets/rating_expired_view.dart';
import '../widgets/rating_guarantee_card.dart';
import '../widgets/rating_header_app_bar.dart';
import '../widgets/rating_stars_bar.dart';
import '../widgets/rating_success_view.dart';
import '../widgets/rating_sync_banner.dart';
import '../widgets/rating_tag_chips_selector.dart';
import '../widgets/rating_trip_preview_card.dart';

class RateDriverPage extends StatelessWidget {
  final DriverRatingProfile? driverProfile;
  final TripSummaryInfo? tripInfo;
  final RateDriverStatus? initialStatus;
  final int? initialStars;
  final List<RatingTag>? initialTags;
  final String? initialComment;
  final RateDriverRepository? repository;

  const RateDriverPage({
    super.key,
    this.driverProfile,
    this.tripInfo,
    this.initialStatus,
    this.initialStars,
    this.initialTags,
    this.initialComment,
    this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RateDriverBloc(
        repository: repository ?? MockRateDriverRepository(),
      )..add(RateDriverStarted(
          driverProfile: driverProfile,
          tripInfo: tripInfo,
          initialStatus: initialStatus,
          initialStars: initialStars,
          initialTags: initialTags,
          initialComment: initialComment,
        )),
      child: const _RateDriverView(),
    );
  }
}

class _RateDriverView extends StatelessWidget {
  const _RateDriverView();

  void _showReportProblemSheet(BuildContext context, String tripId) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Report Trip Issue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(sheetCtx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Lethbridge Dispatch Support: 403-328-8888\nAll past bookings and GPS telemetry are archived for safety and compliance review.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(sheetCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Support ticket created. An agent will contact you.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF991B1B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Contact Support Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RateDriverBloc, RateDriverState>(
      listener: (context, state) {
        if (state.navigateToHome) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        } else if (state.navigateToReceipt) {
          context.go('/receipt');
        } else if (state.showReportIssueSheet) {
          _showReportProblemSheet(context, state.trip.tripId);
        }

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: const Color(0xFFB91C1C),
            ),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<RateDriverBloc>();

        final showSkip = state.status != RateDriverStatus.success &&
            state.status != RateDriverStatus.alreadyRated &&
            state.status != RateDriverStatus.windowExpired;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: RatingHeaderAppBar(
            onClose: () => bloc.add(const RateDriverSkipTapped()),
            onSkip: () => bloc.add(const RateDriverSkipTapped()),
            showSkip: showSkip,
            isSubmitting: state.isSubmitting,
          ),
          body: _buildBody(context, state, bloc),
          bottomNavigationBar: _buildBottomBar(context, state, bloc),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    RateDriverState state,
    RateDriverBloc bloc,
  ) {
    if (state.status == RateDriverStatus.success) {
      return RatingSuccessView(
        driver: state.driver,
        rating: state.selectedStars,
        tags: state.selectedTags,
        onBackToHome: () => bloc.add(const RateDriverBackToHomeTapped()),
      );
    }

    if (state.status == RateDriverStatus.alreadyRated) {
      return RatingAlreadyRatedView(
        driver: state.driver,
        trip: state.trip,
        onBackToReceipt: () => bloc.add(const RateDriverBackToReceiptTapped()),
      );
    }

    if (state.status == RateDriverStatus.windowExpired) {
      return RatingExpiredView(
        driver: state.driver,
        trip: state.trip,
        onReportIssue: () => bloc.add(const RateDriverReportIssueTapped()),
        onDone: () => bloc.add(const RateDriverBackToHomeTapped()),
      );
    }

    // Interactive review form (Screen 1, Screen 2, Screen 3, Screen 5)
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            // Driver avatar & header
            RatingDriverHero(
              driver: state.driver,
              showRatingBadge: state.selectedStars <= 2 && state.selectedStars > 0,
              fleetTag: state.status == RateDriverStatus.submitting
                  ? 'Bridge City Cab #42 • Silver Camry'
                  : null,
            ),
            const SizedBox(height: 16),

            // 5 Stars Bar
            RatingStarsBar(
              selectedStars: state.selectedStars,
              sentimentLabel: state.sentimentLabel,
              onStarsSelected: (stars) => bloc.add(RateDriverStarsSelected(stars)),
              isInteractive: !state.isSubmitting,
            ),
            const SizedBox(height: 20),

            // Tag chips selector (dynamic based on stars: What went wrong vs What went well)
            if (state.selectedStars > 0) ...[
              RatingTagChipsSelector(
                title: state.tagsSectionTitle,
                subtitle: state.tagsSectionSubtitle,
                availableTags: state.availableTags,
                selectedTags: state.selectedTags,
                onTagToggled: (tag) => bloc.add(RateDriverTagToggled(tag)),
                isInteractive: !state.isSubmitting,
              ),
              const SizedBox(height: 16),
            ],

            // Comment Box
            RatingCommentBox(
              comment: state.comment,
              onCommentChanged: (text) => bloc.add(RateDriverCommentChanged(text)),
              isSubmitting: state.isSubmitting,
              title: state.selectedStars == 0 ? 'Leave a note' : null,
              hintText: state.selectedStars >= 3
                  ? 'Add a personal note (optional)'
                  : 'Add a comment (optional)',
            ),
            const SizedBox(height: 16),

            // Low rating guarantee card
            if (state.isLowRating) ...[
              const RatingGuaranteeCard(),
              const SizedBox(height: 16),
            ],

            // High rating trip preview
            if (state.isHighRating) ...[
              RatingTripPreviewCard(
                trip: state.trip,
                driver: state.driver,
              ),
              const SizedBox(height: 16),
            ],

            // Submitting state banner
            if (state.status == RateDriverStatus.submitting) ...[
              const RatingSyncBanner(),
              const SizedBox(height: 16),
            ],

            // Optional note on trip ID
            if (state.selectedStars == 0) ...[
              Text(
                'Trip ID: #${state.trip.tripId} • ${state.trip.transitZone}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget? _buildBottomBar(
    BuildContext context,
    RateDriverState state,
    RateDriverBloc bloc,
  ) {
    if (state.status == RateDriverStatus.success ||
        state.status == RateDriverStatus.alreadyRated ||
        state.status == RateDriverStatus.windowExpired) {
      return null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFE2E8F0).withValues(alpha: 0.8)),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: state.canSubmit
                ? () => bloc.add(const RateDriverReviewSubmitted())
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
              disabledBackgroundColor: const Color(0xFFB91C1C).withValues(alpha: 0.4),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: state.isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Submit Review',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
