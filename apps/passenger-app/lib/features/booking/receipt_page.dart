import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'money.dart';

class ReceiptPage extends ConsumerWidget {
  const ReceiptPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(activeBookingProvider).value;
    if (booking == null || !booking.isReceipt) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final waitingOnCash = booking.status == 'PAYMENT_PENDING' ||
        booking.status == 'TRIP_COMPLETED';
    return Scaffold(
      appBar: AppBar(title: const Text('Receipt')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                booking.trackingId,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                waitingOnCash ? 'Trip complete' : 'Payment received',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (waitingOnCash) ...[
                const SizedBox(height: 8),
                Text(
                  'Please pay cash to your driver.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
              const SizedBox(height: 32),
              _Line(
                label: 'Subtotal',
                value: formatCadCents(booking.receiptSubtotalCents),
              ),
              _Line(
                label: 'GST',
                value: formatCadCents(booking.receiptTaxCents),
              ),
              const Divider(height: 32),
              _Line(
                label: 'Total',
                value: formatCadCents(booking.receiptTotalCents),
                bold: true,
              ),
              const Spacer(),
              Text(
                'Ratings come in a later update.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
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
