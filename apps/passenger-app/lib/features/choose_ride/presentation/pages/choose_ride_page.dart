import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/choose_ride_bloc.dart';
import '../bloc/choose_ride_event.dart';
import '../bloc/choose_ride_state.dart';
import '../../data/models/choose_ride_config.dart';
import '../../data/models/choose_ride_qa_scenario.dart';
import '../../data/models/promo_code.dart';
import '../../data/repositories/choose_ride_repository.dart';
import '../widgets/choose_ride_app_bar.dart';
import '../widgets/choose_ride_bottom_bar.dart';
import '../widgets/choose_ride_header.dart';
import '../widgets/choose_ride_map_view.dart';
import '../widgets/demo_state_bar.dart';
import '../widgets/payment_account_row.dart';
import '../widgets/promo_applied_card.dart';
import '../widgets/promo_input_section.dart';
import '../widgets/promo_teaser_card.dart';
import '../widgets/promo_terms_modal_sheet.dart';
import '../widgets/qa_promo_inspector_bar.dart';
import '../widgets/quote_expiring_banner.dart';
import '../widgets/ride_preferences_section.dart';
import '../widgets/ride_tier_card.dart';
import '../widgets/ride_tier_skeleton.dart';

class ChooseRidePage extends StatelessWidget {
  final ChooseRideRepository? repository;
  final ChooseRideBloc? bloc;
  final bool simulateUnavailable;
  final bool isExpiring;
  final PromoCode? initialPromo;
  final QaPromoScenario? initialQaScenario;
  final ChooseRideDemoState? initialDemoState;
  final bool isInspectorMode;

  const ChooseRidePage({
    super.key,
    this.repository,
    this.bloc,
    this.simulateUnavailable = false,
    this.isExpiring = false,
    this.initialPromo,
    this.initialQaScenario,
    this.initialDemoState,
    this.isInspectorMode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider.value(
        value: bloc!,
        child: const _ChooseRideView(),
      );
    }

    return BlocProvider(
      create: (context) => ChooseRideBloc(
        repository: repository ?? ChooseRideRepositoryImpl(),
      )..add(ChooseRideStarted(
          simulateUnavailable: simulateUnavailable,
          isExpiring: isExpiring,
          initialPromo: initialPromo,
          initialQaScenario: initialQaScenario,
          initialDemoState: initialDemoState,
          isInspectorMode: isInspectorMode,
        )),
      child: const _ChooseRideView(),
    );
  }
}

class _ChooseRideView extends StatelessWidget {
  const _ChooseRideView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChooseRideBloc, ChooseRideState>(
      listener: (context, state) {
        if (state.feedbackMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.feedbackMessage!),
              duration: const Duration(seconds: 2),
            ),
          );
        }

        if (state.targetRoute != null) {
          if (state.targetRoute == '/home') {
            Navigator.of(context).maybePop();
          } else {
            context.push(state.targetRoute!);
          }
        }
      },
      builder: (context, state) {
        final bloc = context.read<ChooseRideBloc>();

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: ChooseRideAppBar(
            onBack: () => bloc.add(const ChooseRideBackTapped()),
            onProfileTapped: () => context.push('/profile'),
            onToggleInspector: () => bloc.add(const ChooseRideToggleInspectorMode()),
            isInspectorMode: state.isInspectorMode,
          ),
          bottomNavigationBar: state.isLoading
              ? null
              : _buildBottomBar(context, state, bloc),
          body: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top QA or Demo Control Bar
                      if (state.isInspectorMode)
                        QaPromoInspectorBar(
                          selectedScenario: state.qaScenario,
                          onScenarioSelected: (sc) =>
                              bloc.add(ChooseRideQaScenarioSelected(sc)),
                        )
                      else
                        DemoStateBar(
                          selectedState: state.demoState,
                          onStateSelected: (st) =>
                              bloc.add(ChooseRideDemoStateSelected(st)),
                        ),

                      // Quote Expiring Banner (Countdown alert)
                      if (state.isExpiring)
                        QuoteExpiringBanner(timerText: state.validityTimerText),

                      // Map Header View
                      ChooseRideMapView(
                        routeText: state.routeText,
                        routeAreaLabel: state.routeAreaLabel,
                        distanceText: state.distanceText,
                        isInspectorMode: state.isInspectorMode,
                      ),

                      // Loading State
                      if (state.isLoading) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                ChooseRideConfig.screenTitle,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                ChooseRideConfig.liveDispatchBadge,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                ChooseRideConfig.findingBestFares,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFB71C1C),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const RideTierSkeleton(),
                      ] else ...[
                        // Sheet Header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    ChooseRideConfig.screenTitle,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Bridge City Cabs · Lethbridge Dispatch · Local Fleet',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 13, color: Color(0xFFDC2626)),
                                    const SizedBox(width: 4),
                                    Text(
                                      state.destinationText,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Promo Section
                        if (state.isPromoApplied) ...[
                          PromoAppliedCard(
                            promo: state.appliedPromo!,
                            onRemove: () =>
                                bloc.add(const ChooseRidePromoRemoved()),
                            onViewTerms: () => bloc.add(
                                const ChooseRideOpenPromoTermsTapped()),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Promo applied: ${state.appliedPromo!.code}',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF047857),
                                  ),
                                ),
                                Text(
                                  '-\$${state.appliedPromo!.discountAmountCad.toStringAsFixed(2)} CAD',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF047857),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (state.isInspectorMode || state.hasPromoError)
                          PromoInputSection(
                            couponCode: state.couponInput,
                            errorMessage: state.promoInputError,
                            onChanged: (code) =>
                                bloc.add(ChooseRidePromoInputChanged(code)),
                            onClear: () => bloc.add(
                                const ChooseRideClearPromoInputTapped()),
                            onApply: () => bloc.add(
                                ChooseRidePromoApplied(state.couponInput)),
                          )
                        else
                          PromoTeaserCard(
                            onAdd: () => bloc.add(
                                const ChooseRideToggleInspectorMode()),
                          ),

                        const SizedBox(height: 6),

                        // Ride Tiers List
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    'Available Rides',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  Text(
                                    'Lethbridge Metrowide',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ...state.tiers.map((tier) {
                                return RideTierCard(
                                  tier: tier,
                                  isSelected: tier.id == state.selectedTierId,
                                  promo: state.appliedPromo,
                                  onTap: () =>
                                      bloc.add(ChooseRideTierSelected(tier.id)),
                                );
                              }),
                            ],
                          ),
                        ),

                        // Ride Preferences (e.g. Lady driver preferred)
                        RidePreferencesSection(
                          preference: state.preference,
                          onVanOnlyChanged: (val) => bloc.add(
                              ChooseRidePreferenceChanged(vanOnly: val)),
                          onLadyDriverChanged: (val) => bloc.add(
                              ChooseRidePreferenceChanged(ladyDriverOnly: val)),
                        ),

                        // Payment Account Row
                        PaymentAccountRow(
                          accountLabel: state.paymentMethodLabel,
                          subtitle: state.isInspectorMode
                              ? 'Standard ride account'
                              : null,
                          showCityRegulatedNotice: !state.isInspectorMode,
                          onChange: () => bloc.add(
                              const ChooseRidePaymentChanged('Personal · MasterCard 1984')),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Modal Bottom Sheet Overlay for Promo Terms (Screen 3)
              if (state.showPromoTermsModal) ...[
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () =>
                        bloc.add(const ChooseRideClosePromoTermsTapped()),
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: PromoTermsModalSheet(
                    onClose: () =>
                        bloc.add(const ChooseRideClosePromoTermsTapped()),
                    onRemovePromo: () {
                      bloc.add(const ChooseRideClosePromoTermsTapped());
                      bloc.add(const ChooseRidePromoRemoved());
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(
      BuildContext context, ChooseRideState state, ChooseRideBloc bloc) {
    String label;
    if (state.isExpiring) {
      label = 'LOCK FARE Continue • ${state.formattedFinalPrice}';
    } else if (state.isPromoApplied) {
      label = 'Continue • ${state.formattedFinalPrice}';
    } else if (state.isInspectorMode) {
      label =
          'Continue with ${state.selectedTier?.name ?? 'Sedan'} · ${state.formattedFinalPrice}';
    } else {
      label = 'Continue • ${state.formattedFinalPrice}';
    }

    return ChooseRideBottomBar(
      buttonLabel: label,
      securityNote: state.isPromoApplied
          ? 'Server verified rate · Valid for this ride'
          : (state.isInspectorMode
              ? 'Guaranteed fare quote · Free cancellation in 2 min'
              : 'Server verified rate · Valid for this ride'),
      hasCheckmark: state.isInspectorMode,
      hasCarIcon: state.isPromoApplied,
      hasArrow: state.isPromoApplied,
      onContinue: () => bloc.add(const ChooseRideContinueTapped()),
    );
  }
}
