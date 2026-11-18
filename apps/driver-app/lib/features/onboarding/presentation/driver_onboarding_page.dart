import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/driver_onboarding_bloc.dart';
import '../bloc/driver_onboarding_event.dart';
import '../bloc/driver_onboarding_state.dart';
import '../data/models/driver_onboarding_step.dart';
import 'widgets/driver_earnings_preview_card.dart';
import 'widgets/driver_onboarding_bottom_card.dart';
import 'widgets/driver_onboarding_header.dart';
import 'widgets/driver_onboarding_map_background.dart';
import 'widgets/driver_onboarding_qa_matrix_bar.dart';
import 'widgets/driver_ride_request_card.dart';
import 'widgets/driver_support_compliance_card.dart';

class DriverOnboardingPage extends StatelessWidget {
  final int initialIndex;
  final bool showQaToolbar;

  const DriverOnboardingPage({
    super.key,
    this.initialIndex = 0,
    this.showQaToolbar = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverOnboardingBloc()
        ..add(DriverOnboardingStarted(initialIndex: initialIndex)),
      child: DriverOnboardingView(
        initialIndex: initialIndex,
        showQaToolbar: showQaToolbar,
      ),
    );
  }
}

class DriverOnboardingView extends StatefulWidget {
  final int initialIndex;
  final bool showQaToolbar;

  const DriverOnboardingView({
    super.key,
    required this.initialIndex,
    required this.showQaToolbar,
  });

  @override
  State<DriverOnboardingView> createState() => _DriverOnboardingViewState();
}

class _DriverOnboardingViewState extends State<DriverOnboardingView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _syncPage(int index) {
    if (_pageController.hasClients && _pageController.page?.round() != index) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverOnboardingBloc, DriverOnboardingState>(
      listenWhen: (previous, current) =>
          previous.currentIndex != current.currentIndex ||
          previous.navigateToPhone != current.navigateToPhone ||
          previous.feedbackMessage != current.feedbackMessage,
      listener: (context, state) {
        _syncPage(state.currentIndex);

        if (state.feedbackMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.feedbackMessage!),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF1F2937),
            ),
          );
        }

        if (state.navigateToPhone) {
          context.go('/phone');
        }
      },
      builder: (context, state) {
        final currentStep = state.currentStep;

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: Stack(
            children: [
              // 1. Dynamic Map Grid & Routes Background
              DriverOnboardingMapBackground(step: currentStep.step),

              // 2. Foreground UI
              SafeArea(
                child: Column(
                  children: [
                    // QA Matrix Bar for fast switching
                    if (widget.showQaToolbar)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                        child: DriverOnboardingQaMatrixBar(
                          currentIndex: state.currentIndex,
                          isSubmitting: state.isSubmitting,
                          onSelectState: (index, submitting) {
                            _pageController.jumpToPage(index);
                            context.read<DriverOnboardingBloc>().add(
                                  DriverOnboardingStepSwitched(
                                    index,
                                    isSubmitting: submitting,
                                  ),
                                );
                          },
                        ),
                      ),

                    // Top Bar: Driver Badge, Online Status, Skip Button
                    DriverOnboardingHeader(
                      step: currentStep.step,
                      onSkip: () {
                        context
                            .read<DriverOnboardingBloc>()
                            .add(const DriverOnboardingSkipTapped());
                      },
                    ),

                    // Middle Section: Carousel / PageView of Cards
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          context
                              .read<DriverOnboardingBloc>()
                              .add(DriverOnboardingPageChanged(index));
                        },
                        children: [
                          // Slide 1: Ride Request preview card
                          Center(
                            child: SingleChildScrollView(
                              child: DriverRideRequestCard(
                                mock: state.rideRequest,
                                onAccept: () {
                                  context.read<DriverOnboardingBloc>().add(
                                        const DriverOnboardingNextTapped(),
                                      );
                                },
                                onDecline: () {},
                              ),
                            ),
                          ),

                          // Slide 2: Earnings preview stacked cards
                          Center(
                            child: SingleChildScrollView(
                              child: DriverEarningsPreviewCard(
                                mock: state.earnings,
                              ),
                            ),
                          ),

                          // Slide 3 & 4: Support & Compliance card
                          Center(
                            child: SingleChildScrollView(
                              child: DriverSupportComplianceCard(
                                mock: state.profileCompliance,
                                isSubmitting: state.isSubmitting,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom Sheet: Category Tag, Title, Description, Dots, Action Button
                    DriverOnboardingBottomCard(
                      stepData: currentStep,
                      totalSteps: state.steps.length,
                      isSubmitting: state.isSubmitting,
                      onNext: () {
                        context
                            .read<DriverOnboardingBloc>()
                            .add(const DriverOnboardingNextTapped());
                      },
                      onGetStarted: () {
                        context
                            .read<DriverOnboardingBloc>()
                            .add(const DriverOnboardingGetStartedTapped());
                      },
                      onLogin: () {
                        context
                            .read<DriverOnboardingBloc>()
                            .add(const DriverOnboardingLoginTapped());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
