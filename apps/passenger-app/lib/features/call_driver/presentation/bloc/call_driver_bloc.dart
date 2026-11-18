import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/call_driver_model.dart';
import '../../data/repositories/call_driver_repository.dart';
import 'call_driver_event.dart';
import 'call_driver_state.dart';

class CallDriverBloc extends Bloc<CallDriverEvent, CallDriverState> {
  final CallDriverRepository repository;

  CallDriverBloc({CallDriverRepository? repository})
      : repository = repository ?? MockCallDriverRepository(),
        super(const CallDriverState()) {
    on<CallDriverStarted>(_onStarted);
    on<CallDriverInitiateTapped>(_onInitiateTapped);
    on<CallDriverPhaseChanged>(_onPhaseChanged);
    on<CallDriverOutcomeScenarioChanged>(_onOutcomeScenarioChanged);
    on<CallDriverToggleMute>(_onToggleMute);
    on<CallDriverToggleKeypad>(_onToggleKeypad);
    on<CallDriverToggleSpeaker>(_onToggleSpeaker);
    on<CallDriverCancelCallTapped>(_onCancelCallTapped);
    on<CallDriverRetryTapped>(_onRetryTapped);
    on<CallDriverDismissTapped>(_onDismissTapped);
    on<CallDriverCallDispatchTapped>(_onCallDispatchTapped);
    on<CallDriverTimerTicked>(_onTimerTicked);
  }

  Future<void> _onStarted(
    CallDriverStarted event,
    Emitter<CallDriverState> emit,
  ) async {
    final driver = await repository.getDriverDetails(event.tripId ?? 'default');
    emit(state.copyWith(
      driverDetails: driver,
      phase: event.initialPhase,
    ));
  }

  Future<void> _onInitiateTapped(
    CallDriverInitiateTapped event,
    Emitter<CallDriverState> emit,
  ) async {
    emit(state.copyWith(
      phase: CallPhase.connecting,
      feedbackMessage: 'Connecting via masked relay...',
    ));
    await repository.initiateMaskedCall(
      tripId: 'BC-123456',
      driverId: state.driverDetails.driverId,
    );
  }

  void _onPhaseChanged(
    CallDriverPhaseChanged event,
    Emitter<CallDriverState> emit,
  ) {
    emit(state.copyWith(phase: event.phase));
  }

  void _onOutcomeScenarioChanged(
    CallDriverOutcomeScenarioChanged event,
    Emitter<CallDriverState> emit,
  ) {
    emit(state.copyWith(
      outcomeScenario: event.scenario,
      phase: CallPhase.outcomeFallback,
    ));
  }

  void _onToggleMute(
    CallDriverToggleMute event,
    Emitter<CallDriverState> emit,
  ) {
    final newMute = !state.isMuted;
    emit(state.copyWith(
      isMuted: newMute,
      feedbackMessage: newMute ? 'Microphone muted' : 'Microphone unmuted',
    ));
  }

  void _onToggleKeypad(
    CallDriverToggleKeypad event,
    Emitter<CallDriverState> emit,
  ) {
    emit(state.copyWith(
      isKeypadOpen: !state.isKeypadOpen,
    ));
  }

  void _onToggleSpeaker(
    CallDriverToggleSpeaker event,
    Emitter<CallDriverState> emit,
  ) {
    final newSpeaker = !state.isSpeakerOn;
    emit(state.copyWith(
      isSpeakerOn: newSpeaker,
      feedbackMessage: newSpeaker ? 'Speakerphone on' : 'Speakerphone off',
    ));
  }

  Future<void> _onCancelCallTapped(
    CallDriverCancelCallTapped event,
    Emitter<CallDriverState> emit,
  ) async {
    await repository.endCall();
    emit(state.copyWith(
      phase: CallPhase.ended,
      feedbackMessage: 'Call ended',
    ));
  }

  Future<void> _onRetryTapped(
    CallDriverRetryTapped event,
    Emitter<CallDriverState> emit,
  ) async {
    emit(state.copyWith(
      phase: CallPhase.connecting,
      feedbackMessage: 'Retrying call to ${state.driverDetails.firstName}...',
    ));
    await repository.initiateMaskedCall(
      tripId: 'BC-123456',
      driverId: state.driverDetails.driverId,
    );
  }

  void _onDismissTapped(
    CallDriverDismissTapped event,
    Emitter<CallDriverState> emit,
  ) {
    emit(state.copyWith(
      phase: CallPhase.preCallPrompt,
      feedbackMessage: 'Call dismissed',
    ));
  }

  void _onCallDispatchTapped(
    CallDriverCallDispatchTapped event,
    Emitter<CallDriverState> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage: 'Dialing Lethbridge 24/7 Dispatch (403-329-5577)...',
    ));
  }

  void _onTimerTicked(
    CallDriverTimerTicked event,
    Emitter<CallDriverState> emit,
  ) {
    emit(state.copyWith(callDurationSeconds: event.seconds));
  }
}
