import 'package:equatable/equatable.dart';

import '../data/models/driver_support_faq.dart';
import '../data/models/driver_support_form_state.dart';
import '../data/models/driver_support_status.dart';
import '../data/models/driver_support_ticket.dart';
import '../data/models/driver_support_topic.dart';

class DriverSupportState extends Equatable {
  final DriverSupportViewStatus viewStatus;
  final List<DriverSupportTicket> tickets;
  final List<DriverSupportFaqItem> faqs;
  final DriverSupportTicketFilter selectedFilter;
  final DriverSupportTicket? selectedTicket;

  // New Ticket Form State
  final DriverSupportTopic selectedTopic;
  final String subject;
  final String description;
  final bool hasAttachment;
  final String attachmentName;
  final String attachmentSize;
  final String linkedTripId;
  final double linkedTripFare;
  final String linkedTripRoute;
  final String linkedTripDate;

  // Inspectors
  final DriverSupportFormInspectorState formInspectorState;
  final DriverSupportDispatchState dispatchState;

  // Telemetry & Meta
  final String cabUnit;
  final String fleetSupportLabel;
  final String supportEmail;
  final String supportPhone;
  final bool isSosActive;

  // Chat draft
  final String chatDraft;

  // Loading & Toast
  final bool isLoading;
  final String? toastMessage;

  const DriverSupportState({
    this.viewStatus = DriverSupportViewStatus.center,
    this.tickets = const [],
    this.faqs = const [],
    this.selectedFilter = DriverSupportTicketFilter.all,
    this.selectedTicket,
    this.selectedTopic = DriverSupportTopic.rideIssue,
    this.subject = 'Incorrect toll adjustment on Whoop-U',
    this.description =
        'Crossing Whoop-Up Dr during the 14:15 construction detour incurred an automated surcharge that was deducted from net payout instead of credited.',
    this.hasAttachment = true,
    this.attachmentName = 'meter_receipt_whoopup.png',
    this.attachmentSize = '1.8 MB • Attached from dash camera',
    this.linkedTripId = 'BC-123456',
    this.linkedTripFare = 22.10,
    this.linkedTripRoute = '440 University Dr to Downtown...',
    this.linkedTripDate = '18 Jul 2026, 14:32',
    this.formInspectorState = DriverSupportFormInspectorState.ready,
    this.dispatchState = DriverSupportDispatchState.active,
    this.cabUnit = 'Unit #42',
    this.fleetSupportLabel = 'LETHBRIDGE FLEET SUPPORT',
    this.supportEmail = 'support@bridgecity...',
    this.supportPhone = '403-328-8888',
    this.isSosActive = false,
    this.chatDraft = '',
    this.isLoading = false,
    this.toastMessage,
  });

  List<DriverSupportTicket> get filteredTickets {
    if (dispatchState == DriverSupportDispatchState.empty) {
      return const [];
    }
    switch (selectedFilter) {
      case DriverSupportTicketFilter.all:
        return tickets;
      case DriverSupportTicketFilter.open:
        return tickets.where((t) => t.status == DriverSupportTicketStatus.open).toList();
      case DriverSupportTicketFilter.inProgress:
        return tickets.where((t) => t.status == DriverSupportTicketStatus.inProgress).toList();
    }
  }

  int get totalTicketsCount => tickets.length;
  int get openTicketsCount => tickets.where((t) => t.status == DriverSupportTicketStatus.open).length;
  int get inProgressTicketsCount =>
      tickets.where((t) => t.status == DriverSupportTicketStatus.inProgress).length;

  DriverSupportState copyWith({
    DriverSupportViewStatus? viewStatus,
    List<DriverSupportTicket>? tickets,
    List<DriverSupportFaqItem>? faqs,
    DriverSupportTicketFilter? selectedFilter,
    DriverSupportTicket? selectedTicket,
    DriverSupportTopic? selectedTopic,
    String? subject,
    String? description,
    bool? hasAttachment,
    String? attachmentName,
    String? attachmentSize,
    String? linkedTripId,
    double? linkedTripFare,
    String? linkedTripRoute,
    String? linkedTripDate,
    DriverSupportFormInspectorState? formInspectorState,
    DriverSupportDispatchState? dispatchState,
    String? cabUnit,
    String? fleetSupportLabel,
    String? supportEmail,
    String? supportPhone,
    bool? isSosActive,
    String? chatDraft,
    bool? isLoading,
    String? toastMessage,
    bool clearSelectedTicket = false,
    bool clearToast = false,
  }) {
    return DriverSupportState(
      viewStatus: viewStatus ?? this.viewStatus,
      tickets: tickets ?? this.tickets,
      faqs: faqs ?? this.faqs,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedTicket: clearSelectedTicket ? null : (selectedTicket ?? this.selectedTicket),
      selectedTopic: selectedTopic ?? this.selectedTopic,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      hasAttachment: hasAttachment ?? this.hasAttachment,
      attachmentName: attachmentName ?? this.attachmentName,
      attachmentSize: attachmentSize ?? this.attachmentSize,
      linkedTripId: linkedTripId ?? this.linkedTripId,
      linkedTripFare: linkedTripFare ?? this.linkedTripFare,
      linkedTripRoute: linkedTripRoute ?? this.linkedTripRoute,
      linkedTripDate: linkedTripDate ?? this.linkedTripDate,
      formInspectorState: formInspectorState ?? this.formInspectorState,
      dispatchState: dispatchState ?? this.dispatchState,
      cabUnit: cabUnit ?? this.cabUnit,
      fleetSupportLabel: fleetSupportLabel ?? this.fleetSupportLabel,
      supportEmail: supportEmail ?? this.supportEmail,
      supportPhone: supportPhone ?? this.supportPhone,
      isSosActive: isSosActive ?? this.isSosActive,
      chatDraft: chatDraft ?? this.chatDraft,
      isLoading: isLoading ?? this.isLoading,
      toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
    );
  }

  @override
  List<Object?> get props => [
        viewStatus,
        tickets,
        faqs,
        selectedFilter,
        selectedTicket,
        selectedTopic,
        subject,
        description,
        hasAttachment,
        attachmentName,
        attachmentSize,
        linkedTripId,
        linkedTripFare,
        linkedTripRoute,
        linkedTripDate,
        formInspectorState,
        dispatchState,
        cabUnit,
        fleetSupportLabel,
        supportEmail,
        supportPhone,
        isSosActive,
        chatDraft,
        isLoading,
        toastMessage,
      ];
}
