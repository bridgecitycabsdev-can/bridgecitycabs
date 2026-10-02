import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bridgeSocketProvider = Provider<BridgeSocket>((ref) {
  final socket = BridgeSocket();
  ref.onDispose(socket.disconnect);
  return socket;
});

class PassengerHomePage extends ConsumerStatefulWidget {
  const PassengerHomePage({super.key});

  @override
  ConsumerState<PassengerHomePage> createState() => _PassengerHomePageState();
}

class _PassengerHomePageState extends ConsumerState<PassengerHomePage> {
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
          url: config.socketUrl('/passenger'),
          token: token,
          refresh: api.refreshAccessToken,
          onBookingUpdated: (data) {
            final booking = ActiveBooking.tryParse(data);
            if (booking == null) return;
            ref.read(activeBookingProvider.notifier).apply(booking);
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(activeBookingProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip'),
        actions: [
          TextButton(
            onPressed: () => ref.read(sessionProvider.notifier).signOut(),
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: SafeArea(
        child: booking.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(errorMessage(error)),
                TextButton(
                  onPressed: () => ref.invalidate(activeBookingProvider),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
          data: (active) {
            if (active == null) {
              return const Center(child: Text('No active booking'));
            }
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  active.trackingId,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(active.status.replaceAll('_', ' ')),
                if (active.pickupAddress != null) ...[
                  const SizedBox(height: 12),
                  Text(active.pickupAddress!),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
