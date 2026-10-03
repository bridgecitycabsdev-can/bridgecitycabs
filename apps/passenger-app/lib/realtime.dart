import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/tracking/driver_location.dart';

final bridgeSocketProvider = Provider<BridgeSocket>((ref) {
  final socket = BridgeSocket();
  ref.onDispose(socket.disconnect);
  return socket;
});

/// Keeps the passenger socket alive for the signed-in session.
final passengerRealtimeProvider = Provider<void>((ref) {
  void bind(bool signedIn) {
    if (!signedIn) {
      ref.read(bridgeSocketProvider).disconnect();
      return;
    }
    Future<void>(() async {
      final token = await ref.read(tokenStoreProvider).readAccess();
      if (token == null || token.isEmpty) return;
      final config = ref.read(appConfigProvider);
      final api = ref.read(apiClientProvider);
      ref
          .read(bridgeSocketProvider)
          .connect(
            url: config.socketUrl('/passenger'),
            token: token,
            refresh: api.refreshAccessToken,
            onBookingUpdated: (data) {
              final booking = ActiveBooking.tryParse(data);
              if (booking == null) return;
              ref.read(activeBookingProvider.notifier).apply(booking);
              if (booking.isTerminal) {
                ref.read(driverLocationProvider.notifier).clear();
              }
            },
            onDriverLocation: (data) {
              final ping = DriverLocationPing.tryParse(data);
              if (ping == null) return;
              ref.read(driverLocationProvider.notifier).apply(ping);
            },
          );
    });
  }

  // Defer so we never mutate other providers while this one is building.
  Future.microtask(() {
    bind(ref.read(sessionProvider).value == true);
  });
  ref.listen<AsyncValue<bool>>(sessionProvider, (previous, next) {
    bind(next.value == true);
  });
});
