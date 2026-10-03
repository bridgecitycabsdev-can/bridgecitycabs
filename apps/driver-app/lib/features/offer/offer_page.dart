import 'dart:async';

import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OfferPage extends ConsumerStatefulWidget {
  const OfferPage({super.key});

  @override
  ConsumerState<OfferPage> createState() => _OfferPageState();
}

class _OfferPageState extends ConsumerState<OfferPage> {
  Timer? _ticker;
  var _accepting = false;
  var _declining = false;
  String? _error;
  final _reason = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _reason.dispose();
    super.dispose();
  }

  Duration _remaining(Offer offer) {
    final left = offer.expiresAt.toUtc().difference(
      ref.read(serverClockProvider).now(),
    );
    if (left.isNegative) return Duration.zero;
    return left;
  }

  Future<void> _accept(Offer offer) async {
    if (_accepting || _declining) return;
    setState(() {
      _accepting = true;
      _error = null;
    });
    final driver = ref.read(driverStateProvider.notifier);
    try {
      await driver.acceptOffer(offer.id);
      // Navigation waits for ASSIGNED via the router redirect.
    } catch (error) {
      if (!mounted) return;
      if (driver.isGone(error)) {
        setState(() => _error = 'This ride is no longer available');
        await driver.reload();
      } else {
        setState(() => _error = errorMessage(error));
      }
    } finally {
      if (mounted) setState(() => _accepting = false);
    }
  }

  Future<void> _decline(Offer offer) async {
    if (_accepting || _declining) return;
    setState(() {
      _declining = true;
      _error = null;
    });
    try {
      await ref
          .read(driverStateProvider.notifier)
          .declineOffer(offer.id, reason: _reason.text);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = errorMessage(error));
    } finally {
      if (mounted) setState(() => _declining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(driverStateProvider).value;
    final offer = snapshot?.offer;
    if (offer == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final left = _remaining(offer);
    final seconds = left.inMilliseconds / 1000;

    return Scaffold(
      appBar: AppBar(title: const Text('New offer')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              '${seconds.toStringAsFixed(1)}s left',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            _line('Passenger', offer.passengerFirstName),
            _line('Pickup', offer.pickup.address),
            _line('Drop-off', offer.dropoff.address),
            _line('To pickup', _distance(offer.distanceToPickupM)),
            _line('Trip', _distance(offer.tripDistanceM)),
            _line('Fare', _money(offer.quotedFareCents)),
            _line('Payment', offer.paymentMethod),
            if (offer.vanOnly || offer.ladyDriverOnly)
              _line(
                'Flags',
                [
                  if (offer.vanOnly) 'Van only',
                  if (offer.ladyDriverOnly) 'Lady driver',
                ].join(' · '),
              ),
            if (offer.notes != null && offer.notes!.isNotEmpty)
              _line('Notes', offer.notes!),
            const SizedBox(height: 16),
            TextField(
              controller: _reason,
              decoration: const InputDecoration(
                labelText: 'Decline reason (optional)',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _accepting || _declining ? null : () => _accept(offer),
              child: Text(_accepting ? 'Accepting…' : 'Accept'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _accepting || _declining ? null : () => _decline(offer),
              child: Text(_declining ? 'Declining…' : 'Decline'),
            ),
          ],
        ),
      ),
    );
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

String _distance(int meters) {
  if (meters < 1000) return '$meters m';
  return '${(meters / 1000).toStringAsFixed(1)} km';
}

String _money(int cents) {
  return '\$${(cents / 100).toStringAsFixed(2)}';
}
