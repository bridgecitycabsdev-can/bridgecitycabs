import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class TripPage extends ConsumerStatefulWidget {
  const TripPage({super.key});

  @override
  ConsumerState<TripPage> createState() => _TripPageState();
}

class _TripPageState extends ConsumerState<TripPage> {
  var _busy = false;
  String? _error;
  final _releaseReason = TextEditingController();

  @override
  void dispose() {
    _releaseReason.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
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

  Future<void> _openMaps(OfferPlace place) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${place.lat},${place.lng}&travelmode=driving',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _navigateToPickup(DriverSnapshot state) async {
    final booking = state.booking;
    final pickup = booking?.pickup;
    if (booking == null || pickup == null) return;
    await _openMaps(pickup);
    await ref.read(driverStateProvider.notifier).markArriving(booking.id);
  }

  Future<void> _complete(DriverBooking booking) async {
    await ref.read(driverStateProvider.notifier).completeTrip(booking.id);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trip complete'),
        content: Text('Quoted fare ${_money(booking.quotedFareCents)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _release(DriverBooking booking) async {
    final reason = _releaseReason.text.trim();
    if (reason.isEmpty) {
      setState(() => _error = 'Enter a reason to release this job');
      return;
    }
    await ref.read(driverStateProvider.notifier).releaseBooking(booking.id, reason);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(driverStateProvider).value;
    final booking = state?.booking;
    if (state == null || booking == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final pickup = booking.pickup;
    final dropoff = booking.dropoff;

    return Scaffold(
      appBar: AppBar(title: Text(booking.trackingId)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              state.status.wire.replaceAll('_', ' '),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            _line('Passenger', booking.passengerFirstName),
            if (pickup != null) _line('Pickup', pickup.address),
            if (dropoff != null) _line('Drop-off', dropoff.address),
            _line('Fare', _money(booking.quotedFareCents)),
            if (booking.notes != null && booking.notes!.isNotEmpty)
              _line('Notes', booking.notes!),
            const SizedBox(height: 24),
            ..._primaryActions(state, booking, pickup),
            const SizedBox(height: 24),
            TextField(
              controller: _releaseReason,
              decoration: const InputDecoration(
                labelText: "Can't take this job — reason",
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _busy ? null : () => _run(() => _release(booking)),
              child: const Text("Can't take this job"),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _primaryActions(
    DriverSnapshot state,
    DriverBooking booking,
    OfferPlace? pickup,
  ) {
    return switch (state.status) {
      DriverStatus.assigned => [
        FilledButton(
          onPressed: _busy || pickup == null
              ? null
              : () => _run(() => _navigateToPickup(state)),
          child: Text(_busy ? 'Working…' : 'Navigate to pickup'),
        ),
      ],
      DriverStatus.enRoutePickup => [
        FilledButton(
          onPressed: _busy
              ? null
              : () => _run(
                  () => ref
                      .read(driverStateProvider.notifier)
                      .markArrived(booking.id),
                ),
          child: Text(_busy ? 'Working…' : "I've arrived"),
        ),
      ],
      DriverStatus.arrived => [
        FilledButton(
          onPressed: _busy
              ? null
              : () => _run(
                  () => ref
                      .read(driverStateProvider.notifier)
                      .startTrip(booking.id),
                ),
          child: Text(_busy ? 'Working…' : 'Start trip'),
        ),
      ],
      DriverStatus.onTrip => [
        if (booking.dropoff != null)
          OutlinedButton(
            onPressed: _busy
                ? null
                : () => _run(() => _openMaps(booking.dropoff!)),
            child: const Text('Navigate to drop-off'),
          ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _busy ? null : () => _run(() => _complete(booking)),
          child: Text(_busy ? 'Working…' : 'Complete trip'),
        ),
      ],
      _ => const <Widget>[],
    };
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

String _money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';
