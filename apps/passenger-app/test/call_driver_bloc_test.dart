import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/call_driver/call_driver.dart';

void main() {
  group('CallDriverBloc Tests', () {
    late CallDriverBloc bloc;

    setUp(() {
      bloc = CallDriverBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state contains defaults', () {
      expect(bloc.state.phase, CallPhase.preCallPrompt);
      expect(bloc.state.driverDetails.firstName, 'Michael');
      expect(bloc.state.isSpeakerOn, isTrue);
      expect(bloc.state.isMuted, isFalse);
      expect(bloc.state.isKeypadOpen, isFalse);
    });

    test('CallDriverStarted initializes state with driver details', () async {
      bloc.add(const CallDriverStarted(initialPhase: CallPhase.connecting));
      await expectLater(
        bloc.stream,
        emits(predicate<CallDriverState>((s) =>
            s.phase == CallPhase.connecting &&
            s.driverDetails.firstName == 'Michael')),
      );
    });

    test('CallDriverInitiateTapped sets phase to connecting', () async {
      bloc.add(const CallDriverInitiateTapped());
      await expectLater(
        bloc.stream,
        emits(predicate<CallDriverState>((s) =>
            s.phase == CallPhase.connecting &&
            s.feedbackMessage != null &&
            s.feedbackMessage!.contains('Connecting'))),
      );
    });

    test('CallDriverPhaseChanged updates call phase', () async {
      bloc.add(const CallDriverPhaseChanged(CallPhase.ringing));
      await expectLater(
        bloc.stream,
        emits(predicate<CallDriverState>((s) => s.phase == CallPhase.ringing)),
      );

      bloc.add(const CallDriverPhaseChanged(CallPhase.connected));
      await expectLater(
        bloc.stream,
        emits(predicate<CallDriverState>((s) => s.phase == CallPhase.connected)),
      );
    });

    test('Audio toggles work correctly', () async {
      // Toggle Mute
      bloc.add(const CallDriverToggleMute());
      await expectLater(
        bloc.stream,
        emits(predicate<CallDriverState>((s) => s.isMuted == true)),
      );

      // Toggle Speaker
      bloc.add(const CallDriverToggleSpeaker());
      await expectLater(
        bloc.stream,
        emits(predicate<CallDriverState>((s) => s.isSpeakerOn == false)),
      );

      // Toggle Keypad
      bloc.add(const CallDriverToggleKeypad());
      await expectLater(
        bloc.stream,
        emits(predicate<CallDriverState>((s) => s.isKeypadOpen == true)),
      );
    });

    test('CallDriverOutcomeScenarioChanged updates scenario and phase', () async {
      bloc.add(const CallOutcomeScenarioChanged(CallOutcomeScenario.driverBusy));
      await expectLater(
        bloc.stream,
        emits(predicate<CallDriverState>((s) =>
            s.phase == CallPhase.outcomeFallback &&
            s.outcomeScenario == CallOutcomeScenario.driverBusy)),
      );
    });

    test('CallDriverRetryTapped resets phase to connecting', () async {
      bloc.add(const CallDriverRetryTapped());
      await expectLater(
        bloc.stream,
        emits(predicate<CallDriverState>((s) =>
            s.phase == CallPhase.connecting &&
            s.feedbackMessage != null &&
            s.feedbackMessage!.contains('Retrying'))),
      );
    });

    test('CallDriverCancelCallTapped transitions to ended', () async {
      bloc.add(const CallDriverCancelCallTapped());
      await expectLater(
        bloc.stream,
        emits(predicate<CallDriverState>((s) =>
            s.phase == CallPhase.ended &&
            s.feedbackMessage == 'Call ended')),
      );
    });
  });
}
