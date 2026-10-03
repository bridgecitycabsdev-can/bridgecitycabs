import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'draft.dart';
import 'money.dart';

class OptionsPage extends ConsumerStatefulWidget {
  const OptionsPage({super.key});

  @override
  ConsumerState<OptionsPage> createState() => _OptionsPageState();
}

class _OptionsPageState extends ConsumerState<OptionsPage> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final draft = ref.read(bookingDraftProvider);
    if (!draft.canQuote) {
      setState(() {
        _loading = false;
        _error = 'Choose pickup and destination first';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final quotes = await fetchQuotes(
        ref.read(apiClientProvider).dio,
        draft,
      );
      if (!mounted) return;
      ref.read(bookingDraftProvider.notifier).applyQuotes(quotes);
      setState(() => _loading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = errorMessage(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final quotes = draft.quotes;
    return Scaffold(
      appBar: AppBar(title: const Text('Choose a ride')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!),
                  TextButton(onPressed: _load, child: const Text('Try again')),
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
                for (final option in quotes?.options ?? const <QuoteOption>[])
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
                          draft.chosen?.vehicleTypeId == option.vehicleTypeId,
                      onTap: () {
                        ref.read(bookingDraftProvider.notifier).choose(option);
                        context.push('/confirm');
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}
