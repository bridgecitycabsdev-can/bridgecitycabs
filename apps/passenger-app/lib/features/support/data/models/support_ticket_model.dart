enum TicketCategory {
  lostItem,
  paymentIssue,
  complaint,
  safety,
  general;

  String get displayName {
    switch (this) {
      case TicketCategory.lostItem:
        return 'Lost item';
      case TicketCategory.paymentIssue:
        return 'Payment issue';
      case TicketCategory.complaint:
        return 'Complaint';
      case TicketCategory.safety:
        return 'Safety / Driver';
      case TicketCategory.general:
        return 'General inquiry';
    }
  }

  String get emoji {
    switch (this) {
      case TicketCategory.lostItem:
        return '🎒';
      case TicketCategory.paymentIssue:
        return '💳';
      case TicketCategory.complaint:
        return '🔀';
      case TicketCategory.safety:
        return '🛡';
      case TicketCategory.general:
        return '💬';
    }
  }
}

enum TicketStatus {
  open,
  inProgress,
  resolved,
  closed;

  String get displayName {
    switch (this) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In progress';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
    }
  }
}

enum MessageDeliveryStatus {
  sending,
  delivered,
  read;
}

class TicketMessage {
  final String id;
  final String text;
  final String senderName;
  final bool isSupport;
  final String timestamp;
  final MessageDeliveryStatus status;

  const TicketMessage({
    required this.id,
    required this.text,
    required this.senderName,
    this.isSupport = false,
    required this.timestamp,
    this.status = MessageDeliveryStatus.delivered,
  });

  TicketMessage copyWith({
    String? id,
    String? text,
    String? senderName,
    bool? isSupport,
    String? timestamp,
    MessageDeliveryStatus? status,
  }) {
    return TicketMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      senderName: senderName ?? this.senderName,
      isSupport: isSupport ?? this.isSupport,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TicketMessage && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class SupportTicket {
  final String id;
  final String title;
  final TicketCategory category;
  final TicketStatus status;
  final String createdAt;
  final String? tripRoute;
  final String? tripId;
  final double? tripFareCad;
  final String? driverName;
  final List<TicketMessage> messages;
  final String? metaNote;
  final bool hasUnread;

  const SupportTicket({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.createdAt,
    this.tripRoute,
    this.tripId,
    this.tripFareCad,
    this.driverName,
    this.messages = const [],
    this.metaNote,
    this.hasUnread = false,
  });

  String get formattedFare =>
      tripFareCad != null ? '\$${tripFareCad!.toStringAsFixed(2)} CAD' : '';

  SupportTicket copyWith({
    String? id,
    String? title,
    TicketCategory? category,
    TicketStatus? status,
    String? createdAt,
    String? tripRoute,
    String? tripId,
    double? tripFareCad,
    String? driverName,
    List<TicketMessage>? messages,
    String? metaNote,
    bool? hasUnread,
  }) {
    return SupportTicket(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      tripRoute: tripRoute ?? this.tripRoute,
      tripId: tripId ?? this.tripId,
      tripFareCad: tripFareCad ?? this.tripFareCad,
      driverName: driverName ?? this.driverName,
      messages: messages ?? this.messages,
      metaNote: metaNote ?? this.metaNote,
      hasUnread: hasUnread ?? this.hasUnread,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportTicket && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum SupportHubTab {
  newReport,
  myTickets,
}
