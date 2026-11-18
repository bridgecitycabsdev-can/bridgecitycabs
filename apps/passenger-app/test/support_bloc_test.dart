import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/support/support.dart';

void main() {
  group('SupportBloc Unit Tests', () {
    late MockSupportRepository repository;
    late SupportBloc bloc;

    setUp(() {
      repository = MockSupportRepository();
      bloc = SupportBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('SupportLoadHubRequested loads tickets from repository', () async {
      bloc.add(const SupportLoadHubRequested());
      await pumpEventQueue();

      expect(bloc.state.status, SupportStatus.loaded);
      expect(bloc.state.tickets.length, 3);
      expect(bloc.state.activeTicketCount, 2);
      expect(bloc.state.unreadCount, 1);
    });

    test('SupportTabChanged switches tabs correctly', () async {
      expect(bloc.state.selectedTab, SupportHubTab.myTickets);

      bloc.add(const SupportTabChanged(SupportHubTab.newReport));
      await pumpEventQueue();
      expect(bloc.state.selectedTab, SupportHubTab.newReport);

      bloc.add(const SupportTabChanged(SupportHubTab.myTickets));
      await pumpEventQueue();
      expect(bloc.state.selectedTab, SupportHubTab.myTickets);
    });

    test('SupportFilterSelected filters list and toggles selection', () async {
      bloc.add(const SupportLoadHubRequested());
      await pumpEventQueue();

      bloc.add(const SupportFilterSelected(TicketCategory.lostItem));
      await pumpEventQueue();
      expect(bloc.state.selectedFilter, TicketCategory.lostItem);
      expect(bloc.state.filteredTickets.length, 1);
      expect(bloc.state.filteredTickets.first.category, TicketCategory.lostItem);

      // Toggle off
      bloc.add(const SupportFilterSelected(TicketCategory.lostItem));
      await pumpEventQueue();
      expect(bloc.state.selectedFilter, isNull);
      expect(bloc.state.filteredTickets.length, 3);
    });

    test('SupportCategoryChanged and form fields update state correctly', () async {
      bloc.add(const SupportCategoryChanged(TicketCategory.complaint));
      bloc.add(const SupportTitleChanged('Driver was late'));
      bloc.add(const SupportMessageChanged('Arrived 15 minutes after ETA.'));
      await pumpEventQueue();

      expect(bloc.state.createCategory, TicketCategory.complaint);
      expect(bloc.state.createTitle, 'Driver was late');
      expect(bloc.state.createMessage, 'Arrived 15 minutes after ETA.');
      expect(bloc.state.isFormValid, isTrue);
    });

    test('SupportCreateTicketSubmitted successfully creates ticket and updates list', () async {
      bloc.add(const SupportLoadHubRequested());
      await pumpEventQueue();

      final initialCount = bloc.state.tickets.length;

      bloc.add(const SupportCategoryChanged(TicketCategory.safety));
      bloc.add(const SupportTitleChanged('Speeding report'));
      bloc.add(const SupportMessageChanged('Driver drove above speed limit on Whoop-Up Dr.'));
      await pumpEventQueue();

      bloc.add(const SupportCreateTicketSubmitted());
      await pumpEventQueue();

      expect(bloc.state.status, SupportStatus.submitSuccess);
      expect(bloc.state.tickets.length, initialCount + 1);
      expect(bloc.state.tickets.first.title, 'Speeding report');
      expect(bloc.state.tickets.first.category, TicketCategory.safety);
      expect(bloc.state.createTitle, isEmpty);
      expect(bloc.state.createMessage, isEmpty);
      expect(bloc.state.selectedTab, SupportHubTab.myTickets);
    });

    test('SupportOpenTicketThread marks ticket as read and loads active ticket', () async {
      bloc.add(const SupportLoadHubRequested());
      await pumpEventQueue();

      expect(bloc.state.unreadCount, 1);

      bloc.add(const SupportOpenTicketThread('BC-9941'));
      await pumpEventQueue();

      expect(bloc.state.activeTicketId, 'BC-9941');
      expect(bloc.state.activeTicket, isNotNull);
      expect(bloc.state.activeTicket!.id, 'BC-9941');
      expect(bloc.state.activeTicket!.hasUnread, isFalse);
      expect(bloc.state.unreadCount, 0);
    });

    test('SupportSendThreadMessage adds message to active ticket', () async {
      bloc.add(const SupportLoadHubRequested());
      await pumpEventQueue();

      bloc.add(const SupportOpenTicketThread('BC-9941'));
      await pumpEventQueue();

      final initialMsgCount = bloc.state.activeTicket!.messages.length;

      bloc.add(const SupportThreadMessageChanged('Thank you so much!'));
      bloc.add(const SupportSendThreadMessage('BC-9941'));
      await pumpEventQueue();

      expect(bloc.state.threadInputMessage, isEmpty);
      expect(bloc.state.activeTicket!.messages.length, initialMsgCount + 1);
      expect(bloc.state.activeTicket!.messages.last.text, 'Thank you so much!');
      expect(bloc.state.activeTicket!.messages.last.senderName, 'You');
    });
  });
}
