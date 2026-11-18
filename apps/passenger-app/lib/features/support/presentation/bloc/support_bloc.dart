import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/support_ticket_model.dart';
import '../../data/repositories/support_repository.dart';
import 'support_event.dart';
import 'support_state.dart';

class SupportBloc extends Bloc<SupportEvent, SupportState> {
  final SupportRepository _repository;

  SupportBloc({required SupportRepository repository})
      : _repository = repository,
        super(const SupportState()) {
    on<SupportLoadHubRequested>(_onLoadHubRequested);
    on<SupportTabChanged>(_onTabChanged);
    on<SupportFilterSelected>(_onFilterSelected);
    on<SupportCategoryChanged>(_onCategoryChanged);
    on<SupportTripSelected>(_onTripSelected);
    on<SupportTitleChanged>(_onTitleChanged);
    on<SupportMessageChanged>(_onMessageChanged);
    on<SupportCreateTicketSubmitted>(_onCreateTicketSubmitted);
    on<SupportResetCreateForm>(_onResetCreateForm);
    on<SupportOpenTicketThread>(_onOpenTicketThread);
    on<SupportThreadMessageChanged>(_onThreadMessageChanged);
    on<SupportSendThreadMessage>(_onSendThreadMessage);
    on<SupportCloseTicketThread>(_onCloseTicketThread);
  }

  Future<void> _onLoadHubRequested(
    SupportLoadHubRequested event,
    Emitter<SupportState> emit,
  ) async {
    emit(state.copyWith(status: SupportStatus.loading));
    try {
      final tickets = await _repository.getTickets();
      emit(state.copyWith(
        status: SupportStatus.loaded,
        tickets: tickets,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SupportStatus.failure,
        errorMessage: () => e.toString(),
      ));
    }
  }

  void _onTabChanged(
    SupportTabChanged event,
    Emitter<SupportState> emit,
  ) {
    emit(state.copyWith(selectedTab: event.tab));
  }

  void _onFilterSelected(
    SupportFilterSelected event,
    Emitter<SupportState> emit,
  ) {
    emit(state.copyWith(
      selectedFilter: () => event.category == state.selectedFilter ? null : event.category,
    ));
  }

  void _onCategoryChanged(
    SupportCategoryChanged event,
    Emitter<SupportState> emit,
  ) {
    emit(state.copyWith(createCategory: event.category));
  }

  void _onTripSelected(
    SupportTripSelected event,
    Emitter<SupportState> emit,
  ) {
    emit(state.copyWith(
      createTripId: () => event.tripId,
      createTripRoute: () => event.tripRoute,
      createTripFareCad: () => event.fareCad,
      createDriverName: () => event.driverName,
    ));
  }

  void _onTitleChanged(
    SupportTitleChanged event,
    Emitter<SupportState> emit,
  ) {
    emit(state.copyWith(createTitle: event.title));
  }

  void _onMessageChanged(
    SupportMessageChanged event,
    Emitter<SupportState> emit,
  ) {
    emit(state.copyWith(createMessage: event.message));
  }

  Future<void> _onCreateTicketSubmitted(
    SupportCreateTicketSubmitted event,
    Emitter<SupportState> emit,
  ) async {
    if (!state.isFormValid) return;

    emit(state.copyWith(status: SupportStatus.submitting));
    try {
      final createdTicket = await _repository.createTicket(
        title: state.createTitle.trim(),
        category: state.createCategory,
        tripId: state.createTripId,
        tripRoute: state.createTripRoute,
        tripFareCad: state.createTripFareCad,
        driverName: state.createDriverName,
        initialMessage: state.createMessage.trim(),
      );

      final updatedTickets = [createdTicket, ...state.tickets];

      emit(state.copyWith(
        status: SupportStatus.submitSuccess,
        tickets: updatedTickets,
        newlyCreatedTicket: () => createdTicket,
        createTitle: '',
        createMessage: '',
        selectedTab: SupportHubTab.myTickets,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SupportStatus.submitFailure,
        errorMessage: () => e.toString(),
      ));
    }
  }

  void _onResetCreateForm(
    SupportResetCreateForm event,
    Emitter<SupportState> emit,
  ) {
    emit(state.copyWith(
      createTitle: '',
      createMessage: '',
      createCategory: TicketCategory.lostItem,
    ));
  }

  Future<void> _onOpenTicketThread(
    SupportOpenTicketThread event,
    Emitter<SupportState> emit,
  ) async {
    SupportTicket? ticket;
    try {
      ticket = state.tickets.firstWhere((t) => t.id == event.ticketId);
    } catch (_) {
      ticket = await _repository.getTicketById(event.ticketId);
    }

    final current = ticket;
    if (current != null) {
      await _repository.markTicketAsRead(current.id);
      final updatedList = state.tickets.map((t) {
        if (t.id == current.id) {
          return t.copyWith(hasUnread: false);
        }
        return t;
      }).toList();

      emit(state.copyWith(
        tickets: updatedList,
        activeTicketId: () => current.id,
        activeTicket: () => current.copyWith(hasUnread: false),
        threadInputMessage: '',
      ));
    }
  }

  void _onThreadMessageChanged(
    SupportThreadMessageChanged event,
    Emitter<SupportState> emit,
  ) {
    emit(state.copyWith(threadInputMessage: event.message));
  }

  Future<void> _onSendThreadMessage(
    SupportSendThreadMessage event,
    Emitter<SupportState> emit,
  ) async {
    final text = state.threadInputMessage.trim();
    if (text.isEmpty) return;

    emit(state.copyWith(isSendingThreadMessage: true));
    try {
      final newMsg = await _repository.sendMessage(
        ticketId: event.ticketId,
        text: text,
        senderName: 'You',
        isSupport: false,
      );

      final active = state.activeTicket;
      if (active != null && active.id == event.ticketId) {
        final updatedMsgs = [...active.messages, newMsg];
        final updatedTicket = active.copyWith(messages: updatedMsgs);

        final updatedTickets = state.tickets.map((t) {
          if (t.id == active.id) {
            return updatedTicket;
          }
          return t;
        }).toList();

        emit(state.copyWith(
          isSendingThreadMessage: false,
          threadInputMessage: '',
          activeTicket: () => updatedTicket,
          tickets: updatedTickets,
        ));
      } else {
        emit(state.copyWith(
          isSendingThreadMessage: false,
          threadInputMessage: '',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isSendingThreadMessage: false,
        errorMessage: () => e.toString(),
      ));
    }
  }

  void _onCloseTicketThread(
    SupportCloseTicketThread event,
    Emitter<SupportState> emit,
  ) {
    emit(state.copyWith(
      activeTicketId: () => null,
      activeTicket: () => null,
      threadInputMessage: '',
    ));
  }
}
