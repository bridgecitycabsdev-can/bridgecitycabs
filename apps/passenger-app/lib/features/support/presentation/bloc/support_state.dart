import 'package:equatable/equatable.dart';
import '../../data/models/support_ticket_model.dart';

enum SupportStatus {
  initial,
  loading,
  loaded,
  submitting,
  submitSuccess,
  submitFailure,
  failure,
}

class SupportState extends Equatable {
  final SupportStatus status;
  final SupportHubTab selectedTab;
  final List<SupportTicket> tickets;
  final TicketCategory? selectedFilter;

  // Form State
  final TicketCategory createCategory;
  final String? createTripId;
  final String? createTripRoute;
  final double? createTripFareCad;
  final String? createDriverName;
  final String createTitle;
  final String createMessage;

  // Thread State
  final String? activeTicketId;
  final SupportTicket? activeTicket;
  final String threadInputMessage;
  final bool isSendingThreadMessage;

  // Meta
  final String? errorMessage;
  final SupportTicket? newlyCreatedTicket;

  const SupportState({
    this.status = SupportStatus.initial,
    this.selectedTab = SupportHubTab.myTickets,
    this.tickets = const [],
    this.selectedFilter,
    this.createCategory = TicketCategory.lostItem,
    this.createTripId = 'BC-84920',
    this.createTripRoute = 'Scenic Dr S → 3 Ave S',
    this.createTripFareCad = 16.20,
    this.createDriverName = 'Michael K.',
    this.createTitle = '',
    this.createMessage = '',
    this.activeTicketId,
    this.activeTicket,
    this.threadInputMessage = '',
    this.isSendingThreadMessage = false,
    this.errorMessage,
    this.newlyCreatedTicket,
  });

  List<SupportTicket> get filteredTickets {
    if (selectedFilter == null) return tickets;
    return tickets.where((t) => t.category == selectedFilter).toList();
  }

  int get activeTicketCount =>
      tickets.where((t) => t.status == TicketStatus.open || t.status == TicketStatus.inProgress).length;

  int get unreadCount => tickets.where((t) => t.hasUnread).length;

  bool get hasTickets => tickets.isNotEmpty;

  bool get isFormValid =>
      createTitle.trim().isNotEmpty && createMessage.trim().isNotEmpty;

  SupportState copyWith({
    SupportStatus? status,
    SupportHubTab? selectedTab,
    List<SupportTicket>? tickets,
    TicketCategory? Function()? selectedFilter,
    TicketCategory? createCategory,
    String? Function()? createTripId,
    String? Function()? createTripRoute,
    double? Function()? createTripFareCad,
    String? Function()? createDriverName,
    String? createTitle,
    String? createMessage,
    String? Function()? activeTicketId,
    SupportTicket? Function()? activeTicket,
    String? threadInputMessage,
    bool? isSendingThreadMessage,
    String? Function()? errorMessage,
    SupportTicket? Function()? newlyCreatedTicket,
  }) {
    return SupportState(
      status: status ?? this.status,
      selectedTab: selectedTab ?? this.selectedTab,
      tickets: tickets ?? this.tickets,
      selectedFilter: selectedFilter != null ? selectedFilter() : this.selectedFilter,
      createCategory: createCategory ?? this.createCategory,
      createTripId: createTripId != null ? createTripId() : this.createTripId,
      createTripRoute: createTripRoute != null ? createTripRoute() : this.createTripRoute,
      createTripFareCad: createTripFareCad != null ? createTripFareCad() : this.createTripFareCad,
      createDriverName: createDriverName != null ? createDriverName() : this.createDriverName,
      createTitle: createTitle ?? this.createTitle,
      createMessage: createMessage ?? this.createMessage,
      activeTicketId: activeTicketId != null ? activeTicketId() : this.activeTicketId,
      activeTicket: activeTicket != null ? activeTicket() : this.activeTicket,
      threadInputMessage: threadInputMessage ?? this.threadInputMessage,
      isSendingThreadMessage: isSendingThreadMessage ?? this.isSendingThreadMessage,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      newlyCreatedTicket: newlyCreatedTicket != null ? newlyCreatedTicket() : this.newlyCreatedTicket,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedTab,
        tickets,
        selectedFilter,
        createCategory,
        createTripId,
        createTripRoute,
        createTripFareCad,
        createDriverName,
        createTitle,
        createMessage,
        activeTicketId,
        activeTicket,
        threadInputMessage,
        isSendingThreadMessage,
        errorMessage,
        newlyCreatedTicket,
      ];
}
