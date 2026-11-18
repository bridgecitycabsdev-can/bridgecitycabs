import 'dart:async';
import '../../../../data/datasources/notification_remote_datasource.dart';
import '../models/notification_item_model.dart';
import '../models/notifications_config.dart';

abstract class NotificationsRepository {
  Future<List<NotificationItem>> fetchNotifications();
  Future<void> markAllAsRead();
  Future<void> markAsRead(String id);
  Future<void> enablePushNotifications();
}

class MockNotificationsRepository implements NotificationsRepository {
  final Duration delay;
  final bool shouldFail;
  final List<NotificationItem> _items;

  MockNotificationsRepository({
    this.delay = const Duration(milliseconds: 500),
    this.shouldFail = false,
    List<NotificationItem>? initialItems,
  }) : _items = List<NotificationItem>.from(
            initialItems ?? NotificationsConfig.defaultNotifications);

  @override
  Future<List<NotificationItem>> fetchNotifications() async {
    await Future.delayed(delay);
    if (shouldFail) {
      throw Exception('Unable to sync latest ride updates.');
    }
    return List.unmodifiable(_items);
  }

  @override
  Future<void> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 100));
    for (int i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> enablePushNotifications() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}

class ApiNotificationsRepository implements NotificationsRepository {
  ApiNotificationsRepository(this._remote);

  final NotificationRemoteDataSource _remote;

  @override
  Future<List<NotificationItem>> fetchNotifications() async {
    final body = await _remote.list();
    final rows = body is Map && body['data'] is List
        ? body['data'] as List
        : const <dynamic>[];
    return rows.map(_item).whereType<NotificationItem>().toList();
  }

  @override
  Future<void> markAllAsRead() => _remote.markAllRead();

  @override
  Future<void> markAsRead(String id) => _remote.markRead(id);

  @override
  Future<void> enablePushNotifications() async {}

  NotificationItem? _item(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final title = raw['title'];
    final body = raw['body'];
    if (id is! String || title is! String || body is! String) return null;
    final type = raw['type'] is String ? raw['type'] as String : '';
    final created = DateTime.tryParse(
      raw['createdAt'] is String ? raw['createdAt'] as String : '',
    );
    final now = DateTime.now();
    final category = type.contains('SUPPORT')
        ? NotificationCategory.support
        : type.contains('PAYMENT') || type.contains('RECEIPT')
            ? NotificationCategory.receipts
            : NotificationCategory.tripsAndDispatch;
    return NotificationItem(
      id: id,
      title: title,
      description: body,
      timestamp: created == null ? '' : _clock(created),
      category: category,
      isRead: raw['readAt'] != null,
      isToday: created != null &&
          created.year == now.year &&
          created.month == now.month &&
          created.day == now.day,
      iconType: category == NotificationCategory.support
          ? NotificationIconType.support
          : category == NotificationCategory.receipts
              ? NotificationIconType.receipt
              : NotificationIconType.car,
    );
  }

  String _clock(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $suffix';
  }
}
