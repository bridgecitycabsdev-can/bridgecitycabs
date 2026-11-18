import 'package:equatable/equatable.dart';

import 'driver_support_message.dart';
import 'driver_support_topic.dart';

enum DriverSupportTicketStatus {
  open,
  inProgress,
  resolved;

  String get label {
    switch (this) {
      case DriverSupportTicketStatus.open:
        return 'Open';
      case DriverSupportTicketStatus.inProgress:
        return 'In progress';
      case DriverSupportTicketStatus.resolved:
        return 'Resolved';
    }
  }

  bool get isOpen => this == DriverSupportTicketStatus.open;
  bool get isInProgress => this == DriverSupportTicketStatus.inProgress;
  bool get isResolved => this == DriverSupportTicketStatus.resolved;
}

enum DriverSupportTicketFilter {
  all,
  open,
  inProgress;

  String get label {
    switch (this) {
      case DriverSupportTicketFilter.all:
        return 'All tickets';
      case DriverSupportTicketFilter.open:
        return 'Open';
      case DriverSupportTicketFilter.inProgress:
        return 'In progress';
    }
  }
}

class DriverSupportTicket extends Equatable {
  final String id;
  final String subject;
  final DriverSupportTopic topic;
  final DriverSupportTicketStatus status;
  final bool hasNewReply;
  final String? linkedTripId;
  final double? linkedTripFare;
  final String? linkedTripRoute;
  final String? linkedTripDate;
  final String lastUpdatedText;
  final String? vehicleUnit;
  final String? otaPatch;
  final String? closedDate;
  final String? resolutionSummary;
  final String tariffCorridor;
  final List<DriverSupportMessage> messages;

  const DriverSupportTicket({
    required this.id,
    required this.subject,
    required this.topic,
    required this.status,
    this.hasNewReply = false,
    this.linkedTripId,
    this.linkedTripFare,
    this.linkedTripRoute,
    this.linkedTripDate,
    required this.lastUpdatedText,
    this.vehicleUnit,
    this.otaPatch,
    this.closedDate,
    this.resolutionSummary,
    this.tariffCorridor = 'Whoop-Up Dr Viaduct • Tariff Corridor 04',
    this.messages = const [],
  });

  DriverSupportTicket copyWith({
    String? id,
    String? subject,
    DriverSupportTopic? topic,
    DriverSupportTicketStatus? status,
    bool? hasNewReply,
    String? linkedTripId,
    double? linkedTripFare,
    String? linkedTripRoute,
    String? linkedTripDate,
    String? lastUpdatedText,
    String? vehicleUnit,
    String? otaPatch,
    String? closedDate,
    String? resolutionSummary,
    String? tariffCorridor,
    List<DriverSupportMessage>? messages,
  }) {
    return DriverSupportTicket(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      status: status ?? this.status,
      hasNewReply: hasNewReply ?? this.hasNewReply,
      linkedTripId: linkedTripId ?? this.linkedTripId,
      linkedTripFare: linkedTripFare ?? this.linkedTripFare,
      linkedTripRoute: linkedTripRoute ?? this.linkedTripRoute,
      linkedTripDate: linkedTripDate ?? this.linkedTripDate,
      lastUpdatedText: lastUpdatedText ?? this.lastUpdatedText,
      vehicleUnit: vehicleUnit ?? this.vehicleUnit,
      otaPatch: otaPatch ?? this.otaPatch,
      closedDate: closedDate ?? this.closedDate,
      resolutionSummary: resolutionSummary ?? this.resolutionSummary,
      tariffCorridor: tariffCorridor ?? this.tariffCorridor,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [
        id,
        subject,
        topic,
        status,
        hasNewReply,
        linkedTripId,
        linkedTripFare,
        linkedTripRoute,
        linkedTripDate,
        lastUpdatedText,
        vehicleUnit,
        otaPatch,
        closedDate,
        resolutionSummary,
        tariffCorridor,
        messages,
      ];
}
