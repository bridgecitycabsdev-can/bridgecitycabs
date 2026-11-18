import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/card_auth_bloc.dart';
import '../bloc/card_auth_event.dart';
import '../bloc/card_auth_state.dart';
import '../../data/models/card_auth_model.dart';
import '../../data/repositories/card_auth_repository.dart';
import '../widgets/card_auth_app_bar.dart';
import '../widgets/expired_card_warning_card.dart';
import '../widgets/qa_auth_scenario_bar.dart';

class ExpiredCardPromptPage extends StatelessWidget {
  const ExpiredCardPromptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CardAuthBloc(
        repository: MockCardAuthRepository(),
      )..add(const CardAuthStarted(
          initialStage: CardAuthStage.expiredCard,
          initialEdgeScenario: EdgeCaseScenario.expiredCard,
        )),
      child: const ExpiredCardPromptPageView(),
    );
  }
}

class ExpiredCardPromptPageView extends StatelessWidget {
  const ExpiredCardPromptPageView({super.key});

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
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: CardAuthAppBar(
            title: 'Confirm Trip',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          body: Column(
            children: [
              // QA Scenario Bar (1. Expired Card, 2. Insufficient Funds, 3. Payment Error)
              EdgeCaseScenarioBar(
                selectedScenario: state.selectedEdgeScenario,
                onScenarioSelected: (scenario) {
                  context
                      .read<CardAuthBloc>()
                      .add(CardAuthEdgeCaseSelected(scenario));
                },
              ),

              // Scrollable Expired Card Details
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ExpiredCardWarningCard(
                    currentCard: state.currentCard,
                    fareCad: state.fareCad,
                    onChangeCard: () {
                      context
                          .read<CardAuthBloc>()
                          .add(const CardAuthChangeCardTapped());
                    },
                    onPayCash: () {
                      context
                          .read<CardAuthBloc>()
                          .add(const CardAuthPayCashInsteadTapped());
                    },
                    onAddNewCard: () {
                      context
                          .read<CardAuthBloc>()
                          .add(const CardAuthAddNewCardTapped());
                    },
                    onBookRide: () {
                      context
                          .read<CardAuthBloc>()
                          .add(const CardAuthBookWithSelectedMethodTapped());
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
