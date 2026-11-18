import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../../data/models/onboarding_step_data.dart';
import '../../data/repositories/onboarding_repository.dart';
import '../widgets/onboarding_bottom_card.dart';
import '../widgets/onboarding_header.dart';
import '../widgets/onboarding_map_background.dart';
import '../widgets/ride_tier_card.dart';
import '../widgets/safety_badges_overlay.dart';
import '../widgets/schedule_transfer_overlay.dart';

/// Entry widget providing the Onboarding experience with [OnboardingBloc].
class OnboardingPage extends StatelessWidget {
  final OnboardingRepository? repository;

  const OnboardingPage({
    super.key,
    this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc(
        repository: repository ?? OnboardingRepositoryImpl(),
      )..add(const OnboardingStarted()),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state.shouldNavigate) {
          context.go(state.targetRoute!);
        } else if (_pageController.hasClients &&
            _pageController.page?.round() != state.pageIndex) {
          _pageController.animateToPage(
            state.pageIndex,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOut,
          );
        }
      },
      builder: (context, state) {
        final stepData = state.currentStepData;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: const Color(0xFFF4F6F2),
            body: Stack(
              children: [
                // 1. Lethbridge Vector Map Background
                OnboardingMapBackground(stepIndex: state.pageIndex),

                // 2. Main Content inside SafeArea
                SafeArea(
                  child: Column(
                    children: [
                      // Top Header Bar
                      OnboardingHeader(
                        locationText: stepData.headerLocation,
                        onSkip: () {
                          context
                              .read<OnboardingBloc>()
                              .add(const OnboardingSkipTapped());
                        },
                      ),

                      // Middle Illustration / Overlay Area
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: OnboardingStepData.steps.length,
                          onPageChanged: (index) {
                            context
                                .read<OnboardingBloc>()
                                .add(OnboardingPageChanged(index));
                          },
                          itemBuilder: (context, index) {
                            return Center(
                              child: _buildStepOverlay(
                                context: context,
                                index: index,
                                state: state,
                              ),
                            );
                          },
                        ),
                      ),

                      // 3. Bottom White Sheet Card
                      OnboardingBottomCard(
                        stepData: stepData,
                        onNext: () {
                          context
                              .read<OnboardingBloc>()
                              .add(const OnboardingNextTapped());
                        },
                        onGetStarted: () {
                          context
                              .read<OnboardingBloc>()
                              .add(const OnboardingGetStartedTapped());
                        },
                        onSignIn: () {
                          context
                              .read<OnboardingBloc>()
                              .add(const OnboardingSignInTapped());
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepOverlay({
    required BuildContext context,
    required int index,
    required OnboardingState state,
  }) {
    switch (index) {
      case 0:
        return RideTierCardsSection(
          selectedTier: state.selectedTier,
          onTierSelected: (tier) {
            context
                .read<OnboardingBloc>()
                .add(OnboardingTierSelected(tier));
          },
        );
      case 1:
        return const ScheduleTransferOverlay();
      case 2:
        return const SafetyBadgesOverlay();
      default:
        return const SizedBox.shrink();
    }
  }
}
