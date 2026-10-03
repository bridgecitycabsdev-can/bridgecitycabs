import 'dart:async';

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
  final publisher = LocationPublisher(
    ref.watch(bridgeSocketProvider),
    ref.watch(apiClientProvider).dio,
  );
  ref.onDispose(publisher.stop);
  return publisher;
});

bool _bookingActive(DriverSnapshot snapshot) =>
    snapshot.booking != null || snapshot.offer != null;

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
      final location = ref.read(locationPublisherProvider);
      ref.read(bridgeSocketProvider).connect(
        url: config.socketUrl('/driver'),
        token: token,
        refresh: api.refreshAccessToken,
        onConnected: () {
          unawaited(location.flushBuffer());
        },
        onDriverState: (data) {
          final snapshot = DriverSnapshot.tryParse(data);
          if (snapshot == null) return;
          driver.applySocket(snapshot);
          unawaited(
            location.sync(
              onShift: snapshot.onShift,
              bookingActive: _bookingActive(snapshot),
            ),
          );
        },
        onOfferNew: (data) {
          final offer = Offer.tryParse(data);
          if (offer == null) return;
          HapticFeedback.heavyImpact();
          SystemSound.play(SystemSoundType.alert);
          driver.noteOfferNew(offer);
          final current = driver.latest;
          if (current != null) {
            unawaited(
              location.sync(
                onShift: current.onShift,
                bookingActive: true,
              ),
            );
          }
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
