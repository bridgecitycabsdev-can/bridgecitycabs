import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/session.dart';
import 'otp_pages.dart';

GoRouter createShellRouter({required Ref ref, required Widget home}) {
  final tick = ValueNotifier(0);
  ref.onDispose(tick.dispose);
  ref.listen(sessionProvider, (previous, next) => tick.value++);
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
      if (!signedIn && location == '/home') return '/phone';
      if (!signedIn && location == '/boot') return '/phone';
      if (signedIn && signingIn) return '/home';
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
      GoRoute(path: '/home', builder: (context, state) => home),
    ],
  );
}
