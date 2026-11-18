import '../models/driver_support_faq.dart';
import '../models/driver_support_message.dart';
import '../models/driver_support_ticket.dart';
import '../models/driver_support_topic.dart';

abstract class DriverSupportRepository {
  Future<List<DriverSupportTicket>> getTickets();
  Future<List<DriverSupportFaqItem>> getFaqTopics();
  Future<DriverSupportTicket> createTicket({
    required DriverSupportTopic topic,
    required String subject,
    required String description,
    String? linkedTripId,
    double? linkedTripFare,
    String? attachmentName,
  });
  Future<DriverSupportMessage> sendMessage({
    required String ticketId,
    required String text,
    String? attachmentName,
  });
  Future<bool> triggerEmergencySos({
    required String cabUnit,
    required String coordinates,
  });
}

class FakeDriverSupportRepository implements DriverSupportRepository {
  final List<DriverSupportTicket> _tickets = [];
  final List<DriverSupportFaqItem> _faqs = [];

  FakeDriverSupportRepository() {
    _initializeSeedData();
  }

  void _initializeSeedData() {
    _faqs.addAll([
      const DriverSupportFaqItem(
        id: 'statements',
        title: 'Statements and payouts',
        subtitle: 'Weekly direct deposit schedule & fee schedule',
        iconType: 'wallet',
      ),
      const DriverSupportFaqItem(
        id: 'documents',
        title: 'Documents and approval',
        subtitle: 'Class 4, CVIP inspection & municipal permit',
        iconType: 'shield',
      ),
      const DriverSupportFaqItem(
        id: 'no_show',
        title: 'Passenger no-show',
        subtitle: 'Wait timer rules & cancellation fee collection',
        iconType: 'passenger_no_show',
      ),
      const DriverSupportFaqItem(
        id: 'safety',
        title: 'Report a safety issue',
        subtitle: 'Coulee incidents, passenger conduct & roadside',
        iconType: 'warning',
        isDestructive: true,
      ),
    ]);

    final sampleMessages = [
      const DriverSupportMessage(
        id: 'msg-1',
        sender: DriverSupportSender.driver,
        authorName: 'Marcus Vance',
        text:
            'Hi, on trip #BC-123456 the passenger paid \$22.10 cash but the meter showed an automatic bridge surcharge deduction that didn\'t apply on Whoop-Up Dr. Can you audit the odometer log?',
        timestamp: '10:14 AM',
        deliveryStatus: DriverSupportMessageDeliveryStatus.delivered,
      ),
      const DriverSupportMessage(
        id: 'msg-2',
        sender: DriverSupportSender.agent,
        authorName: 'Bridge City Cabs Support • Agent Sarah',
        text:
            'Hello Marcus! We\'ve received your trip audit request. Our Lethbridge dispatch team is reviewing your GPS breadcrumbs and the automated meter tariff. We\'ll adjust your shift ledger within 2 hours.',
        timestamp: '10:28 AM',
        deliveryStatus: DriverSupportMessageDeliveryStatus.delivered,
      ),
      const DriverSupportMessage(
        id: 'msg-3',
        sender: DriverSupportSender.driver,
        authorName: 'Marcus Vance',
        text: 'Thanks Sarah, I\'ve also uploaded the paper terminal voucher if needed.',
        timestamp: '10:31 AM',
        deliveryStatus: DriverSupportMessageDeliveryStatus.delivered,
      ),
      const DriverSupportMessage(
        id: 'msg-4',
        sender: DriverSupportSender.driver,
        authorName: 'Marcus Vance',
        text: 'Attached voucher scan #V-8819 for car unit #44.',
        timestamp: '10:33 AM',
        deliveryStatus: DriverSupportMessageDeliveryStatus.sending,
        attachmentName: 'voucher_scan_v8819.png',
        attachmentSize: '1.4 MB',
      ),
      const DriverSupportMessage(
        id: 'msg-5',
        sender: DriverSupportSender.driver,
        authorName: 'Marcus Vance',
        text:
            'Signal lost over Oldman River coulee: Shift total recalculation sync request.',
        timestamp: '10:35 AM',
        deliveryStatus: DriverSupportMessageDeliveryStatus.failed,
      ),
    ];

    _tickets.addAll([
      DriverSupportTicket(
        id: 'TK-9042',
        subject: 'Fare audit for disputed cash trip #BC-123456',
        topic: DriverSupportTopic.rideIssue,
        status: DriverSupportTicketStatus.open,
        hasNewReply: true,
        linkedTripId: 'BC-123456',
        linkedTripFare: 22.10,
        linkedTripRoute: 'University Dr to Downtown Lethbridge',
        linkedTripDate: '18 Jul 2026, 14:32',
        lastUpdatedText: 'Updated 15 mins ago • Support agent Marcus...',
        tariffCorridor: 'Whoop-Up Dr Viaduct • Tariff Corridor 04',
        messages: sampleMessages,
      ),
      const DriverSupportTicket(
        id: 'TK-8819',
        subject: 'CVIP annual vehicle inspection renewal approval',
        topic: DriverSupportTopic.documentApproval,
        status: DriverSupportTicketStatus.inProgress,
        hasNewReply: false,
        vehicleUnit: 'Crown Victoria #Cab-14',
        lastUpdatedText: 'Updated Yesterday • Compliance team review...',
        messages: [],
      ),
      const DriverSupportTicket(
        id: 'TK-7602',
        subject: 'In-cab terminal tap-to-pay firmware sync error',
        topic: DriverSupportTopic.appIssue,
        status: DriverSupportTicketStatus.resolved,
        hasNewReply: false,
        otaPatch: 'OTA Patch 4.12',
        closedDate: '12 Jul 2026',
        resolutionSummary: 'Solved by OTA update',
        lastUpdatedText: 'Closed 12 Jul 2026 • Solved by OTA update',
        messages: [],
      ),
    ]);
  }

  @override
  Future<List<DriverSupportTicket>> getTickets() async {
    await Future.delayed(const Duration(milliseconds: 60));
    return List.from(_tickets);
  }

  @override
  Future<List<DriverSupportFaqItem>> getFaqTopics() async {
    await Future.delayed(const Duration(milliseconds: 40));
    return List.from(_faqs);
  }

  @override
  Future<DriverSupportTicket> createTicket({
    required DriverSupportTopic topic,
    required String subject,
    required String description,
    String? linkedTripId,
    double? linkedTripFare,
    String? attachmentName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final newId = 'TK-${9100 + _tickets.length}';
    final ticket = DriverSupportTicket(
      id: newId,
      subject: subject,
      topic: topic,
      status: DriverSupportTicketStatus.open,
      hasNewReply: false,
      linkedTripId: linkedTripId,
      linkedTripFare: linkedTripFare,
      linkedTripRoute: '440 University Dr to Downtown Lethbridge',
      linkedTripDate: '18 Jul 2026, 14:32',
      lastUpdatedText: 'Just now • Awaiting dispatch desk...',
      messages: [
        DriverSupportMessage(
          id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
          sender: DriverSupportSender.driver,
          authorName: 'Marcus Vance',
          text: description,
          timestamp: 'Just now',
          deliveryStatus: DriverSupportMessageDeliveryStatus.delivered,
          attachmentName: attachmentName,
        ),
      ],
    );
    _tickets.insert(0, ticket);
    return ticket;
  }

  @override
  Future<DriverSupportMessage> sendMessage({
    required String ticketId,
    required String text,
    String? attachmentName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 80));
    final message = DriverSupportMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      sender: DriverSupportSender.driver,
      authorName: 'Marcus Vance',
      text: text,
      timestamp: 'Just now',
      deliveryStatus: DriverSupportMessageDeliveryStatus.delivered,
      attachmentName: attachmentName,
    );

    final index = _tickets.indexWhere((t) => t.id == ticketId);
    if (index != -1) {
      final ticket = _tickets[index];
      final updatedMessages = List<DriverSupportMessage>.from(ticket.messages)..add(message);
      _tickets[index] = ticket.copyWith(messages: updatedMessages);
    }
    return message;
  }

  @override
  Future<bool> triggerEmergencySos({
    required String cabUnit,
    required String coordinates,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }
}
