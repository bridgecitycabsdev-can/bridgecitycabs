import 'package:driver_app/features/support/support.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriverSupportBloc Tests', () {
    late FakeDriverSupportRepository repository;
    late DriverSupportBloc bloc;

    setUp(() {
      repository = FakeDriverSupportRepository();
      bloc = DriverSupportBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state defaults to Support Center with seed tickets and faqs', () async {
      expect(bloc.state.viewStatus, DriverSupportViewStatus.center);
      expect(bloc.state.cabUnit, 'Unit #42');
      expect(bloc.state.fleetSupportLabel, 'LETHBRIDGE FLEET SUPPORT');
      expect(bloc.state.supportPhone, '403-328-8888');

      bloc.add(const DriverSupportStarted());
      await Future.delayed(const Duration(milliseconds: 150));

      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.tickets.length, 3);
      expect(bloc.state.faqs.length, 4);
      expect(bloc.state.selectedTicket?.id, 'TK-9042');
    });

    test('Switching view status updates viewStatus correctly', () {
      bloc.add(const DriverSupportSwitchView(DriverSupportViewStatus.newTicket));
      expect(bloc.state.viewStatus, DriverSupportViewStatus.newTicket);

      bloc.add(const DriverSupportSwitchView(DriverSupportViewStatus.myTickets));
      expect(bloc.state.viewStatus, DriverSupportViewStatus.myTickets);

      bloc.add(const DriverSupportSwitchView(DriverSupportViewStatus.ticketDetail));
      expect(bloc.state.viewStatus, DriverSupportViewStatus.ticketDetail);

      bloc.add(const DriverSupportSwitchView(DriverSupportViewStatus.emergencySos));
      expect(bloc.state.viewStatus, DriverSupportViewStatus.emergencySos);
    });

    test('Topic selection, subject and description modification with 500 char clamp', () {
      bloc.add(const DriverSupportSelectTopic(DriverSupportTopic.safety));
      expect(bloc.state.selectedTopic, DriverSupportTopic.safety);

      bloc.add(const DriverSupportSubjectChanged('Coulee icing safety report'));
      expect(bloc.state.subject, 'Coulee icing safety report');

      // Test description clamp
      final longText = 'A' * 600;
      bloc.add(DriverSupportDescriptionChanged(longText));
      expect(bloc.state.description.length, 500);

      // Attachment toggle
      bloc.add(const DriverSupportToggleAttachment(false));
      expect(bloc.state.hasAttachment, isFalse);
      bloc.add(const DriverSupportToggleAttachment(true));
      expect(bloc.state.hasAttachment, isTrue);
    });

    test('Submitting new ticket creates ticket and navigates to myTickets', () async {
      bloc.add(const DriverSupportStarted());
      await Future.delayed(const Duration(milliseconds: 150));

      final initialCount = bloc.state.tickets.length;

      bloc.add(const DriverSupportSelectTopic(DriverSupportTopic.paymentStatement));
      bloc.add(const DriverSupportSubjectChanged('Shift ledger payout query'));
      bloc.add(const DriverSupportDescriptionChanged('Direct deposit was short \$12.40.'));

      bloc.add(const DriverSupportSubmitTicketPressed());
      await Future.delayed(const Duration(milliseconds: 200));

      expect(bloc.state.tickets.length, initialCount + 1);
      expect(bloc.state.viewStatus, DriverSupportViewStatus.myTickets);
      expect(bloc.state.toastMessage, contains('submitted to Lethbridge Dispatch'));
    });

    test('Filter tickets filters by open, in-progress, and all', () async {
      bloc.add(const DriverSupportStarted());
      await Future.delayed(const Duration(milliseconds: 150));

      // All tickets: 3
      bloc.add(const DriverSupportSelectFilter(DriverSupportTicketFilter.all));
      expect(bloc.state.filteredTickets.length, 3);

      // Open tickets: 1
      bloc.add(const DriverSupportSelectFilter(DriverSupportTicketFilter.open));
      expect(bloc.state.filteredTickets.length, 1);
      expect(bloc.state.filteredTickets.first.status, DriverSupportTicketStatus.open);

      // In-progress tickets: 1
      bloc.add(const DriverSupportSelectFilter(DriverSupportTicketFilter.inProgress));
      expect(bloc.state.filteredTickets.length, 1);
      expect(bloc.state.filteredTickets.first.status, DriverSupportTicketStatus.inProgress);
    });

    test('Selecting ticket loads ticketDetail view with corresponding messages', () async {
      bloc.add(const DriverSupportStarted());
      await Future.delayed(const Duration(milliseconds: 150));

      bloc.add(const DriverSupportSelectTicket('TK-9042'));
      expect(bloc.state.viewStatus, DriverSupportViewStatus.ticketDetail);
      expect(bloc.state.selectedTicket?.id, 'TK-9042');
      expect(bloc.state.selectedTicket?.messages.length, 5);
    });

    test('Sending chat message appends message to active ticket', () async {
      bloc.add(const DriverSupportStarted());
      await Future.delayed(const Duration(milliseconds: 150));

      bloc.add(const DriverSupportSelectTicket('TK-9042'));
      final originalCount = bloc.state.selectedTicket!.messages.length;

      bloc.add(const DriverSupportSendChatMessage('Can you check the odometer reading?'));
      await Future.delayed(const Duration(milliseconds: 150));

      expect(bloc.state.selectedTicket!.messages.length, originalCount + 1);
      expect(
        bloc.state.selectedTicket!.messages.last.text,
        'Can you check the odometer reading?',
      );
    });

    test('Retrying failed message updates status to delivered', () async {
      bloc.add(const DriverSupportStarted());
      await Future.delayed(const Duration(milliseconds: 150));

      bloc.add(const DriverSupportSelectTicket('TK-9042'));

      // msg-5 was in failed status
      bloc.add(const DriverSupportRetryChatMessage('msg-5'));
      final msg5 = bloc.state.selectedTicket!.messages.firstWhere((m) => m.id == 'msg-5');
      expect(msg5.deliveryStatus, DriverSupportMessageDeliveryStatus.delivered);
      expect(bloc.state.toastMessage, contains('cellular fallback'));
    });

    test('Emergency SOS triggers distress signal and alerts Lethbridge Police Services', () async {
      bloc.add(const DriverSupportEmergencySosTriggered());
      await Future.delayed(const Duration(milliseconds: 150));

      expect(bloc.state.isSosActive, isTrue);
      expect(bloc.state.toastMessage, contains('Lethbridge Police Services (LPS) alerted'));
    });

    test('Form inspector state and simulated dispatch state toggles', () {
      // Form inspector empty
      bloc.add(const DriverSupportSetFormInspectorState(DriverSupportFormInspectorState.empty));
      expect(bloc.state.subject, '');
      expect(bloc.state.description, '');
      expect(bloc.state.hasAttachment, isFalse);

      // Form inspector ready
      bloc.add(const DriverSupportSetFormInspectorState(DriverSupportFormInspectorState.ready));
      expect(bloc.state.subject, contains('Incorrect toll adjustment'));
      expect(bloc.state.hasAttachment, isTrue);

      // Dispatch empty state
      bloc.add(const DriverSupportSetDispatchState(DriverSupportDispatchState.empty));
      expect(bloc.state.filteredTickets, isEmpty);

      // Dispatch active state
      bloc.add(const DriverSupportSetDispatchState(DriverSupportDispatchState.active));
      expect(bloc.state.dispatchState, DriverSupportDispatchState.active);
    });
  });
}
