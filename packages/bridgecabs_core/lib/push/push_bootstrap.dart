import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'notification_channels.dart';

/// Background isolate entry. The OS already shows the notification tray UI.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

/// Initializes Firebase, channels, and iOS foreground presentation.
///
/// Foreground: do not show a system notification — the socket delivers offers.
/// When [options] is null or [FirebaseOptions.projectId] is the placeholder,
/// initialization is skipped so CI/unit tests can run without a Firebase project.
Future<bool> bootstrapFirebase({required FirebaseOptions options}) async {
  if (kIsWeb) return false;
  if (options.projectId == 'bridgecabs-unconfigured') {
    debugPrint(
      'Firebase not configured. Run `flutterfire configure` '
      '(see docs/firebase-push.md).',
    );
    return false;
  }

  await Firebase.initializeApp(options: options);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationChannels.create();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: false,
    badge: false,
    sound: false,
  );
  return true;
}
