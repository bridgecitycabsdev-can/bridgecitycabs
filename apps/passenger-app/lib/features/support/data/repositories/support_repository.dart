import 'dart:async';
import '../../../../data/datasources/support_remote_datasource.dart';
import '../models/support_config.dart';
import '../models/support_ticket_model.dart';

abstract class SupportRepository {
  Future<List<SupportTicket>> getTickets();
  Future<SupportTicket?> getTicketById(String id);
  Future<SupportTicket> createTicket({
    required String title,
    required TicketCategory category,
    String? tripId,
    String? tripRoute,
    double? tripFareCad,
    String? driverName,
    required String initialMessage,
  });
  Future<TicketMessage> sendMessage({
    required String ticketId,
    required String text,
    required String senderName,
    bool isSupport = false,
  });
  Future<void> markTicketAsRead(String ticketId);
}

class MockSupportRepository implements SupportRepository {
  final List<SupportTicket> _tickets;

  MockSupportRepository({List<SupportTicket>? initialTickets})
      : _tickets = initialTickets != null
            ? List.from(initialTickets)
            : List.from(SupportConfig.mockTickets);

  @override
  Future<List<SupportTicket>> getTickets() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return List.unmodifiable(_tickets);
  }

  @override
  Future<SupportTicket?> getTicketById(String id) async {
    await Future.delayed(const Duration(milliseconds: 20));
    try {
      return _tickets.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<SupportTicket> createTicket({
    required String title,
    required TicketCategory category,
    String? tripId,
    String? tripRoute,
    double? tripFareCad,
    String? driverName,
    required String initialMessage,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final newId = 'TKT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final initialMsg = TicketMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: initialMessage,
      senderName: 'You',
      isSupport: false,
      timestamp: 'Just now',
      status: MessageDeliveryStatus.delivered,
    );

    final newTicket = SupportTicket(
      id: newId,
      title: title,
      category: category,
      status: TicketStatus.open,
      createdAt: 'Just now',
      tripRoute: tripRoute ?? '515 5th Ave S → Park Place Mall',
      tripId: tripId ?? 'BC-84920',
      tripFareCad: tripFareCad ?? 16.20,
      driverName: driverName ?? 'Michael K.',
      messages: [initialMsg],
      hasUnread: false,
    );

    _tickets.insert(0, newTicket);
    return newTicket;
  }

  @override
  Future<TicketMessage> sendMessage({
    required String ticketId,
    required String text,
    required String senderName,
    bool isSupport = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));

    final newMsg = TicketMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      senderName: senderName,
      isSupport: isSupport,
      timestamp: 'Just now',
      status: MessageDeliveryStatus.delivered,
    );

    final index = _tickets.indexWhere((t) => t.id == ticketId);
    if (index != -1) {
      final ticket = _tickets[index];
      final updatedMessages = List<TicketMessage>.from(ticket.messages)..add(newMsg);
      _tickets[index] = ticket.copyWith(messages: updatedMessages);
    }

    return newMsg;
  }

  @override
  Future<void> markTicketAsRead(String ticketId) async {
    await Future.delayed(const Duration(milliseconds: 10));
    final index = _tickets.indexWhere((t) => t.id == ticketId);
    if (index != -1) {
      _tickets[index] = _tickets[index].copyWith(hasUnread: false);
    }
  }
}

class ApiSupportRepository implements SupportRepository {
  ApiSupportRepository(this._remote);

  final SupportRemoteDataSource _remote;

  @override
  Future<List<SupportTicket>> getTickets() async {
    final body = await _remote.mine();
    final rows = body is Map && body['data'] is List
        ? body['data'] as List
        : const <dynamic>[];
    return rows.map(_ticket).whereType<SupportTicket>().toList();
  }

  @override
  Future<SupportTicket?> getTicketById(String id) async {
    return _ticket(await _remote.get(id));
  }

  @override
  Future<SupportTicket> createTicket({
    required String title,
    required TicketCategory category,
    String? tripId,
    String? tripRoute,
    double? tripFareCad,
    String? driverName,
    required String initialMessage,
  }) async {
    final created = await _remote.create({
      'subject': title,
      'category': _category(category),
      'body': initialMessage,
      if (_isUuid(tripId)) 'bookingId': tripId,
    });
    final ticket = _ticket(created);
    if (ticket == null) {
      throw StateError('Support ticket was created but could not be read');
    }
    return ticket;
  }

  @override
  Future<TicketMessage> sendMessage({
    required String ticketId,
    required String text,
    required String senderName,
    bool isSupport = false,
  }) async {
    final updated = _ticket(await _remote.addMessage(ticketId, text));
    if (updated != null && updated.messages.isNotEmpty) {
      return updated.messages.last;
    }
    return TicketMessage(
      id: ticketId,
      text: text,
      senderName: senderName,
      isSupport: isSupport,
      timestamp: 'Just now',
    );
  }

  @override
  Future<void> markTicketAsRead(String ticketId) async {}

  SupportTicket? _ticket(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final subject = raw['subject'];
    if (id is! String || subject is! String) return null;
    final messages = raw['messages'];
    return SupportTicket(
      id: id,
      title: subject,
      category: _fromCategory(raw['category'] is String ? raw['category'] as String : ''),
      status: _fromStatus(raw['status'] is String ? raw['status'] as String : ''),
      createdAt: raw['createdAt'] is String ? raw['createdAt'] as String : '',
      tripId: raw['bookingId'] is String ? raw['bookingId'] as String : null,
      messages: messages is List
          ? messages.map(_message).whereType<TicketMessage>().toList()
          : const [],
    );
  }

  TicketMessage? _message(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final body = raw['body'];
    if (id is! String || body is! String) return null;
    final sender = raw['senderType'] is String ? raw['senderType'] as String : '';
    return TicketMessage(
      id: id,
      text: body,
      senderName: sender == 'STAFF' ? 'Support' : 'You',
      isSupport: sender == 'STAFF',
      timestamp: raw['createdAt'] is String ? raw['createdAt'] as String : '',
    );
  }

  String _category(TicketCategory category) {
    switch (category) {
      case TicketCategory.lostItem:
        return 'LOST_ITEM';
      case TicketCategory.paymentIssue:
        return 'PAYMENT_ISSUE';
      case TicketCategory.complaint:
      case TicketCategory.safety:
        return 'COMPLAINT';
      case TicketCategory.general:
        return 'OTHER';
    }
  }

  TicketCategory _fromCategory(String value) {
    switch (value) {
      case 'LOST_ITEM':
        return TicketCategory.lostItem;
      case 'PAYMENT_ISSUE':
        return TicketCategory.paymentIssue;
      case 'COMPLAINT':
        return TicketCategory.complaint;
      default:
        return TicketCategory.general;
    }
  }

  TicketStatus _fromStatus(String value) {
    switch (value) {
      case 'IN_PROGRESS':
        return TicketStatus.inProgress;
      case 'RESOLVED':
        return TicketStatus.resolved;
      case 'CLOSED':
        return TicketStatus.closed;
      default:
        return TicketStatus.open;
    }
  }

  bool _isUuid(String? value) {
    if (value == null) return false;
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(value);
  }
}
