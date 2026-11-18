import 'package:equatable/equatable.dart';

import '../data/models/driver_support_form_state.dart';
import '../data/models/driver_support_status.dart';
import '../data/models/driver_support_ticket.dart';
import '../data/models/driver_support_topic.dart';

abstract class DriverSupportEvent extends Equatable {
  const DriverSupportEvent();

  @override
  List<Object?> get props => [];
}

class DriverSupportStarted extends DriverSupportEvent {
  const DriverSupportStarted();
}

class DriverSupportSwitchView extends DriverSupportEvent {
  final DriverSupportViewStatus status;
  const DriverSupportSwitchView(this.status);

  @override
  List<Object?> get props => [status];
}

class DriverSupportSelectTopic extends DriverSupportEvent {
  final DriverSupportTopic topic;
  const DriverSupportSelectTopic(this.topic);

  @override
  List<Object?> get props => [topic];
}

class DriverSupportSubjectChanged extends DriverSupportEvent {
  final String subject;
  const DriverSupportSubjectChanged(this.subject);

  @override
  List<Object?> get props => [subject];
}

class DriverSupportDescriptionChanged extends DriverSupportEvent {
  final String description;
  const DriverSupportDescriptionChanged(this.description);

  @override
  List<Object?> get props => [description];
}

class DriverSupportToggleAttachment extends DriverSupportEvent {
  final bool hasAttachment;
  const DriverSupportToggleAttachment(this.hasAttachment);

  @override
  List<Object?> get props => [hasAttachment];
}

class DriverSupportSubmitTicketPressed extends DriverSupportEvent {
  const DriverSupportSubmitTicketPressed();
}

class DriverSupportSelectFilter extends DriverSupportEvent {
  final DriverSupportTicketFilter filter;
  const DriverSupportSelectFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}

class DriverSupportSelectTicket extends DriverSupportEvent {
  final String ticketId;
  const DriverSupportSelectTicket(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}

class DriverSupportSendChatMessage extends DriverSupportEvent {
  final String text;
  const DriverSupportSendChatMessage(this.text);

  @override
  List<Object?> get props => [text];
}

class DriverSupportRetryChatMessage extends DriverSupportEvent {
  final String messageId;
  const DriverSupportRetryChatMessage(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

class DriverSupportQuickActionTriggered extends DriverSupportEvent {
  final String action;
  const DriverSupportQuickActionTriggered(this.action);

  @override
  List<Object?> get props => [action];
}

class DriverSupportEmergencySosTriggered extends DriverSupportEvent {
  const DriverSupportEmergencySosTriggered();
}

class DriverSupportSetFormInspectorState extends DriverSupportEvent {
  final DriverSupportFormInspectorState inspectorState;
  const DriverSupportSetFormInspectorState(this.inspectorState);

  @override
  List<Object?> get props => [inspectorState];
}

class DriverSupportSetDispatchState extends DriverSupportEvent {
  final DriverSupportDispatchState dispatchState;
  const DriverSupportSetDispatchState(this.dispatchState);

  @override
  List<Object?> get props => [dispatchState];
}

class DriverSupportClearToast extends DriverSupportEvent {
  const DriverSupportClearToast();
}
