import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../di/app_providers.dart';
import '../../push.dart';
import 'draft.dart';
import 'money.dart';
import 'presentation/bloc/confirm_bloc.dart';
import 'stripe_sheet.dart';

class ConfirmPage extends ConsumerWidget {
  const ConfirmPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => ConfirmBloc(
        ref.read(bookingRepositoryProvider),
        ref.read(paymentRepositoryProvider),
      )..add(const ConfirmCardsRequested()),
      child: const _ConfirmView(),
    );
  }
}

class _ConfirmView extends ConsumerStatefulWidget {
  const _ConfirmView();

  @override
  ConsumerState<_ConfirmView> createState() => _ConfirmViewState();
}

class _ConfirmViewState extends ConsumerState<_ConfirmView> {
  String? _cardId;
  String? _addError;

  Future<void> _addCard() async {
    try {
      await presentCardSetup(ref.read(paymentRepositoryProvider));
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _addError = null);
      context.read<ConfirmBloc>().add(const ConfirmCardsRequested());
    } catch (error) {
      if (stripeCancelled(error) || !mounted) return;
      setState(() => _addError = errorMessage(error));
    }
  }

  void _book() {
    final draft = ref.read(bookingDraftProvider);
    final notifier = ref.read(bookingDraftProvider.notifier);
    final payload = notifier.createPayload(
      paymentMethod: _cardId == null ? 'CASH' : 'CARD',
      paymentMethodId: _cardId,
    );
    if (payload == null || draft.chosen == null) return;
    context.read<ConfirmBloc>().add(
      ConfirmBookRequested(
        body: payload,
        idempotencyKey: notifier.idempotencyKeyFor(payload),
        vehicleTypeId: draft.chosen?.vehicleTypeId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final chosen = draft.chosen;
    final quotes = draft.quotes;
    return BlocConsumer<ConfirmBloc, ConfirmState>(
      listener: (context, state) async {
        if (state.status == ConfirmStatus.quoteExpired &&
            state.refreshedQuote != null) {
          ref.read(bookingDraftProvider.notifier).applyQuotes(
            state.refreshedQuote!,
            keepVehicleTypeId: state.keepVehicleTypeId,
          );
        }
        final created = state.created;
        if (state.status != ConfirmStatus.booked || created == null) return;
        ref.read(activeBookingProvider.notifier).apply(created);
        ref.read(bookingDraftProvider.notifier).reset();
        await requestPassengerPushAfterBooking(ref);
        if (!context.mounted) return;
        context.go(created.isSearching ? '/searching' : '/tracking');
      },
      builder: (context, state) {
        final busy = state.status == ConfirmStatus.booking;
        final missingRide = chosen == null;
        return Scaffold(
          appBar: AppBar(title: const Text('Confirm')),
          body: RadioGroup<String?>(
            groupValue: _cardId,
            onChanged: (value) {
              if (busy) return;
              setState(() => _cardId = value);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Pickup', style: Theme.of(context).textTheme.labelLarge),
                Text(draft.pickup?.address ?? '—'),
                const SizedBox(height: 12),
                Text(
                  'Destination',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(draft.dropoff?.address ?? '—'),
                const SizedBox(height: 12),
                Text('Ride', style: Theme.of(context).textTheme.labelLarge),
                Text(chosen?.name ?? '—'),
                const SizedBox(height: 12),
                Text('Payment', style: Theme.of(context).textTheme.labelLarge),
                RadioListTile<String?>(
                  value: null,
                  title: const Text('Cash'),
                  enabled: !busy,
                ),
                for (final card in state.cards)
                  RadioListTile<String?>(
                    value: card.id,
                    title: Text(card.label),
                    subtitle: card.isDefault ? const Text('Default') : null,
                    enabled: !busy,
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: busy ? null : _addCard,
                    child: const Text('Add card'),
                  ),
                ),
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
                          Text(
                            'Includes GST ${formatCadCents(chosen.taxCents)}',
                          ),
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
                if (missingRide) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Choose a ride first',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                if (state.error != null || _addError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    state.error ?? _addError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: busy || !draft.canConfirm ? null : _book,
                  child: busy
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
          ),
        );
      },
    );
  }
}
