import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/notifications/notifications.dart';

void main() {
  group('NotificationsPage Widget Tests', () {
    testWidgets('renders Screen 1 Populated Inbox with Unread Items accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NotificationsPage(
            initialStatus: NotificationsViewStatus.loaded,
            simulateLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Mark all as read'), findsOneWidget);
      expect(find.text('Inbox Activity'), findsOneWidget);
      expect(find.text('3 new'), findsOneWidget);
      expect(find.text('Real-time ride updates & receipts'), findsOneWidget);
      expect(find.text('All (6)'), findsOneWidget);
      expect(find.text('Trips & Dispatch'), findsOneWidget);
      expect(find.text('Receipts'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('3 unread'), findsOneWidget);
      expect(find.text('Driver is arriving'), findsOneWidget);
      expect(find.text('Trip completed'), findsOneWidget);
      expect(find.text('Support replied'), findsOneWidget);
      expect(find.text('EARLIER'), findsOneWidget);
      expect(find.text('Archived'), findsOneWidget);
      expect(find.text('Card authorization notice'), findsOneWidget);
      expect(find.text('Driver assigned'), findsOneWidget);
      expect(find.text('Receipt delivered'), findsOneWidget);
      expect(find.text(NotificationsConfig.couleePromoTitle), findsOneWidget);
      expect(find.text(NotificationsConfig.couleePromoSubtitle), findsOneWidget);
    });

    testWidgets('renders Screen 2 All Caught Up State accurately',
        (tester) async {
      final readItems = NotificationsConfig.defaultNotifications
          .map((i) => i.copyWith(isRead: true))
          .toList();

      await tester.pumpWidget(
        MaterialApp(
          home: NotificationsPage(
            initialItems: readItems,
            initialStatus: NotificationsViewStatus.loaded,
            simulateLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('All caught up • 0 unread notifications'),
        findsOneWidget,
      );
      expect(find.text('0 active'), findsOneWidget);
      expect(find.text('No action required'), findsOneWidget);
    });

    testWidgets('renders Screen 3 Empty State accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NotificationsPage(
            initialItems: [],
            initialStatus: NotificationsViewStatus.empty,
            simulateLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NotificationEmptyView), findsOneWidget);
      expect(find.text('No notifications yet'), findsOneWidget);
      expect(find.text('Bridge City Dispatch'), findsOneWidget);
      expect(find.text('Check for updates'), findsOneWidget);
      expect(find.text('0 UNREAD'), findsOneWidget);
    });

    testWidgets('renders Screen 4 Skeleton / Loading State accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NotificationsPage(
            initialStatus: NotificationsViewStatus.loading,
            simulateLoading: true,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(NotificationSkeletonView), findsOneWidget);
      expect(
        find.text('Syncing dispatch notifications...'),
        findsOneWidget,
      );
      expect(
        find.text('Connected to Lethbridge Central Hub'),
        findsOneWidget,
      );
    });

    testWidgets('renders Screen 5 Offline Error State with Cached Feed accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NotificationsPage(
            initialStatus: NotificationsViewStatus.offlineError,
            simulateLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NotificationOfflineView), findsOneWidget);
      expect(
        find.text('Unable to sync latest ride updates'),
        findsOneWidget,
      );
      expect(find.text("Couldn't load notifications"), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(
        find.text('Call Lethbridge dispatch (403-328-8888)'),
        findsOneWidget,
      );
      expect(find.text('Cached feed • Today, 2:45 PM'), findsOneWidget);
      expect(find.text('Cab #42 Arrived'), findsOneWidget);
      expect(find.text('Receipt - University Hall'), findsOneWidget);
    });

    testWidgets('renders Screen 6 Push Permission Sheet accurately',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PushPermissionSheet(
              onEnable: () {},
              onDismiss: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Live distance tracking'), findsOneWidget);
      expect(find.text('Driver arrival ping'), findsOneWidget);
      expect(find.text('Instant fare receipts'), findsOneWidget);
      expect(find.text('In-app activity center'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('Turn on notifications'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
      expect(
        find.text('You can turn these off anytime in your device Settings.'),
        findsOneWidget,
      );
    });
  });
}
