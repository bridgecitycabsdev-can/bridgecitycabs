import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session.dart';
import 'device_registry.dart';

/// Notification permission for push registration UX.
enum PushPermissionStatus {
  /// Firebase not configured or not yet checked.
  unknown,

  /// Permission granted (or not required on this platform).
  granted,

  /// User denied; show the persistent banner for drivers.
  denied,
}

final deviceRegistryProvider = Provider<DeviceRegistry>((ref) {
  return DeviceRegistry(ref.watch(apiClientProvider).dio);
});

final pushControllerProvider =
    NotifierProvider<PushController, PushPermissionStatus>(PushController.new);

typedef PushRefresh = Future<void> Function();
typedef SocketConnected = bool Function();

/// Owns FCM permission, device registration, and tap/foreground handlers.
class PushController extends Notifier<PushPermissionStatus> {
  StreamSubscription<String>? _tokenSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;
  var _handlersBound = false;
  var _enabled = false;

  @override
  PushPermissionStatus build() {
    ref.onDispose(() {
      _tokenSub?.cancel();
      _foregroundSub?.cancel();
      _openedSub?.cancel();
    });
    return PushPermissionStatus.unknown;
  }

  /// Call once after [bootstrapFirebase] returns true.
  void enable() => _enabled = true;

  bool get isEnabled => _enabled;

  /// Bind tap + foreground listeners. Safe to call multiple times.
  void bindHandlers({
    required PushRefresh refreshState,
    required SocketConnected socketConnected,
  }) {
    if (!_enabled || _handlersBound || kIsWeb) return;
    _handlersBound = true;

    _foregroundSub = FirebaseMessaging.onMessage.listen((message) async {
      // Socket already delivers offers; only REST-refresh when disconnected.
      if (!socketConnected()) {
        await refreshState();
      }
    });

    _openedSub = FirebaseMessaging.onMessageOpenedApp.listen((_) async {
      await refreshState();
    });

    unawaited(() async {
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) await refreshState();
    }());
  }

  /// Drivers: request after login. Passengers: request after first booking.
  Future<void> requestPermissionAndRegister() async {
    if (!_enabled || kIsWeb) return;

    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    state = granted
        ? PushPermissionStatus.granted
        : PushPermissionStatus.denied;
    if (!granted) return;

    await _registerCurrentToken();
    _tokenSub?.cancel();
    _tokenSub = messaging.onTokenRefresh.listen((token) {
      unawaited(ref.read(deviceRegistryProvider).register(token));
    });
  }

  /// Re-register if already permitted (e.g. cold start while signed in).
  Future<void> registerIfPermitted() async {
    if (!_enabled || kIsWeb) return;
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    state = granted
        ? PushPermissionStatus.granted
        : settings.authorizationStatus == AuthorizationStatus.denied
        ? PushPermissionStatus.denied
        : PushPermissionStatus.unknown;
    if (!granted) return;
    await _registerCurrentToken();
    _tokenSub?.cancel();
    _tokenSub = FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      unawaited(ref.read(deviceRegistryProvider).register(token));
    });
  }

  Future<void> unregisterAndDeleteToken() async {
    if (!_enabled || kIsWeb) return;
    _tokenSub?.cancel();
    _tokenSub = null;
    final registry = ref.read(deviceRegistryProvider);
    String? token = registry.lastToken;
    try {
      token ??= await FirebaseMessaging.instance.getToken();
    } catch (_) {
      // Token unavailable when Firebase is misconfigured.
    }
    await registry.unregister(token);
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {
      // Best-effort local revoke.
    }
    state = PushPermissionStatus.unknown;
  }

  Future<void> _registerCurrentToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;
      await ref.read(deviceRegistryProvider).register(token);
    } catch (error) {
      debugPrint('FCM register failed: $error');
    }
  }
}
