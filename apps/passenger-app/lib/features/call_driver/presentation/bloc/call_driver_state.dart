import 'package:equatable/equatable.dart';
import '../../data/models/call_driver_model.dart';

class CallDriverState extends Equatable {
  final DriverCallDetails driverDetails;
  final CallPhase phase;
  final CallOutcomeScenario outcomeScenario;
  final bool isMuted;
  final bool isKeypadOpen;
  final bool isSpeakerOn;
  final int callDurationSeconds;
  final String? feedbackMessage;

  const CallDriverState({
    this.driverDetails = DriverCallDetails.defaultMichael,
    this.phase = CallPhase.preCallPrompt,
    this.outcomeScenario = CallOutcomeScenario.didntAnswer,
    this.isMuted = false,
    this.isKeypadOpen = false,
    this.isSpeakerOn = true, // Speaker is highlighted in red on Screen 3
    this.callDurationSeconds = 42, // Default 42s matches Screen 2 & 3
    this.feedbackMessage,
  });

  String get formattedDuration {
    final minutes = callDurationSeconds ~/ 60;
    final seconds = callDurationSeconds % 60;
    final paddedSec = seconds.toString().padLeft(2, '0');
    return '$minutes:$paddedSec';
  }

  String get statusTitle {
    switch (phase) {
      case CallPhase.preCallPrompt:
        return 'Call ${driverDetails.firstName}';
      case CallPhase.connecting:
        return 'Connecting you to ${driverDetails.firstName}...';
      case CallPhase.ringing:
        return 'Ringing ${driverDetails.firstName}...';
      case CallPhase.connected:
        return 'Connected ($formattedDuration)';
      case CallPhase.ended:
        return 'Call ended';
      case CallPhase.outcomeFallback:
        return outcomeScenario.title;
    }
  }

  String get statusSubtitle {
    switch (phase) {
      case CallPhase.preCallPrompt:
        return 'Lethbridge City Regulated Driver';
      case CallPhase.connecting:
        return 'Establishing encrypted cab relay';
      case CallPhase.ringing:
        return 'Driver phone is ringing via proxy';
      case CallPhase.connected:
        return 'Secure masked proxy call active';
      case CallPhase.ended:
        return 'Call duration: $formattedDuration';
      case CallPhase.outcomeFallback:
        return outcomeScenario.description;
    }
  }

  CallDriverState copyWith({
    DriverCallDetails? driverDetails,
    CallPhase? phase,
    CallOutcomeScenario? outcomeScenario,
    bool? isMuted,
    bool? isKeypadOpen,
    bool? isSpeakerOn,
    int? callDurationSeconds,
    String? feedbackMessage,
  }) {
    return CallDriverState(
      driverDetails: driverDetails ?? this.driverDetails,
      phase: phase ?? this.phase,
      outcomeScenario: outcomeScenario ?? this.outcomeScenario,
      isMuted: isMuted ?? this.isMuted,
      isKeypadOpen: isKeypadOpen ?? this.isKeypadOpen,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      callDurationSeconds: callDurationSeconds ?? this.callDurationSeconds,
      feedbackMessage: feedbackMessage,
    );
  }

  @override
  List<Object?> get props => [
        driverDetails,
        phase,
        outcomeScenario,
        isMuted,
        isKeypadOpen,
        isSpeakerOn,
        callDurationSeconds,
        feedbackMessage,
      ];
}
