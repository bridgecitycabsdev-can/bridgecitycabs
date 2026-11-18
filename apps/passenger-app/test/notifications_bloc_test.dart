import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/notifications/notifications.dart';

void main() {
  group('NotificationsBloc Tests', () {
    late MockNotificationsRepository repository;
    late NotificationsBloc bloc;

    setUp(() {
      repository = MockNotificationsRepository(
        delay: const Duration(milliseconds: 10),
      );
      bloc = NotificationsBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state with mock items defaults to loaded with 6 items and 3 unread', () async {
      bloc.add(const NotificationsStarted(simulateLoading: false));
      await pumpEventQueue();

      expect(bloc.state.status, NotificationsViewStatus.loaded);
      expect(bloc.state.items.length, 6);
      expect(bloc.state.unreadCount, 3);
      expect(bloc.state.unreadTodayCount, 3);
      expect(bloc.state.allCaughtUp, isFalse);
      expect(bloc.state.selectedCategory, NotificationCategory.all);
    });

    test('filtering by category returns correct subsets of items', () async {
      bloc.add(const NotificationsStarted(simulateLoading: false));
      await pumpEventQueue();

      bloc.add(const NotificationsCategoryFilterChanged(NotificationCategory.tripsAndDispatch));
      await pumpEventQueue();
      expect(bloc.state.selectedCategory, NotificationCategory.tripsAndDispatch);
      expect(bloc.state.filteredItems.length, 2);

      bloc.add(const NotificationsCategoryFilterChanged(NotificationCategory.receipts));
      await pumpEventQueue();
      expect(bloc.state.filteredItems.length, 3);

      bloc.add(const NotificationsCategoryFilterChanged(NotificationCategory.support));
      await pumpEventQueue();
      expect(bloc.state.filteredItems.length, 1);
    });

    test('mark all as read sets all items to isRead and allCaughtUp to true', () async {
      bloc.add(const NotificationsStarted(simulateLoading: false));
      await pumpEventQueue();

      expect(bloc.state.unreadCount, 3);

      bloc.add(const NotificationsMarkAllAsReadTapped());

      await expectLater(
        bloc.stream,
        emits(predicate<NotificationsState>((s) {
          return s.unreadCount == 0 &&
              s.allCaughtUp &&
              s.items.every((item) => item.isRead);
        })),
      );
    });

    test('tapping single item marks it read and emits target route', () async {
      bloc.add(const NotificationsStarted(simulateLoading: false));
      await pumpEventQueue();

      final firstItem = bloc.state.items.first;
      expect(firstItem.isRead, isFalse);

      bloc.add(NotificationsItemTapped(firstItem));

      await expectLater(
        bloc.stream,
        emits(predicate<NotificationsState>((s) {
          final updated = s.items.firstWhere((i) => i.id == firstItem.id);
          return updated.isRead == true && s.targetRoute == '/tracking';
        })),
      );
    });

    test('empty notifications list sets status to empty', () async {
      bloc.add(const NotificationsStarted(
        initialItems: [],
        simulateLoading: false,
      ));
      await pumpEventQueue();

      expect(bloc.state.status, NotificationsViewStatus.empty);
      expect(bloc.state.isEmpty, isTrue);
    });

    test('repository failure emits offlineError with cached offline feed', () async {
      final failRepo = MockNotificationsRepository(
        delay: const Duration(milliseconds: 10),
        shouldFail: true,
      );
      final failBloc = NotificationsBloc(repository: failRepo);

      failBloc.add(const NotificationsStarted(simulateLoading: false));
      await pumpEventQueue();

      expect(failBloc.state.status, NotificationsViewStatus.offlineError);
      expect(failBloc.state.isOfflineError, isTrue);
      expect(failBloc.state.cachedItems.length, 2);

      failBloc.close();
    });

    test('enable push notifications dismisses sheet', () async {
      bloc.add(const NotificationsStarted(simulateLoading: false));
      await pumpEventQueue();

      bloc.add(const NotificationsEnablePushTapped());

      await expectLater(
        bloc.stream,
        emits(predicate<NotificationsState>((s) => s.showPermissionSheet == false)),
      );
    });
  });
}
