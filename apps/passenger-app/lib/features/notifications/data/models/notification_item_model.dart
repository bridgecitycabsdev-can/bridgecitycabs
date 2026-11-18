enum NotificationsViewStatus {
  loading,
  loaded,
  empty,
  offlineError,
}

enum NotificationCategory {
  all,
  tripsAndDispatch,
  receipts,
  support;

  String get displayName {
    switch (this) {
      case NotificationCategory.all:
        return 'All';
      case NotificationCategory.tripsAndDispatch:
        return 'Trips & Dispatch';
      case NotificationCategory.receipts:
        return 'Receipts';
      case NotificationCategory.support:
        return 'Support';
    }
  }
}

enum NotificationIconType {
  car,
  checkmark,
  support,
  info,
  driver,
  receipt;
}

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String timestamp;
  final NotificationCategory category;
  final bool isRead;
  final bool isToday;
  final String? metaText;
  final NotificationIconType iconType;
  final String? targetRoute;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.category,
    this.isRead = false,
    this.isToday = true,
    this.metaText,
    this.iconType = NotificationIconType.car,
    this.targetRoute,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? description,
    String? timestamp,
    NotificationCategory? category,
    bool? isRead,
    bool? isToday,
    String? metaText,
    NotificationIconType? iconType,
    String? targetRoute,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      isRead: isRead ?? this.isRead,
      isToday: isToday ?? this.isToday,
      metaText: metaText ?? this.metaText,
      iconType: iconType ?? this.iconType,
      targetRoute: targetRoute ?? this.targetRoute,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
