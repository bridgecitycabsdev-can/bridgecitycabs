import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/card_auth_bloc.dart';
import '../bloc/card_auth_event.dart';
import '../bloc/card_auth_state.dart';
import '../../data/models/card_auth_model.dart';
import '../../data/repositories/card_auth_repository.dart';
import '../widgets/card_auth_app_bar.dart';
import '../widgets/card_declined_error_banner.dart';
import '../widgets/payment_method_selection_list.dart';
import '../widgets/qa_auth_scenario_bar.dart';

class PaymentErrorFallbackPage extends StatelessWidget {
  const PaymentErrorFallbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CardAuthBloc(
        repository: MockCardAuthRepository(),
      )..add(const CardAuthStarted(
          initialStage: CardAuthStage.declined,
          initialTestScenario: AuthTestScenario.failed,
        )),
      child: const PaymentErrorFallbackPageView(),
    );
  }
}

class PaymentErrorFallbackPageView extends StatelessWidget {
  const PaymentErrorFallbackPageView({super.key});

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

        if (state.isWaitingForBank || state.isPrompt3ds) {
          Navigator.of(context).maybePop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: CardAuthAppBar(
            title: 'Authentication Failed Alert',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          body: Column(
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

              // Scrollable Details & Methods
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Declined Error Banner & Route Locked Card
                      CardDeclinedErrorBanner(
                        errorCode: state.errorCode,
                        errorMessage: state.errorMessage,
                        fareCad: state.fareCad,
                      ),

                      // Alternate Payment Method Selection List
                      PaymentMethodSelectionList(
                        methods: state.availableMethods,
                        selectedMethodId: state.selectedPaymentMethodId,
                        fareCad: state.fareCad,
                        isProcessing: state.isProcessing,
                        onSelectMethod: (id) {
                          context
                              .read<CardAuthBloc>()
                              .add(CardAuthPaymentMethodSelected(id));
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
                        onCancel: () {
                          context
                              .read<CardAuthBloc>()
                              .add(const CardAuthCancelTapped());
                          Navigator.of(context).maybePop();
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
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
