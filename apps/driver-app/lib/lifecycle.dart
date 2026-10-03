import 'dart:async';

import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'realtime.dart';

/// On resume: reload `/driver/me/state` and restart location if on shift.
final driverLifecycleProvider = Provider<void>((ref) {
  final observer = _DriverLifecycleObserver(ref);
  WidgetsBinding.instance.addObserver(observer);
  ref.onDispose(() => WidgetsBinding.instance.removeObserver(observer));
});

class _DriverLifecycleObserver with WidgetsBindingObserver {
  _DriverLifecycleObserver(this._ref);

  final Ref _ref;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (_ref.read(sessionProvider).value != true) return;
    unawaited(_onResume());
  }

  Future<void> _onResume() async {
    final driver = _ref.read(driverStateProvider.notifier);
    await driver.reload();
    final snapshot = _ref.read(driverStateProvider).value;
    if (snapshot == null || !snapshot.onShift) return;
    final location = _ref.read(locationPublisherProvider);
    if (location.isRunning) return;
    await location.sync(
      onShift: true,
      bookingActive: snapshot.booking != null || snapshot.offer != null,
    );
  }
}
