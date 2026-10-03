import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../location_publisher.dart';
import '../../realtime.dart';
import '../location/battery_help_page.dart';
import '../location/location_disclosure_page.dart';

class DriverHomePage extends ConsumerStatefulWidget {
  const DriverHomePage({super.key});

  @override
  ConsumerState<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends ConsumerState<DriverHomePage> {
  var _busy = false;
  String? _error;

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = errorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _startShift() async {
    final location = ref.read(locationPublisherProvider);
    if (!location.consentAccepted) {
      final agreed = await showLocationDisclosure(context);
      if (!mounted || !agreed) return;
      location.markConsentAccepted();
    }

    try {
      await ref.read(driverStateProvider.notifier).startShift();
    } catch (error) {
      if (errorCode(error) != 'CONSENT_REQUIRED') rethrow;
      if (!mounted) return;
      final agreed = await showLocationDisclosure(context);
      if (!mounted || !agreed) return;
      location.markConsentAccepted();
      await ref.read(driverStateProvider.notifier).startShift();
    }

    final snapshot = ref.read(driverStateProvider).value;
    if (snapshot != null) {
      await location.sync(
        onShift: snapshot.onShift,
        bookingActive: snapshot.booking != null || snapshot.offer != null,
      );
    }
    if (!mounted) return;
    await maybeShowBatteryHelp(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(driverRealtimeProvider);
    final snapshot = ref.watch(driverStateProvider);
    final location = ref.watch(locationPublisherProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift'),
        actions: [
          TextButton(
            onPressed: () => context.push('/earnings'),
            child: const Text('Earnings'),
          ),
          TextButton(
            onPressed: () => ref
                .read(sessionProvider.notifier)
                .signOutWithPushCleanup(
                  () => ref
                      .read(pushControllerProvider.notifier)
                      .unregisterAndDeleteToken(),
                ),
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: SafeArea(
        child: snapshot.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _Message(
            text: errorMessage(error),
            action: 'Try again',
            onPressed: () => ref.invalidate(driverStateProvider),
          ),
          data: (state) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (ref.watch(pushControllerProvider) ==
                  PushPermissionStatus.denied) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "You won't receive ride requests while the app is closed.",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                      TextButton(
                        onPressed: () => ref
                            .read(pushControllerProvider.notifier)
                            .requestPermissionAndRegister(),
                        child: const Text('Enable notifications'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                state.status.wire.replaceAll('_', ' '),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(state.onShift ? 'On shift' : 'Off shift'),
              if (state.unitNumber != null) Text('Unit ${state.unitNumber}'),
              if (state.booking != null)
                Text(
                  'Job ${state.booking!.trackingId} · ${state.booking!.status.replaceAll('_', ' ')}',
                ),
              const SizedBox(height: 24),
              if (state.onShift)
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () => _run(
                          ref.read(driverStateProvider.notifier).endShift,
                        ),
                  child: Text(_busy ? 'Ending…' : 'End shift'),
                )
              else
                FilledButton(
                  onPressed: _busy ? null : () => _run(_startShift),
                  child: Text(_busy ? 'Starting…' : 'Start shift'),
                ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              Text(_locationCopy(location)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.text,
    required this.action,
    required this.onPressed,
  });

  final String text;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text),
          TextButton(onPressed: onPressed, child: Text(action)),
        ],
      ),
    );
  }
}

String _locationCopy(LocationPublisher location) {
  return switch (location.status) {
    LocationSendStatus.sending =>
      'Sharing your location every ${location.intervalSec}s while on shift '
          '(including in the background).',
    LocationSendStatus.denied =>
      'Location permission is off, so dispatch cannot see this cab.',
    LocationSendStatus.needsConsent =>
      'Accept the location notice before starting a shift.',
    LocationSendStatus.idle =>
      'Location is shared only while you are on shift.',
  };
}
