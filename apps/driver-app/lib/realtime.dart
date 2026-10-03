import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'location_publisher.dart';

final bridgeSocketProvider = Provider<BridgeSocket>((ref) {
  final socket = BridgeSocket();
  ref.onDispose(socket.disconnect);
  return socket;
});

final locationPublisherProvider = ChangeNotifierProvider<LocationPublisher>((
  ref,
) {
  final publisher = LocationPublisher(ref.watch(bridgeSocketProvider));
  ref.onDispose(publisher.stop);
  return publisher;
});

/// Keeps the driver socket alive for the signed-in session, not only on /home.
final driverRealtimeProvider = Provider<void>((ref) {
  void bind(bool signedIn) {
    if (!signedIn) {
      ref.read(bridgeSocketProvider).disconnect();
      ref.read(locationPublisherProvider).stop();
      return;
    }
    Future<void>(() async {
      final token = await ref.read(tokenStoreProvider).readAccess();
      if (token == null || token.isEmpty) return;
      final config = ref.read(appConfigProvider);
      final api = ref.read(apiClientProvider);
      final driver = ref.read(driverStateProvider.notifier);
      ref.read(bridgeSocketProvider).connect(
        url: config.socketUrl('/driver'),
        token: token,
        refresh: api.refreshAccessToken,
        onDriverState: (data) {
          final snapshot = DriverSnapshot.tryParse(data);
          if (snapshot == null) return;
          driver.applySocket(snapshot);
          final location = ref.read(locationPublisherProvider);
          if (snapshot.onShift) {
            location.start();
          } else {
            location.stop();
          }
        },
        onOfferNew: (data) {
          final offer = Offer.tryParse(data);
          if (offer == null) return;
          HapticFeedback.heavyImpact();
          SystemSound.play(SystemSoundType.alert);
          driver.noteOfferNew(offer);
        },
        onOfferExpired: (data) {
          final offerId = data['offerId'];
          if (offerId is String) driver.clearOffer(offerId);
        },
        onOfferCancelled: (data) {
          final offerId = data['offerId'];
          if (offerId is String) driver.clearOffer(offerId);
        },
      );
    });
  }

  bind(ref.read(sessionProvider).value == true);
  ref.listen<AsyncValue<bool>>(sessionProvider, (previous, next) {
    bind(next.value == true);
  });
});
