import 'package:equatable/equatable.dart';
import '../../data/models/notification_item_model.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class NotificationsStarted extends NotificationsEvent {
  final List<NotificationItem>? initialItems;
  final NotificationsViewStatus? initialStatus;
  final bool simulateLoading;

  const NotificationsStarted({
    this.initialItems,
    this.initialStatus,
    this.simulateLoading = false,
  });

  @override
  List<Object?> get props => [initialItems, initialStatus, simulateLoading];
}

class NotificationsCategoryFilterChanged extends NotificationsEvent {
  final NotificationCategory category;

  const NotificationsCategoryFilterChanged(this.category);

  @override
  List<Object?> get props => [category];
}

class NotificationsMarkAllAsReadTapped extends NotificationsEvent {
  const NotificationsMarkAllAsReadTapped();
}

class NotificationsItemTapped extends NotificationsEvent {
  final NotificationItem item;

  const NotificationsItemTapped(this.item);

  @override
  List<Object?> get props => [item];
}

class NotificationsCheckForUpdatesTapped extends NotificationsEvent {
  const NotificationsCheckForUpdatesTapped();
}

class NotificationsRetryTapped extends NotificationsEvent {
  const NotificationsRetryTapped();
}

class NotificationsEnablePushTapped extends NotificationsEvent {
  const NotificationsEnablePushTapped();
}

class NotificationsDismissPermissionSheet extends NotificationsEvent {
  const NotificationsDismissPermissionSheet();
}

class NotificationsBackTapped extends NotificationsEvent {
  const NotificationsBackTapped();
}
