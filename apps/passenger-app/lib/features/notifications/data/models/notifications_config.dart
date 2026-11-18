import 'notification_item_model.dart';

class NotificationsConfig {
  static const String screenTitle = 'Notifications';
  static const String markAllAsRead = 'Mark all as read';

  static const String couleePromoTitle = 'Need a ride across the coulees?';
  static const String couleePromoSubtitle =
      'Bridge City Cabs is available 24/7 across Lethbridge.';

  static const String dispatchPhone = '403-328-8888';

  static const String retentionNotice =
      'Notifications are saved for 30 days.\nBridge City Cabs • Southern Alberta Mobility';

  static const List<NotificationItem> defaultNotifications = [
    NotificationItem(
      id: 'notif_1',
      title: 'Driver is arriving',
      description: 'Michael is 3 minutes away in a white Toyota Corolla.',
      timestamp: '2m',
      category: NotificationCategory.tripsAndDispatch,
      isRead: false,
      isToday: true,
      metaText: 'Trip #BC-84920 • Downtown Lethbridge',
      iconType: NotificationIconType.car,
      targetRoute: '/tracking',
    ),
    NotificationItem(
      id: 'notif_2',
      title: 'Trip completed',
      description: 'Your total was \$22.10 CAD. Tap to see your receipt.',
      timestamp: '1h',
      category: NotificationCategory.receipts,
      isRead: false,
      isToday: true,
      metaText: 'Paid via Visa •••• 4242',
      iconType: NotificationIconType.checkmark,
      targetRoute: '/receipt',
    ),
    NotificationItem(
      id: 'notif_3',
      title: 'Support replied',
      description:
          "We've replied to your ticket about a lost item in Michael's vehicle.",
      timestamp: '3h',
      category: NotificationCategory.support,
      isRead: false,
      isToday: true,
      metaText: 'Bridge City Dispatch • Ticket #L491',
      iconType: NotificationIconType.support,
    ),
    NotificationItem(
      id: 'notif_4',
      title: 'Card authorization notice',
      description:
          'Temporary \$22.10 CAD pre-authorization hold released by RBC...',
      timestamp: 'Yesterday',
      category: NotificationCategory.receipts,
      isRead: true,
      isToday: false,
      metaText: 'Banking Authorization Status • Completed',
      iconType: NotificationIconType.info,
    ),
    NotificationItem(
      id: 'notif_5',
      title: 'Driver assigned',
      description:
          'Michael K. (4.9 ★) has accepted your ride request to Park Place Mall.',
      timestamp: 'Oct 24',
      category: NotificationCategory.tripsAndDispatch,
      isRead: true,
      isToday: false,
      metaText: '1st Ave S → Scenic Drive',
      iconType: NotificationIconType.driver,
      targetRoute: '/tracking',
    ),
    NotificationItem(
      id: 'notif_6',
      title: 'Receipt delivered',
      description:
          'Your ride receipt for \$17.10 CAD (BRIDGE5 promo applied) has been...',
      timestamp: 'Oct 22',
      category: NotificationCategory.receipts,
      isRead: true,
      isToday: false,
      metaText: 'PDF invoice dispatched',
      iconType: NotificationIconType.receipt,
      targetRoute: '/receipt',
    ),
  ];

  static const List<NotificationItem> cachedOfflineFeed = [
    NotificationItem(
      id: 'cached_1',
      title: 'Cab #42 Arrived',
      description:
          'Toyota Sienna (Silver) arrived at Scenic Dr S & 3 Ave S. Driver: Dave M.',
      timestamp: '2:45 PM',
      category: NotificationCategory.tripsAndDispatch,
      isRead: true,
      isToday: true,
      metaText: 'Trip completed • \$16.25 CAD',
      iconType: NotificationIconType.car,
    ),
    NotificationItem(
      id: 'cached_2',
      title: 'Receipt - University Hall',
      description: 'Ride charged to Visa ending in 4108.',
      timestamp: '11:18 AM',
      category: NotificationCategory.receipts,
      isRead: true,
      isToday: true,
      iconType: NotificationIconType.receipt,
    ),
  ];
}
