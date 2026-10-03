import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../realtime.dart';

class CollectPage extends ConsumerStatefulWidget {
  const CollectPage({super.key});

  @override
  ConsumerState<CollectPage> createState() => _CollectPageState();
}

class _CollectPageState extends ConsumerState<CollectPage> {
  var _busy = false;
  String? _error;

  Future<void> _collect(PendingPayment pending) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(driverStateProvider.notifier).collectCash(pending.bookingId);
      // Router leaves /collect only when the next snapshot clears pendingPayment.
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
    return Scaffold(
      appBar: AppBar(title: const Text('Collect cash')),
      body: SafeArea(
        child: snapshot.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text(errorMessage(error))),
          data: (state) {
            final pending = state.pendingPayment;
            if (pending == null) {
              return const Center(child: Text('Payment settled'));
            }
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    pending.trackingId,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _money(pending.totalCents),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cash to collect',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  _Line(label: 'Fare', value: _money(pending.subtotalCents)),
                  _Line(label: 'GST', value: _money(pending.taxCents)),
                  const Divider(height: 32),
                  _Line(label: 'Total', value: _money(pending.totalCents), bold: true),
                  const Spacer(),
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                    const SizedBox(height: 12),
                  ],
                  FilledButton(
                    onPressed: _busy ? null : () => _collect(pending),
                    child: Text(_busy ? 'Confirming…' : 'Cash collected'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}

String _money(int cents) {
  return '\$${(cents / 100).toStringAsFixed(2)}';
}
