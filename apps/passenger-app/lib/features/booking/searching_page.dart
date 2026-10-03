import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SearchingPage extends ConsumerStatefulWidget {
  const SearchingPage({super.key});

  @override
  ConsumerState<SearchingPage> createState() => _SearchingPageState();
}

class _SearchingPageState extends ConsumerState<SearchingPage> {
  bool _busy = false;
  String? _error;

  Future<void> _cancel() async {
    final booking = ref.read(activeBookingProvider).value;
    if (booking == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(apiClientProvider)
          .dio
          .post<dynamic>('/passenger/bookings/${booking.id}/cancel', data: {});
      if (!mounted) return;
      ref.read(activeBookingProvider.notifier).clear();
      context.go('/home');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = errorMessage(error);
      });
    }
  }

  Future<void> _retry() async {
    final booking = ref.read(activeBookingProvider).value;
    if (booking == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final response = await ref
          .read(apiClientProvider)
          .dio
          .post<dynamic>('/passenger/bookings/${booking.id}/retry');
      final next = ActiveBooking.tryParse(response.data);
      if (!mounted) return;
      if (next != null) {
        ref.read(activeBookingProvider.notifier).apply(next);
      }
      setState(() => _busy = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = errorMessage(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(activeBookingProvider).value;
    final noDriver = booking?.noDriverFound == true;
    return Scaffold(
      appBar: AppBar(title: Text(noDriver ? 'No drivers nearby' : 'Finding a driver')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!noDriver) const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                noDriver
                    ? 'We could not find a driver. Retry the search or cancel.'
                    : 'Looking for a nearby driver…',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (booking?.pickupAddress != null) ...[
                const SizedBox(height: 8),
                Text(booking!.pickupAddress!, textAlign: TextAlign.center),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              if (noDriver)
                FilledButton(
                  onPressed: _busy ? null : _retry,
                  child: const Text('Retry'),
                ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _busy ? null : _cancel,
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
