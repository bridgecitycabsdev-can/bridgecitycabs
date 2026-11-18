import 'support_ticket_model.dart';

class SupportConfig {
  static const String screenTitle = 'Support Hub';
  static const String dispatchPhone = '403-328-8888';
  static const String supportEmail = 'support@bridgecabs.ca';

  static const String passengerGuaranteeTitle = 'Passenger Guarantee';
  static const String passengerGuaranteeSubtitle =
      'Direct response from local Lethbridge dispatch in 15 mins or less.';

  static const String responseTimeSubtitle =
      'Average response under 5 mins\nLive Lethbridge dispatch • Local operators';

  static const String chatDisclaimer =
      'Messages in support tickets cannot be edited or deleted.';

  static const List<SupportTicket> mockTickets = [
    SupportTicket(
      id: 'BC-9941',
      title: 'Left black backpack in Toyota Camry',
      category: TicketCategory.lostItem,
      status: TicketStatus.open,
      createdAt: '15m ago',
      tripRoute: 'Scenic Dr S → 3 Ave S',
      tripId: 'BC-84920',
      tripFareCad: 16.20,
      driverName: 'Michael K.',
      hasUnread: true,
      messages: [
        TicketMessage(
          id: 'msg_1',
          text:
              'Hi, I think I left my black North Face backpack on the back seat of the cab after getting dropped off at Park Place Mall. Has the driver turned it in?',
          senderName: 'You',
          isSupport: false,
          timestamp: '3:02 PM',
          status: MessageDeliveryStatus.delivered,
        ),
        TicketMessage(
          id: 'msg_2',
          text:
              "Hello! We've contacted Michael K. right away. He checked the back seat and confirmed your backpack is safe in his vehicle. He can meet you at the 5th Ave cab stand or drop it at our downtown dispatch office. Which do you prefer?",
          senderName: 'Dispatcher Sarah',
          isSupport: true,
          timestamp: '3:08 PM',
          status: MessageDeliveryStatus.delivered,
        ),
        TicketMessage(
          id: 'msg_3',
          text:
              "That's such a relief, thank you! The downtown dispatch office works best. I can pick it up in 30 minutes.",
          senderName: 'You',
          isSupport: false,
          timestamp: '3:10 PM',
          status: MessageDeliveryStatus.read,
        ),
      ],
    ),
    SupportTicket(
      id: 'TKT-88402',
      title: 'Double charged on trip to Park Place',
      category: TicketCategory.paymentIssue,
      status: TicketStatus.inProgress,
      createdAt: '2h ago',
      tripRoute: '515 5th Ave S → Park Place Mall',
      tripId: 'BC-84901',
      tripFareCad: 24.50,
      metaNote: '\$24.50 CAD | #TKT-88402',
    ),
    SupportTicket(
      id: 'TKT-82109',
      title: 'Driver took Mayor Magrath detour',
      category: TicketCategory.complaint,
      status: TicketStatus.resolved,
      createdAt: 'Yesterday',
      tripRoute: 'Scenic Heights → West Lethbridge',
      tripId: 'BC-83210',
      tripFareCad: 28.00,
      metaNote: 'Credit applied | Closed Oct 24',
    ),
  ];
}
