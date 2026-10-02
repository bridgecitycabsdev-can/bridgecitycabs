import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'driver_home.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return createShellRouter(ref: ref, home: const DriverHomePage());
});

class DriverApp extends ConsumerWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'BridgeCabs Driver',
      theme: bridgeTheme(Brightness.light),
      darkTheme: bridgeTheme(Brightness.dark),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
