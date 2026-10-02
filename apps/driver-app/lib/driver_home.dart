import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter/material.dart';
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
  final publisher = LocationPublisher(ref.watch(bridgeSocketProvider));
  ref.onDispose(publisher.stop);
  return publisher;
});

final driverSnapshotProvider =
    AsyncNotifierProvider<DriverSnapshotController, DriverShiftSnapshot>(
      DriverSnapshotController.new,
    );

class DriverSnapshotController extends AsyncNotifier<DriverShiftSnapshot> {
  final DriverStateGate _gate = DriverStateGate();
  DriverShiftSnapshot? _latest;

  @override
  Future<DriverShiftSnapshot> build() => _load();

  void applySocket(DriverShiftSnapshot snapshot) {
    if (!_gate.acceptSocket(snapshot.version)) return;
    _latest = snapshot;
    state = AsyncData(snapshot);
  }

  Future<void> startShift() async {
    await ref
        .read(apiClientProvider)
        .dio
        .post<dynamic>('/driver/shift/start', data: <String, dynamic>{});
    ref.invalidateSelf();
    await future;
  }

  Future<void> endShift() async {
    await ref.read(apiClientProvider).dio.post<dynamic>('/driver/shift/end');
    ref.invalidateSelf();
    await future;
  }

  Future<DriverShiftSnapshot> _load() async {
    final response = await ref
        .read(apiClientProvider)
        .dio
        .get<dynamic>('/driver/me/state');
    final snapshot = DriverShiftSnapshot.tryParse(response.data);
    if (snapshot == null) {
      throw StateError('Driver state was incomplete');
    }
    if (!_gate.acceptRest(snapshot.version) && _latest != null) return _latest!;
    _latest = snapshot;
    return snapshot;
  }
}

class DriverHomePage extends ConsumerStatefulWidget {
  const DriverHomePage({super.key});

  @override
  ConsumerState<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends ConsumerState<DriverHomePage> {
  var _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_connect);
  }

  Future<void> _connect() async {
    final token = await ref.read(tokenStoreProvider).readAccess();
    if (!mounted || token == null || token.isEmpty) return;
    final config = ref.read(appConfigProvider);
    final api = ref.read(apiClientProvider);
    ref
        .read(bridgeSocketProvider)
        .connect(
          url: config.socketUrl('/driver'),
          token: token,
          refresh: api.refreshAccessToken,
          onDriverState: (data) {
            final snapshot = DriverShiftSnapshot.tryParse(data);
            if (snapshot == null) return;
            ref.read(driverSnapshotProvider.notifier).applySocket(snapshot);
          },
        );
  }

  void _syncLocation(bool onShift) {
    final publisher = ref.read(locationPublisherProvider);
    if (onShift) {
      publisher.start();
    } else {
      publisher.stop();
    }
  }

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
    final snapshot = ref.watch(driverSnapshotProvider);
    final location = ref.watch(locationPublisherProvider);
    ref.listen(driverSnapshotProvider, (previous, next) {
      _syncLocation(next.value?.onShift ?? false);
    });
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
            onPressed: () => ref.invalidate(driverSnapshotProvider),
          ),
          data: (state) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                _statusLabel(state.status),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(state.onShift ? 'On shift' : 'Off shift'),
              if (state.unitNumber != null) Text('Unit ${state.unitNumber}'),
              if (state.bookingTrackingId != null)
                Text(
                  'Job ${state.bookingTrackingId} · ${_statusLabel(state.bookingStatus ?? '')}',
                ),
              const SizedBox(height: 24),
              if (state.onShift)
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () => _run(
                          ref.read(driverSnapshotProvider.notifier).endShift,
                        ),
                  child: Text(_busy ? 'Ending…' : 'End shift'),
                )
              else
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () => _run(
                          ref.read(driverSnapshotProvider.notifier).startShift,
                        ),
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

String _statusLabel(String status) => status.replaceAll('_', ' ');

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
