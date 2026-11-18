import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../di/app_providers.dart';
import 'draft.dart';
import 'money.dart';
import 'presentation/bloc/options_bloc.dart';

class OptionsPage extends ConsumerWidget {
  const OptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => OptionsBloc(ref.read(bookingRepositoryProvider))
        ..add(OptionsRequested(ref.read(bookingDraftProvider))),
      child: const _OptionsView(),
    );
  }
}

class _OptionsView extends ConsumerWidget {
  const _OptionsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(bookingDraftProvider);
    return BlocConsumer<OptionsBloc, OptionsState>(
      listener: (context, state) {
        final quotes = state.quotes;
        if (state.status == OptionsStatus.ready && quotes != null) {
          ref.read(bookingDraftProvider.notifier).applyQuotes(quotes);
        }
      },
      builder: (context, state) {
        final quotes = state.quotes ?? draft.quotes;
        return Scaffold(
          appBar: AppBar(title: const Text('Choose a ride')),
          body: state.status == OptionsStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : state.status == OptionsStatus.failure
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.error ?? 'Could not load rides'),
                      TextButton(
                        onPressed: () => context.read<OptionsBloc>().add(
                          OptionsRequested(ref.read(bookingDraftProvider)),
                        ),
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (quotes != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          '${(quotes.distanceM / 1000).toStringAsFixed(1)} km · '
                          '${(quotes.durationS / 60).round()} min'
                          '${quotes.source == 'ESTIMATE' ? ' · Estimated' : ''}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    if (quotes == null || quotes.options.isEmpty)
                      const Text('No rides available for this trip.'),
                    for (final option
                        in quotes?.options ?? const <QuoteOption>[])
                      Card(
                        child: ListTile(
                          title: Text(option.name),
                          subtitle: option.etaMinutes != null
                              ? Text('${option.etaMinutes} min away')
                              : null,
                          trailing: Text(
                            formatCadCents(option.totalCents),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          selected:
                              draft.chosen?.vehicleTypeId ==
                              option.vehicleTypeId,
                          onTap: () {
                            ref
                                .read(bookingDraftProvider.notifier)
                                .choose(option);
                            context.push('/confirm');
                          },
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}
