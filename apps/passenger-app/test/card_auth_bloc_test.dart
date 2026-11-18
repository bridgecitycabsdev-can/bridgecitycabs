import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/card_authentication/card_authentication.dart';

void main() {
  group('CardAuthBloc Tests', () {
    late CardAuthBloc bloc;
    late CardAuthRepository repository;

    setUp(() {
      repository = CardAuthRepositoryImpl(
        simulateLatency: const Duration(milliseconds: 5),
      );
      bloc = CardAuthBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state defaults to 3DS prompt stage and $22.10 CAD fare', () {
      expect(bloc.state.stage, CardAuthStage.prompt3ds);
      expect(bloc.state.isPrompt3ds, isTrue);
      expect(bloc.state.fareCad, 22.10);
      expect(bloc.state.currentCard.last4, '4242');
      expect(bloc.state.selectedTestScenario, AuthTestScenario.waiting);
    });

    test('CardAuthStarted initializes stage and scenarios', () async {
      bloc.add(const CardAuthStarted(
        initialStage: CardAuthStage.declined,
        initialTestScenario: AuthTestScenario.failed,
      ));

      await expectLater(
        bloc.stream,
        emits(predicate<CardAuthState>((s) {
          return s.stage == CardAuthStage.declined &&
              s.selectedTestScenario == AuthTestScenario.failed &&
              s.isDeclined;
        })),
      );
    });

    test('CardAuthContinueToVerifyTapped transitions to waitingForBank', () async {
      bloc.add(const CardAuthContinueToVerifyTapped());

      await expectLater(
        bloc.stream,
        emits(predicate<CardAuthState>((s) {
          return s.stage == CardAuthStage.waitingForBank &&
              s.isWaitingForBank;
        })),
      );
    });

    test('CardAuthPayCashInsteadTapped switches to Cash and notifies', () async {
      bloc.add(const CardAuthPayCashInsteadTapped());

      await expectLater(
        bloc.stream,
        emits(predicate<CardAuthState>((s) {
          return s.selectedPaymentMethodId == 'pm_cash' &&
              s.feedbackMessage != null &&
              s.feedbackMessage!.contains('Switched to Cash payment');
        })),
      );
    });

    test('CardAuthTestScenarioSelected sets waiting, verified, failed and canceled', () async {
      // Waiting
      bloc.add(const CardAuthTestScenarioSelected(AuthTestScenario.waiting));
      await expectLater(
        bloc.stream,
        emits(predicate<CardAuthState>((s) => s.isWaitingForBank)),
      );

      // Verified
      bloc.add(const CardAuthTestScenarioSelected(AuthTestScenario.verified));
      await expectLater(
        bloc.stream,
        emits(predicate<CardAuthState>((s) =>
            s.isVerified && s.feedbackMessage!.contains('Card verified'))),
      );

      // Failed
      bloc.add(const CardAuthTestScenarioSelected(AuthTestScenario.failed));
      await expectLater(
        bloc.stream,
        emits(predicate<CardAuthState>((s) =>
            s.isDeclined && s.errorCode == CardAuthConfig.errDeclinedGeneric)),
      );

      // Canceled
      bloc.add(const CardAuthTestScenarioSelected(AuthTestScenario.canceled));
      await expectLater(
        bloc.stream,
        emits(predicate<CardAuthState>((s) =>
            s.isCanceled && s.feedbackMessage!.contains('canceled'))),
      );
    });

    test('CardAuthEdgeCaseSelected updates edge scenario and stages', () async {
      bloc.add(const CardAuthEdgeCaseSelected(EdgeCaseScenario.expiredCard));
      await expectLater(
        bloc.stream,
        emits(predicate<CardAuthState>((s) => s.isExpiredCard)),
      );

      bloc.add(const CardAuthEdgeCaseSelected(EdgeCaseScenario.insufficientFunds));
      await expectLater(
        bloc.stream,
        emits(predicate<CardAuthState>((s) =>
            s.selectedEdgeScenario == EdgeCaseScenario.insufficientFunds &&
            s.feedbackMessage!.contains('Insufficient Funds'))),
      );
    });

    test('CardAuthPaymentMethodSelected updates selected method ID', () async {
      bloc.add(const CardAuthPaymentMethodSelected('pm_mc_1984'));
      await expectLater(
        bloc.stream,
        emits(predicate<CardAuthState>(
            (s) => s.selectedPaymentMethodId == 'pm_mc_1984')),
      );
    });

    test('CardAuthBookWithSelectedMethodTapped completes booking authorization', () async {
      bloc.add(const CardAuthPaymentMethodSelected('pm_mc_1984'));
      await pumpEventQueue();

      bloc.add(const CardAuthBookWithSelectedMethodTapped());

      // Emits isProcessing: true, then finishes
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<CardAuthState>((s) =>
            !s.isProcessing &&
            s.feedbackMessage != null &&
            s.feedbackMessage!.contains('authorized successfully'))),
      );
    });
  });
}
