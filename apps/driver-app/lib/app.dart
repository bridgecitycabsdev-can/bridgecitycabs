import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/home/home_page.dart';
import 'features/offer/offer_page.dart';
import 'features/trip/trip_page.dart';
import 'realtime.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final tick = ValueNotifier(0);
  ref.onDispose(tick.dispose);
  ref.listen(sessionProvider, (previous, next) => tick.value++);
  ref.listen(driverStateProvider, (previous, next) => tick.value++);
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
      if (!signedIn && (location == '/home' || location == '/offer' || location == '/trip')) {
        return '/phone';
      }
      if (!signedIn && location == '/boot') return '/phone';
      if (signedIn && signingIn) return '/home';
      if (!signedIn) return null;

      final driver = ref.read(driverStateProvider).value;
      if (driver == null) return null;
      final target = switch (driver.status) {
        DriverStatus.offered => '/offer',
        DriverStatus.assigned ||
        DriverStatus.enRoutePickup ||
        DriverStatus.arrived ||
        DriverStatus.onTrip =>
          '/trip',
        _ => '/home',
      };
      return state.matchedLocation == target ? null : target;
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
      GoRoute(path: '/home', builder: (context, state) => const DriverHomePage()),
      GoRoute(path: '/offer', builder: (context, state) => const OfferPage()),
      GoRoute(path: '/trip', builder: (context, state) => const TripPage()),
    ],
  );
});

class DriverApp extends ConsumerWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(driverRealtimeProvider);
    return MaterialApp.router(
      title: 'BridgeCabs Driver',
      theme: bridgeTheme(Brightness.light),
      darkTheme: bridgeTheme(Brightness.dark),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
