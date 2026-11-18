import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/driver_support_form_state.dart';
import '../data/models/driver_support_message.dart';
import '../data/models/driver_support_status.dart';
import '../data/models/driver_support_ticket.dart';
import '../data/repositories/driver_support_repository.dart';
import 'driver_support_event.dart';
import 'driver_support_state.dart';

class DriverSupportBloc extends Bloc<DriverSupportEvent, DriverSupportState> {
  final DriverSupportRepository repository;

  DriverSupportBloc({
    required this.repository,
    DriverSupportViewStatus initialStatus = DriverSupportViewStatus.center,
  }) : super(DriverSupportState(viewStatus: initialStatus)) {
    on<DriverSupportStarted>(_onStarted);
    on<DriverSupportSwitchView>(_onSwitchView);
    on<DriverSupportSelectTopic>(_onSelectTopic);
    on<DriverSupportSubjectChanged>(_onSubjectChanged);
    on<DriverSupportDescriptionChanged>(_onDescriptionChanged);
    on<DriverSupportToggleAttachment>(_onToggleAttachment);
    on<DriverSupportSubmitTicketPressed>(_onSubmitTicketPressed);
    on<DriverSupportSelectFilter>(_onSelectFilter);
    on<DriverSupportSelectTicket>(_onSelectTicket);
    on<DriverSupportSendChatMessage>(_onSendChatMessage);
    on<DriverSupportRetryChatMessage>(_onRetryChatMessage);
    on<DriverSupportQuickActionTriggered>(_onQuickActionTriggered);
    on<DriverSupportEmergencySosTriggered>(_onEmergencySosTriggered);
    on<DriverSupportSetFormInspectorState>(_onSetFormInspectorState);
    on<DriverSupportSetDispatchState>(_onSetDispatchState);
    on<DriverSupportClearToast>(_onClearToast);
  }

  Future<void> _onStarted(
    DriverSupportStarted event,
    Emitter<DriverSupportState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final tickets = await repository.getTickets();
      final faqs = await repository.getFaqTopics();
      final initialTicket = tickets.isNotEmpty ? tickets.first : null;
      emit(state.copyWith(
        isLoading: false,
        tickets: tickets,
        faqs: faqs,
        selectedTicket: initialTicket,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        toastMessage: 'Failed to load tickets: $e',
      ));
    }
  }

  void _onSwitchView(
    DriverSupportSwitchView event,
    Emitter<DriverSupportState> emit,
  ) {
    emit(state.copyWith(viewStatus: event.status));
  }

  void _onSelectTopic(
    DriverSupportSelectTopic event,
    Emitter<DriverSupportState> emit,
  ) {
    emit(state.copyWith(selectedTopic: event.topic));
  }

  void _onSubjectChanged(
    DriverSupportSubjectChanged event,
    Emitter<DriverSupportState> emit,
  ) {
    emit(state.copyWith(subject: event.subject));
  }

  void _onDescriptionChanged(
    DriverSupportDescriptionChanged event,
    Emitter<DriverSupportState> emit,
  ) {
    final text = event.description.length > 500
        ? event.description.substring(0, 500)
        : event.description;
    emit(state.copyWith(description: text));
  }

  void _onToggleAttachment(
    DriverSupportToggleAttachment event,
    Emitter<DriverSupportState> emit,
  ) {
    emit(state.copyWith(hasAttachment: event.hasAttachment));
  }

  Future<void> _onSubmitTicketPressed(
    DriverSupportSubmitTicketPressed event,
    Emitter<DriverSupportState> emit,
  ) async {
    if (state.subject.trim().isEmpty) {
      emit(state.copyWith(toastMessage: 'Please enter a ticket subject'));
      return;
    }
    if (state.description.trim().isEmpty) {
      emit(state.copyWith(toastMessage: 'Please describe your issue'));
      return;
    }

    emit(state.copyWith(isLoading: true));
    try {
      final newTicket = await repository.createTicket(
        topic: state.selectedTopic,
        subject: state.subject,
        description: state.description,
        linkedTripId: state.linkedTripId,
        linkedTripFare: state.linkedTripFare,
        attachmentName: state.hasAttachment ? state.attachmentName : null,
      );

      final updatedTickets = [newTicket, ...state.tickets];
      emit(state.copyWith(
        isLoading: false,
        tickets: updatedTickets,
        selectedTicket: newTicket,
        viewStatus: DriverSupportViewStatus.myTickets,
        toastMessage: 'Ticket ${newTicket.id} submitted to Lethbridge Dispatch',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        toastMessage: 'Failed to submit ticket: $e',
      ));
    }
  }

  void _onSelectFilter(
    DriverSupportSelectFilter event,
    Emitter<DriverSupportState> emit,
  ) {
    emit(state.copyWith(selectedFilter: event.filter));
  }

  void _onSelectTicket(
    DriverSupportSelectTicket event,
    Emitter<DriverSupportState> emit,
  ) {
    final ticket = state.tickets.firstWhere(
      (t) => t.id == event.ticketId,
      orElse: () => state.tickets.first,
    );
    emit(state.copyWith(
      selectedTicket: ticket,
      viewStatus: DriverSupportViewStatus.ticketDetail,
    ));
  }

  Future<void> _onSendChatMessage(
    DriverSupportSendChatMessage event,
    Emitter<DriverSupportState> emit,
  ) async {
    if (event.text.trim().isEmpty || state.selectedTicket == null) return;

    final ticketId = state.selectedTicket!.id;
    final message = await repository.sendMessage(
      ticketId: ticketId,
      text: event.text,
    );

    final updatedTickets = state.tickets.map((t) {
      if (t.id == ticketId) {
        return t.copyWith(
          messages: [...t.messages, message],
        );
      }
      return t;
    }).toList();

    final currentSelected = updatedTickets.firstWhere((t) => t.id == ticketId);

    emit(state.copyWith(
      tickets: updatedTickets,
      selectedTicket: currentSelected,
      chatDraft: '',
    ));
  }

  void _onRetryChatMessage(
    DriverSupportRetryChatMessage event,
    Emitter<DriverSupportState> emit,
  ) {
    if (state.selectedTicket == null) return;
    final ticketId = state.selectedTicket!.id;

    final updatedMessages = state.selectedTicket!.messages.map((m) {
      if (m.id == event.messageId) {
        return m.copyWith(
          deliveryStatus: DriverSupportMessageDeliveryStatus.delivered,
        );
      }
      return m;
    }).toList();

    final updatedTicket = state.selectedTicket!.copyWith(messages: updatedMessages);
    final updatedTickets = state.tickets.map((t) {
      return t.id == ticketId ? updatedTicket : t;
    }).toList();

    emit(state.copyWith(
      tickets: updatedTickets,
      selectedTicket: updatedTicket,
      toastMessage: 'Message resent successfully via cellular fallback',
    ));
  }

  void _onQuickActionTriggered(
    DriverSupportQuickActionTriggered event,
    Emitter<DriverSupportState> emit,
  ) {
    emit(state.copyWith(
      toastMessage: 'Quick action: "${event.action}" attached to ticket ledger',
    ));
  }

  Future<void> _onEmergencySosTriggered(
    DriverSupportEmergencySosTriggered event,
    Emitter<DriverSupportState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    await repository.triggerEmergencySos(
      cabUnit: state.cabUnit,
      coordinates: '49.6942° N, 112.8328° W',
    );
    emit(state.copyWith(
      isLoading: false,
      isSosActive: true,
      toastMessage:
          '🚨 SOS Alert broadcasted! Lethbridge Police Services (LPS) alerted. Telemetry locked.',
    ));
  }

  void _onSetFormInspectorState(
    DriverSupportSetFormInspectorState event,
    Emitter<DriverSupportState> emit,
  ) {
    final nextState = event.inspectorState;
    if (nextState == DriverSupportFormInspectorState.empty) {
      emit(state.copyWith(
        formInspectorState: nextState,
        subject: '',
        description: '',
        hasAttachment: false,
      ));
    } else if (nextState == DriverSupportFormInspectorState.ready) {
      emit(state.copyWith(
        formInspectorState: nextState,
        subject: 'Incorrect toll adjustment on Whoop-U',
        description:
            'Crossing Whoop-Up Dr during the 14:15 construction detour incurred an automated surcharge that was deducted from net payout instead of credited.',
        hasAttachment: true,
      ));
    } else if (nextState == DriverSupportFormInspectorState.sending) {
      emit(state.copyWith(
        formInspectorState: nextState,
        isLoading: true,
      ));
    } else if (nextState == DriverSupportFormInspectorState.error) {
      emit(state.copyWith(
        formInspectorState: nextState,
        isLoading: false,
        toastMessage:
            'Dispatch telemetry fault: Unable to submit ticket near river coulee.',
      ));
    }
  }

  void _onSetDispatchState(
    DriverSupportSetDispatchState event,
    Emitter<DriverSupportState> emit,
  ) {
    emit(state.copyWith(dispatchState: event.dispatchState));
  }

  void _onClearToast(
    DriverSupportClearToast event,
    Emitter<DriverSupportState> emit,
  ) {
    emit(state.copyWith(clearToast: true));
  }
}
