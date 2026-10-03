import 'dart:async';

import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'realtime.dart';

/// Wires FCM for the passenger app. Permission is requested after the first
/// booking (see [requestPassengerPushAfterBooking]); cold start re-registers
/// when already permitted.
final passengerPushProvider = Provider<void>((ref) {
  if (!DefaultFirebaseOptions.isConfigured) return;

  final push = ref.read(pushControllerProvider.notifier);
  push.enable();
  push.bindHandlers(
    refreshState: () => ref.read(activeBookingProvider.notifier).refresh(),
    socketConnected: () => ref.read(bridgeSocketProvider).isConnected,
  );

  Future.microtask(() async {
    if (ref.read(sessionProvider).value == true) {
      await push.registerIfPermitted();
    }
  });
  ref.listen<AsyncValue<bool>>(sessionProvider, (previous, next) {
    if (next.value == true && previous?.value != true) {
      unawaited(push.registerIfPermitted());
    }
  });
});

/// Call after the passenger's first successful booking create.
Future<void> requestPassengerPushAfterBooking(WidgetRef ref) async {
  if (!DefaultFirebaseOptions.isConfigured) return;
  final push = ref.read(pushControllerProvider.notifier);
  if (!push.isEnabled) push.enable();
  await push.requestPermissionAndRegister();
}
