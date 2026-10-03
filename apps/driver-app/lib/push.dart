import 'dart:async';

import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'realtime.dart';

/// Wires FCM for the driver app: permission after login, register/unregister,
/// tap → refreshState, foreground REST refresh when the socket is down.
final driverPushProvider = Provider<void>((ref) {
  if (!DefaultFirebaseOptions.isConfigured) return;

  final push = ref.read(pushControllerProvider.notifier);
  push.enable();
  push.bindHandlers(
    refreshState: () => ref.read(driverStateProvider.notifier).reload(),
    socketConnected: () => ref.read(bridgeSocketProvider).isConnected,
  );

  void onSession(bool signedIn) {
    if (signedIn) {
      // Offers depend on permission — ask right after login.
      unawaited(push.requestPermissionAndRegister());
    }
  }

  Future.microtask(() {
    onSession(ref.read(sessionProvider).value == true);
  });
  ref.listen<AsyncValue<bool>>(sessionProvider, (previous, next) {
    final wasIn = previous?.value == true;
    final isIn = next.value == true;
    if (isIn && !wasIn) onSession(true);
  });
});
