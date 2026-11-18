import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/card_auth_bloc.dart';
import '../bloc/card_auth_event.dart';
import '../bloc/card_auth_state.dart';
import '../../data/models/card_auth_model.dart';
import '../../data/repositories/card_auth_repository.dart';
import '../widgets/bank_waiting_challenge_sheet.dart';
import '../widgets/card_3ds_prompt_sheet.dart';
import '../widgets/card_auth_app_bar.dart';
import '../widgets/qa_auth_scenario_bar.dart';
import 'payment_error_fallback_page.dart';

class CardAuthenticationPage extends StatelessWidget {
  final CardAuthStage initialStage;
  final AuthTestScenario initialScenario;

  const CardAuthenticationPage({
    super.key,
    this.initialStage = CardAuthStage.prompt3ds,
    this.initialScenario = AuthTestScenario.waiting,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CardAuthBloc(
        repository: MockCardAuthRepository(),
      )..add(CardAuthStarted(
          initialStage: initialStage,
          initialTestScenario: initialScenario,
        )),
      child: const _CardAuthenticationView(),
    );
  }
}

class _CardAuthenticationView extends StatelessWidget {
  const _CardAuthenticationView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CardAuthBloc, CardAuthState>(
      listener: (context, state) {
        if (state.feedbackMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.feedbackMessage!),
              duration: const Duration(seconds: 2),
              backgroundColor: state.isVerified
                  ? const Color(0xFF059669)
                  : const Color(0xFF1F2937),
            ),
          );
        }

        if (state.isDeclined) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<CardAuthBloc>(),
                child: const PaymentErrorFallbackPageView(),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: CardAuthAppBar(
            title: state.isWaitingForBank
                ? 'Authentication Challenge'
                : '3D Secure Verification',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          body: Stack(
            children: [
              // Background Ride Preview & Map Placeholder
              Column(
                children: [
                  // QA Scenario Bar (1. Waiting, 2. Verified, 3. Failed, 4. Canceled)
                  QaAuthScenarioBar(
                    selectedScenario: state.selectedTestScenario,
                    onScenarioSelected: (scenario) {
                      context
                          .read<CardAuthBloc>()
                          .add(CardAuthTestScenarioSelected(scenario));
                    },
                  ),

                  // Simulated Map & Route Info (Dimmed behind sheet)
                  Expanded(
                    child: Container(
                      color: const Color(0xFFF3F4F6),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.local_taxi,
                                    color: Color(0xFF991B1B),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Standard Ride',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Est. Pickup 3 mins',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  state.formattedFare,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF991B1B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Semi-transparent backdrop scrim
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.35),
                ),
              ),

              // Bottom Sheet Overlay
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: state.isWaitingForBank
                      ? BankWaitingChallengeSheet(
                          key: const ValueKey('bank_waiting_sheet'),
                          card: state.currentCard,
                          fareCad: state.fareCad,
                        )
                      : Card3dsPromptSheet(
                          key: const ValueKey('card_3ds_prompt_sheet'),
                          card: state.currentCard,
                          fareCad: state.fareCad,
                          isProcessing: state.isProcessing,
                          onContinueToVerify: () {
                            context
                                .read<CardAuthBloc>()
                                .add(const CardAuthContinueToVerifyTapped());
                          },
                          onPayWithCash: () {
                            context
                                .read<CardAuthBloc>()
                                .add(const CardAuthPayCashInsteadTapped());
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
