import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../push.dart';
import 'draft.dart';
import 'money.dart';

class ConfirmPage extends ConsumerStatefulWidget {
  const ConfirmPage({super.key});

  @override
  ConsumerState<ConfirmPage> createState() => _ConfirmPageState();
}

class _ConfirmPageState extends ConsumerState<ConfirmPage> {
  bool _busy = false;
  String? _error;

  Future<void> _book() async {
    final draft = ref.read(bookingDraftProvider);
    final notifier = ref.read(bookingDraftProvider.notifier);
    final payload = notifier.createPayload();
    if (payload == null || draft.chosen == null) {
      setState(() => _error = 'Choose a ride first');
      return;
    }
    final key = notifier.idempotencyKeyFor(payload);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final response = await ref
          .read(apiClientProvider)
          .dio
          .post<dynamic>(
            '/passenger/bookings',
            data: payload,
            options: Options(headers: {'Idempotency-Key': key}),
          );
      final booking = ActiveBooking.tryParse(response.data);
      if (!mounted) return;
      if (booking == null) {
        setState(() {
          _busy = false;
          _error = 'Booking created but could not be read';
        });
        return;
      }
      ref.read(activeBookingProvider.notifier).apply(booking);
      notifier.reset();
      // Ask once after the first booking; system won't re-prompt if decided.
      await requestPassengerPushAfterBooking(ref);
      if (!mounted) return;
      if (booking.isSearching) {
        context.go('/searching');
      } else {
        context.go('/tracking');
      }
    } on DioException catch (error) {
      if (!mounted) return;
      final code = errorCode(error);
      final body = errorBody(error);
      if (error.response?.statusCode == 409 && code == 'QUOTE_EXPIRED') {
        final fresh = FareQuotes.tryParse(body?['quote'], priceChanged: true);
        if (fresh != null) {
          notifier.applyQuotes(
            fresh,
            keepVehicleTypeId: draft.chosen?.vehicleTypeId,
          );
        }
        setState(() {
          _busy = false;
          _error =
              'The price changed. Confirm the new total, then book again.';
        });
        return;
      }
      if (error.response?.statusCode == 409) {
        setState(() {
          _busy = false;
          _error =
              'You already have an active trip. Finish or cancel it before '
              'booking another.';
        });
        return;
      }
      setState(() {
        _busy = false;
        _error = errorMessage(error);
      });
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
    final draft = ref.watch(bookingDraftProvider);
    final chosen = draft.chosen;
    final quotes = draft.quotes;
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Pickup', style: Theme.of(context).textTheme.labelLarge),
          Text(draft.pickup?.address ?? '—'),
          const SizedBox(height: 12),
          Text('Destination', style: Theme.of(context).textTheme.labelLarge),
          Text(draft.dropoff?.address ?? '—'),
          const SizedBox(height: 12),
          Text('Ride', style: Theme.of(context).textTheme.labelLarge),
          Text(chosen?.name ?? '—'),
          const SizedBox(height: 12),
          Text('Payment', style: Theme.of(context).textTheme.labelLarge),
          const Text('Cash'),
          const SizedBox(height: 16),
          if (chosen != null)
            Card(
              color: quotes?.priceChanged == true
                  ? Theme.of(context).colorScheme.tertiaryContainer
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total ${formatCadCents(chosen.totalCents)}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text('Includes GST ${formatCadCents(chosen.taxCents)}'),
                    if (quotes?.priceChanged == true)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Review the new price, then confirm to book.',
                        ),
                      ),
                  ],
                ),
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
            onPressed: _busy || !draft.canConfirm ? null : _book,
            child: _busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    quotes?.priceChanged == true
                        ? 'Confirm new price'
                        : 'Request ride',
                  ),
          ),
        ],
      ),
    );
  }
}
