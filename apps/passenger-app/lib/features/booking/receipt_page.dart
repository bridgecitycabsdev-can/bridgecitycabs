import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'money.dart';

/// Fare summary for a finished trip. The router sends PAYMENT_PENDING and
/// TRIP_COMPLETED bookings here until the API closes them.
class ReceiptPage extends ConsumerWidget {
  const ReceiptPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(activeBookingProvider).value;
    if (booking == null) {
      return const Scaffold(body: Center(child: Text('No receipt yet')));
    }
    final driver = booking.driver;
    final vehicle = driver?.vehicle;
    return Scaffold(
      appBar: AppBar(title: Text(booking.trackingId)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            booking.status.replaceAll('_', ' '),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Text('Pickup', style: Theme.of(context).textTheme.labelLarge),
          Text(booking.pickupAddress ?? '—'),
          const SizedBox(height: 12),
          Text('Destination', style: Theme.of(context).textTheme.labelLarge),
          Text(booking.dropoffAddress ?? '—'),
          if (driver != null) ...[
            const SizedBox(height: 12),
            Text('Driver', style: Theme.of(context).textTheme.labelLarge),
            Text(driver.firstName),
            if (vehicle != null)
              Text('${vehicle.colour ?? ''} ${vehicle.make} ${vehicle.model} · ${vehicle.plate}'.trim()),
          ],
          const SizedBox(height: 16),
          Text('Subtotal ${formatCadCents(booking.receiptSubtotalCents)}'),
          Text('GST ${formatCadCents(booking.receiptTaxCents)}'),
          Text(
            'Total ${formatCadCents(booking.receiptTotalCents)}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (booking.status == 'PAYMENT_PENDING')
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'The card charge is waiting for the bank. This screen updates when it succeeds.',
              ),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.push('/rate-driver?bookingId=${booking.id}'),
            child: const Text('Rate driver'),
          ),
        ],
      ),
    );
  }
}
