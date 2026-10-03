import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/booking/confirm_page.dart';
import 'features/booking/options_page.dart';
import 'features/booking/receipt_page.dart';
import 'features/booking/search_page.dart';
import 'features/booking/searching_page.dart';
import 'features/tracking/tracking_page.dart';
import 'push.dart';
import 'realtime.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final tick = ValueNotifier(0);
  ref.onDispose(tick.dispose);
  ref.listen(sessionProvider, (previous, next) => tick.value++);
  ref.listen(activeBookingProvider, (previous, next) => tick.value++);
  return GoRouter(
    initialLocation: '/boot',
    refreshListenable: tick,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final location = state.matchedLocation;
      if (session.isLoading) return location == '/boot' ? null : '/boot';
      final signedIn = session.value == true;
      final signingIn =
          location == '/phone' || location == '/code' || location == '/boot';
      const bookingRoutes = {
        '/home',
        '/options',
        '/confirm',
        '/searching',
        '/tracking',
        '/receipt',
      };
      if (!signedIn && bookingRoutes.contains(location)) return '/phone';
      if (!signedIn && location == '/boot') return '/phone';
      if (signedIn && signingIn) return '/home';
      if (!signedIn) return null;

      final booking = ref.read(activeBookingProvider);
      if (booking.isLoading) {
        return location == '/boot' ? null : '/boot';
      }
      final active = booking.value;
      if (active != null && active.isLive) {
        final target = active.isTracking ? '/tracking' : '/searching';
        return location == target ? null : target;
      }
      if (active != null && active.isReceipt) {
        return location == '/receipt' ? null : '/receipt';
      }
      if (location == '/searching' ||
          location == '/tracking' ||
          location == '/receipt') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/boot',
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: '/phone',
        builder: (context, state) => const OtpPhonePage(),
      ),
      GoRoute(
        path: '/code',
        builder: (context, state) =>
            OtpCodePage(phone: state.uri.queryParameters['phone'] ?? ''),
      ),
      GoRoute(path: '/home', builder: (context, state) => const SearchPage()),
      GoRoute(
        path: '/options',
        builder: (context, state) => const OptionsPage(),
      ),
      GoRoute(
        path: '/confirm',
        builder: (context, state) => const ConfirmPage(),
      ),
      GoRoute(
        path: '/searching',
        builder: (context, state) => const SearchingPage(),
      ),
      GoRoute(
        path: '/tracking',
        builder: (context, state) => const TrackingPage(),
      ),
      GoRoute(
        path: '/receipt',
        builder: (context, state) => const ReceiptPage(),
      ),
    ],
  );
});

class PassengerApp extends ConsumerWidget {
  const PassengerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(passengerRealtimeProvider);
    ref.watch(passengerPushProvider);
    return MaterialApp.router(
      title: 'BridgeCabs',
      theme: bridgeTheme(Brightness.light),
      darkTheme: bridgeTheme(Brightness.dark),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
