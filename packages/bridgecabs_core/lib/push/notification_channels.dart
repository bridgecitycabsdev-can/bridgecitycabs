import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Android notification channels used by FCM data/notification payloads.
///
/// Channel ids must match the API push payload (`android.notification.channelId`).
class NotificationChannels {
  static const offers = AndroidNotificationChannel(
    'offers',
    'Ride offers',
    description: 'Incoming ride requests while you are on shift.',
    importance: Importance.high,
    playSound: true,
  );

  static const tripUpdates = AndroidNotificationChannel(
    'trip_updates',
    'Trip updates',
    description: 'Trip status and payment reminders.',
    importance: Importance.defaultImportance,
  );

  static Future<void> create() async {
    final plugin = FlutterLocalNotificationsPlugin();
    const init = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await plugin.initialize(init);

    final android = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(offers);
    await android?.createNotificationChannel(tripUpdates);
  }
}
