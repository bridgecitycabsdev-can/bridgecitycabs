import 'package:equatable/equatable.dart';
import '../../data/models/notification_item_model.dart';
import '../../data/models/notifications_config.dart';

class NotificationsState extends Equatable {
  final NotificationsViewStatus status;
  final List<NotificationItem> items;
  final NotificationCategory selectedCategory;
  final bool showPermissionSheet;
  final String? errorMessage;
  final List<NotificationItem> cachedItems;
  final bool navigateBack;
  final String? targetRoute;

  const NotificationsState({
    this.status = NotificationsViewStatus.loading,
    this.items = const [],
    this.selectedCategory = NotificationCategory.all,
    this.showPermissionSheet = false,
    this.errorMessage,
    this.cachedItems = NotificationsConfig.cachedOfflineFeed,
    this.navigateBack = false,
    this.targetRoute,
  });

  bool get isLoading => status == NotificationsViewStatus.loading;
  bool get isOfflineError => status == NotificationsViewStatus.offlineError;
  bool get isEmpty =>
      status == NotificationsViewStatus.empty ||
      (status == NotificationsViewStatus.loaded && items.isEmpty);

  int get unreadCount => items.where((item) => !item.isRead).length;
  bool get allCaughtUp => unreadCount == 0 && items.isNotEmpty;

  List<NotificationItem> get filteredItems {
    if (selectedCategory == NotificationCategory.all) return items;
    return items.where((item) => item.category == selectedCategory).toList();
  }

  List<NotificationItem> get todayItems =>
      filteredItems.where((item) => item.isToday).toList();

  List<NotificationItem> get earlierItems =>
      filteredItems.where((item) => !item.isToday).toList();

  int get unreadTodayCount =>
      todayItems.where((item) => !item.isRead).length;

  NotificationsState copyWith({
    NotificationsViewStatus? status,
    List<NotificationItem>? items,
    NotificationCategory? selectedCategory,
    bool? showPermissionSheet,
    String? errorMessage,
    bool clearError = false,
    List<NotificationItem>? cachedItems,
    bool? navigateBack,
    String? targetRoute,
    bool clearTargetRoute = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      items: items ?? this.items,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      showPermissionSheet: showPermissionSheet ?? this.showPermissionSheet,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      cachedItems: cachedItems ?? this.cachedItems,
      navigateBack: navigateBack ?? this.navigateBack,
      targetRoute: clearTargetRoute ? null : (targetRoute ?? this.targetRoute),
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        selectedCategory,
        showPermissionSheet,
        errorMessage,
        cachedItems,
        navigateBack,
        targetRoute,
      ];
}
