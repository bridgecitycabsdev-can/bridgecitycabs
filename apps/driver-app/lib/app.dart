import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/auth.dart';
import 'features/collect/collect_page.dart';
import 'features/delete_account/delete_account.dart';
import 'features/earnings/earnings.dart';
import 'features/flag_ride/flag_ride.dart';
import 'features/history/history.dart';
import 'features/home/home.dart';
import 'features/menu/menu.dart';
import 'features/offer/offer_page.dart';
import 'features/onboarding/onboarding.dart';
import 'features/otp/otp.dart';
import 'features/profile/profile.dart';
import 'features/registration/registration.dart';
import 'features/request/request.dart';
import 'features/reviews/reviews.dart';
import 'features/settings/settings.dart';
import 'features/splash/splash.dart';
import 'features/support/support.dart';
import 'features/trip/trip.dart';
import 'features/trip_summary/trip_summary.dart';
import 'lifecycle.dart';
import 'push.dart';
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
      const protected = {
        '/home',
        '/offer',
        '/trip',
        '/trip-summary',
        '/summary',
        '/collect',
        '/earnings',
        '/history',
        '/reviews',
        '/settings',
        '/flag-ride',
        '/support',
        '/delete-account',
      };
      if (!signedIn && protected.contains(location)) return '/phone';
      if (!signedIn && location == '/boot') return '/phone';
      if (signedIn && signingIn) return '/home';
      if (!signedIn) return null;

      final driver = ref.read(driverStateProvider).value;
      if (driver == null) return null;
      // Offer and live trip keep priority over collect cash.
      final target = switch (driver.status) {
        DriverStatus.offered => '/offer',
        DriverStatus.assigned ||
        DriverStatus.enRoutePickup ||
        DriverStatus.arrived ||
        DriverStatus.onTrip =>
          '/trip',
        _ => driver.pendingPayment != null ? '/collect' : '/home',
      };
      if ((location == '/earnings' ||
              location == '/history' ||
              location == '/reviews' ||
              location == '/settings' ||
              location == '/flag-ride' ||
              location == '/support' ||
              location == '/delete-account') &&
          target == '/home') {
        return null;
      }
      return location == target ? null : target;
    },
    routes: [
      GoRoute(
        path: '/boot',
        builder: (context, state) => const DriverSplashPage(),
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const DriverSplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const DriverOnboardingPage(),
      ),
      GoRoute(
        path: '/phone',
        builder: (context, state) => const DriverLoginPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const DriverLoginPage(),
      ),
      GoRoute(
        path: '/code',
        builder: (context, state) =>
            DriverOtpPage(phone: state.uri.queryParameters['phone'] ?? ''),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) =>
            DriverOtpPage(phone: state.uri.queryParameters['phone'] ?? ''),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const DriverRegisterStep1Page(),
      ),
      GoRoute(
        path: '/register-step-1',
        builder: (context, state) => const DriverRegisterStep1Page(),
      ),
      GoRoute(
        path: '/register-step-2',
        builder: (context, state) => const DriverRegisterStep2Page(),
      ),
      GoRoute(
        path: '/register-step-3',
        builder: (context, state) => const DriverRegisterStep3Page(),
      ),
      GoRoute(
        path: '/register-step-4',
        builder: (context, state) => const DriverRegisterStep4Page(),
      ),
      GoRoute(
        path: '/pending-approval',
        builder: (context, state) => const DriverRegisterStep4Page(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const DriverHomePage()),
      GoRoute(path: '/menu', builder: (context, state) => const DriverMenuPage()),
      GoRoute(path: '/profile', builder: (context, state) => const DriverProfilePage()),
      GoRoute(path: '/offer', builder: (context, state) => const DriverRequestPage()),
      GoRoute(path: '/request', builder: (context, state) => const DriverRequestPage()),
      GoRoute(path: '/trip', builder: (context, state) => const DriverTripPage()),
      GoRoute(
        path: '/trip-summary',
        builder: (context, state) => const DriverTripSummaryPage(),
      ),
      GoRoute(
        path: '/summary',
        builder: (context, state) => const DriverTripSummaryPage(),
      ),
      GoRoute(path: '/collect', builder: (context, state) => const CollectPage()),
      GoRoute(
        path: '/earnings',
        builder: (context, state) => const DriverEarningsPage(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const DriverTripHistoryPage(),
      ),
      GoRoute(
        path: '/reviews',
        builder: (context, state) => const DriverReviewsPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const DriverSettingsPage(),
      ),
      GoRoute(
        path: '/flag-ride',
        builder: (context, state) => const DriverFlagRidePage(),
      ),
      GoRoute(
        path: '/support',
        builder: (context, state) => const DriverSupportPage(),
      ),
      GoRoute(
        path: '/delete-account',
        builder: (context, state) => const DriverDeleteAccountPage(),
      ),
    ],
  );
});

class DriverApp extends ConsumerWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(driverRealtimeProvider);
    ref.watch(driverPushProvider);
    ref.watch(driverLifecycleProvider);
    return MaterialApp.router(
      title: 'BridgeCabs Driver',
      theme: bridgeTheme(Brightness.light),
      darkTheme: bridgeTheme(Brightness.dark),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
