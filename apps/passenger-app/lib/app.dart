import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/auth.dart';
import 'features/cancel_ride/cancel_ride.dart';
import 'features/no_driver/no_driver.dart';
import 'features/booking/cards_page.dart';
import 'features/booking/confirm_page.dart';
import 'features/booking/options_page.dart';
import 'features/booking/receipt_page.dart';
import 'features/rate_driver/rate_driver.dart';
import 'features/add_card/add_card.dart';
import 'features/notifications/notifications.dart';
import 'features/support/support.dart';
import 'features/sos_alert/sos_alert.dart';
import 'features/profile/profile.dart';
import 'features/trip_history/trip_history.dart';
import 'features/card_authentication/card_authentication.dart';
import 'features/past_trip_detail/past_trip_detail.dart';
import 'features/side_menu_and_settings/side_menu_and_settings.dart';
import 'features/call_driver/call_driver.dart';
import 'features/delete_account/delete_account.dart';
import 'features/booking/search_page.dart';
import 'features/booking/searching_page.dart';
import 'features/home/home.dart';
import 'features/location_permission/location_permission.dart';
import 'features/onboarding/onboarding.dart';
import 'features/otp/otp.dart';
import 'features/profile_setup/profile_setup.dart';
import 'features/splash/splash.dart';
import 'di/app_providers.dart';
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
        '/search',
        '/options',
        '/confirm',
        '/searching',
        '/tracking',
        '/receipt',
        '/location-permission',
        '/notifications',
        '/support',
        '/support/thread',
        '/sos-alert',
        '/payment-methods',
        '/rate-driver',
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
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/phone',
        builder: (context, state) => Consumer(
          builder: (context, ref, _) => LoginPage(
            repository: AuthRepositoryImpl(
              customRequestOtp: (raw) =>
                  ref.read(sessionProvider.notifier).requestOtp(raw),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/code',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return Consumer(
            builder: (context, ref, _) => OtpPage(
              phone: phone,
              repository: OtpRepositoryImpl(
                customVerify: (code) =>
                    ref.read(sessionProvider.notifier).verifyOtp(phone, code),
                customResend: () =>
                    ref.read(sessionProvider.notifier).requestOtp(phone),
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => Consumer(
          builder: (context, ref, _) {
            final profiles = ref.read(profileRepositoryProvider);
            return ProfileSetupPage(
              repository: ProfileSetupRepositoryImpl(
                customSave: (profile) => profiles.saveNames(
                  firstName: profile.firstName,
                  lastName: profile.lastName,
                  email: profile.email,
                ),
              ),
            );
          },
        ),
      ),
      GoRoute(
        path: '/location-permission',
        builder: (context, state) => const LocationPermissionPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => Consumer(
          builder: (context, ref, _) => HomePage(
            onSignedOut: () => ref
                .read(sessionProvider.notifier)
                .signOutWithPushCleanup(
                  () => ref
                      .read(pushControllerProvider.notifier)
                      .unregisterAndDeleteToken(),
                ),
          ),
        ),
      ),
      GoRoute(path: '/search', builder: (context, state) => const SearchPage()),
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
        path: '/no-driver',
        builder: (context, state) => const NoDriverPage(),
      ),
      GoRoute(
        path: '/tracking',
        builder: (context, state) => const TrackingPage(),
      ),
      GoRoute(
        path: '/cancel-ride',
        builder: (context, state) => const CancelRidePage(),
      ),
      GoRoute(
        path: '/receipt',
        builder: (context, state) => const ReceiptPage(),
      ),
      GoRoute(
        path: '/rate-driver',
        builder: (context, state) {
          final bookingId = state.uri.queryParameters['bookingId'];
          return Consumer(
            builder: (context, ref, _) => RateDriverPage(
              tripInfo: bookingId == null
                  ? null
                  : TripSummaryInfo(tripId: bookingId),
              repository: ref.read(ratingRepositoryProvider),
            ),
          );
        },
      ),
      GoRoute(
        path: '/payment-methods',
        builder: (context, state) => const CardsPage(),
      ),
      GoRoute(
        path: '/add-card',
        builder: (context, state) => const AddCardPage(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => Consumer(
          builder: (context, ref, _) => NotificationsPage(
            repository: ref.read(notificationsRepositoryProvider),
          ),
        ),
      ),
      GoRoute(
        path: '/support',
        builder: (context, state) => Consumer(
          builder: (context, ref, _) => SupportHubPage(
            repository: ref.read(supportRepositoryProvider),
          ),
        ),
      ),
      GoRoute(
        path: '/support/thread',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? '';
          return Consumer(
            builder: (context, ref, _) => TicketThreadPage(
              ticketId: id,
              repository: ref.read(supportRepositoryProvider),
            ),
          );
        },
      ),
      GoRoute(
        path: '/sos-alert',
        builder: (context, state) => Consumer(
          builder: (context, ref, _) {
            final booking = ref.read(activeBookingProvider).value;
            return SosAlertPage(
              repository: ref.read(sosRepositoryProvider(booking?.id)),
            );
          },
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => Consumer(
          builder: (context, ref, _) => ProfilePage(
            repository: ref.read(profileRepositoryProvider),
          ),
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => Consumer(
          builder: (context, ref, _) => SettingsPage(
            repository: ref.read(profileRepositoryProvider),
          ),
        ),
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
      GoRoute(
        path: '/trip-history',
        builder: (context, state) => Consumer(
          builder: (context, ref, _) => TripHistoryPage(
            repository: ref.read(tripHistoryRepositoryProvider),
          ),
        ),
      ),
      GoRoute(
        path: '/trips',
        builder: (context, state) => Consumer(
          builder: (context, ref, _) => TripsHistoryHubPage(
            repository: ref.read(tripHistoryRepositoryProvider),
          ),
        ),
      ),
      GoRoute(
        path: '/trip-breakdown',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return Consumer(
            builder: (context, ref, _) => TripFareBreakdownPage(
              tripId: id,
              repository: ref.read(tripHistoryRepositoryProvider),
            ),
          );
        },
      ),
      GoRoute(
        path: '/card-auth',
        builder: (context, state) {
          final stageParam = state.uri.queryParameters['stage'];
          final CardAuthStage stage = stageParam == 'waiting'
              ? CardAuthStage.waitingForBank
              : CardAuthStage.prompt3ds;
          return CardAuthenticationPage(initialStage: stage);
        },
      ),
      GoRoute(
        path: '/card-auth/error',
        builder: (context, state) => const PaymentErrorFallbackPage(),
      ),
      GoRoute(
        path: '/card-auth/expired',
        builder: (context, state) => const ExpiredCardPromptPage(),
      ),
      GoRoute(
        path: '/past-trip-detail',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return PassengerTripDetailPage(tripId: id);
        },
      ),
      GoRoute(
        path: '/past-trips',
        builder: (context, state) => const PastTripsHubPage(),
      ),
      GoRoute(
        path: '/side-menu',
        builder: (context, state) => const SideMenuPage(),
      ),
      GoRoute(
        path: '/passenger-settings',
        builder: (context, state) => const PassengerSettingsPage(),
      ),
      GoRoute(
        path: '/call-driver',
        builder: (context, state) => const CallDriverPage(),
      ),
      GoRoute(
        path: '/call-driver/active',
        builder: (context, state) => const CallDriverPage(
          initialPhase: CallPhase.connecting,
        ),
      ),
      GoRoute(
        path: '/call-driver/outcome',
        builder: (context, state) => const CallDriverPage(
          initialPhase: CallPhase.outcomeFallback,
        ),
      ),
      GoRoute(
        path: '/delete-account',
        builder: (context, state) => Consumer(
          builder: (context, ref, _) => DeleteAccountPage(
            initialStep: DeleteAccountStep.warning,
            repository: ref.read(deleteAccountRepositoryProvider),
          ),
        ),
      ),
      GoRoute(
        path: '/delete-account/security',
        builder: (context, state) => Consumer(
          builder: (context, ref, _) => DeleteAccountPage(
            initialStep: DeleteAccountStep.verification,
            repository: ref.read(deleteAccountRepositoryProvider),
          ),
        ),
      ),
      GoRoute(
        path: '/delete-account/success',
        builder: (context, state) => Consumer(
          builder: (context, ref, _) => DeleteAccountPage(
            initialStep: DeleteAccountStep.requestedResult,
            repository: ref.read(deleteAccountRepositoryProvider),
          ),
        ),
      ),
      GoRoute(
        path: '/delete-account/safeguards',
        builder: (context, state) => Consumer(
          builder: (context, ref, _) => DeleteAccountPage(
            initialStep: DeleteAccountStep.safeguardsMatrix,
            repository: ref.read(deleteAccountRepositoryProvider),
          ),
        ),
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
