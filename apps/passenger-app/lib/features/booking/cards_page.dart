import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/app_providers.dart';
import 'presentation/bloc/cards_bloc.dart';
import 'stripe_sheet.dart';

class CardsPage extends ConsumerWidget {
  const CardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => CardsBloc(ref.read(paymentRepositoryProvider))
        ..add(const CardsLoadRequested()),
      child: const _CardsView(),
    );
  }
}

class _CardsView extends ConsumerStatefulWidget {
  const _CardsView();

  @override
  ConsumerState<_CardsView> createState() => _CardsViewState();
}

class _CardsViewState extends ConsumerState<_CardsView> {
  String? _error;

  Future<void> _add() async {
    try {
      await presentCardSetup(ref.read(paymentRepositoryProvider));
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      context.read<CardsBloc>().add(const CardsLoadRequested());
    } catch (error) {
      if (stripeCancelled(error) || !mounted) return;
      setState(() => _error = errorMessage(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CardsBloc, CardsState>(
      builder: (context, state) {
        final error = _error ?? state.error;
        return Scaffold(
          appBar: AppBar(title: const Text('Payment cards')),
          body: state.status == CardsStatus.loading && state.cards.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (error != null)
                      Text(
                        error,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    if (state.cards.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No saved cards. Cash still works at the end of a trip.',
                        ),
                      ),
                    for (final card in state.cards)
                      ListTile(
                        title: Text(card.label),
                        subtitle: Text(card.isDefault ? 'Default' : 'Saved'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            final bloc = context.read<CardsBloc>();
                            if (value == 'default') {
                              bloc.add(CardsSetDefaultRequested(card.id));
                            }
                            if (value == 'remove') {
                              bloc.add(CardsRemoveRequested(card.id));
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'default',
                              child: Text('Make default'),
                            ),
                            PopupMenuItem(
                              value: 'remove',
                              child: Text('Remove'),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _add,
                      child: const Text('Add card'),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
