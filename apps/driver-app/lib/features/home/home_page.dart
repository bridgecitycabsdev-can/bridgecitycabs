import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../location_publisher.dart';
import '../../realtime.dart';

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
            onPressed: () => ref.read(sessionProvider.notifier).signOut(),
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
                      : () => _run(ref.read(driverStateProvider.notifier).endShift),
                  child: Text(_busy ? 'Ending…' : 'End shift'),
                )
              else
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () => _run(ref.read(driverStateProvider.notifier).startShift),
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
              Text(_locationCopy(location.status)),
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

String _locationCopy(LocationSendStatus status) {
  return switch (status) {
    LocationSendStatus.sending =>
      'Sending your location every 5 seconds while this screen is open.',
    LocationSendStatus.denied =>
      'Location permission is off, so dispatch cannot see this cab.',
    LocationSendStatus.idle =>
      'Location is sent only while you are on shift and this app is open. Tracking with the screen locked comes in a later release.',
  };
}
