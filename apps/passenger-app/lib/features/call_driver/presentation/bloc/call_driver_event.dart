import 'package:equatable/equatable.dart';
import '../../data/models/call_driver_model.dart';

abstract class CallDriverEvent extends Equatable {
  const CallDriverEvent();

  @override
  List<Object?> get props => [];
}

class CallDriverStarted extends CallDriverEvent {
  final String? tripId;
  final CallPhase initialPhase;

  const CallDriverStarted({
    this.tripId,
    this.initialPhase = CallPhase.preCallPrompt,
  });

  @override
  List<Object?> get props => [tripId, initialPhase];
}

class CallDriverInitiateTapped extends CallDriverEvent {
  const CallDriverInitiateTapped();
}

class CallDriverPhaseChanged extends CallDriverEvent {
  final CallPhase phase;

  const CallDriverPhaseChanged(this.phase);

  @override
  List<Object?> get props => [phase];
}

class CallDriverOutcomeScenarioChanged extends CallDriverEvent {
  final CallOutcomeScenario scenario;

  const CallDriverOutcomeScenarioChanged(this.scenario);

  @override
  List<Object?> get props => [scenario];
}

class CallDriverToggleMute extends CallDriverEvent {
  const CallDriverToggleMute();
}

class CallDriverToggleKeypad extends CallDriverEvent {
  const CallDriverToggleKeypad();
}

class CallDriverToggleSpeaker extends CallDriverEvent {
  const CallDriverToggleSpeaker();
}

class CallDriverCancelCallTapped extends CallDriverEvent {
  const CallDriverCancelCallTapped();
}

class CallDriverRetryTapped extends CallDriverEvent {
  const CallDriverRetryTapped();
}

class CallDriverDismissTapped extends CallDriverEvent {
  const CallDriverDismissTapped();
}

class CallDriverCallDispatchTapped extends CallDriverEvent {
  const CallDriverCallDispatchTapped();
}

class CallDriverTimerTicked extends CallDriverEvent {
  final int seconds;

  const CallDriverTimerTicked(this.seconds);

  @override
  List<Object?> get props => [seconds];
}
