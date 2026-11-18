import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../di/app_providers.dart';
import 'presentation/bloc/searching_bloc.dart';

class SearchingPage extends ConsumerWidget {
  const SearchingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => SearchingBloc(ref.read(bookingRepositoryProvider)),
      child: const _SearchingView(),
    );
  }
}

class _SearchingView extends ConsumerWidget {
  const _SearchingView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(activeBookingProvider).value;
    final noDriver = booking?.noDriverFound == true;
    return BlocConsumer<SearchingBloc, SearchingState>(
      listener: (context, state) {
        if (state.status == SearchingStatus.cancelled) {
          ref.read(activeBookingProvider.notifier).clear();
          context.go('/home');
          return;
        }
        if (state.status == SearchingStatus.retried && state.booking != null) {
          ref.read(activeBookingProvider.notifier).apply(state.booking!);
        }
      },
      builder: (context, state) {
        final busy = state.status == SearchingStatus.busy;
        return Scaffold(
          appBar: AppBar(
            title: Text(noDriver ? 'No drivers nearby' : 'Finding a driver'),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!noDriver) const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    noDriver
                        ? 'We could not find a driver. Retry the search or cancel.'
                        : 'Looking for a nearby driver…',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (booking?.pickupAddress != null) ...[
                    const SizedBox(height: 8),
                    Text(booking!.pickupAddress!, textAlign: TextAlign.center),
                  ],
                  if (state.error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (noDriver)
                    FilledButton(
                      onPressed: busy || booking == null
                          ? null
                          : () => context.read<SearchingBloc>().add(
                              SearchingRetryRequested(booking.id),
                            ),
                      child: const Text('Retry'),
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: busy || booking == null
                        ? null
                        : () => context.read<SearchingBloc>().add(
                            SearchingCancelRequested(booking.id),
                          ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
