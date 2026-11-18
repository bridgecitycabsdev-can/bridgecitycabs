import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../di/app_providers.dart';
import 'draft.dart';
import 'place_field.dart';
import 'places.dart';
import 'presentation/bloc/search_bloc.dart';
import '../tracking/map_placeholder.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.read(placesRepositoryProvider);
    return BlocProvider(
      create: (_) => SearchBloc(places),
      child: _SearchView(places: places),
    );
  }
}

class _SearchView extends ConsumerStatefulWidget {
  const _SearchView({required this.places});

  final PlaceLookup places;

  @override
  ConsumerState<_SearchView> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<_SearchView> {
  late final PlaceSearchController _pickup;
  late final PlaceSearchController _dropoff;
  String? _error;
  bool _primed = false;

  @override
  void initState() {
    super.initState();
    _pickup = PlaceSearchController(widget.places);
    _dropoff = PlaceSearchController(widget.places);
    Future.microtask(_primePickup);
  }

  @override
  void dispose() {
    _pickup.dispose();
    _dropoff.dispose();
    super.dispose();
  }

  Future<void> _primePickup() async {
    if (_primed) return;
    _primed = true;
    final draft = ref.read(bookingDraftProvider);
    if (draft.pickup != null) {
      _pickup.setText(draft.pickup!.address);
      return;
    }
    if (draft.pickupNeedsSearch) return;
    final notifier = ref.read(bookingDraftProvider.notifier);
    notifier.setLocatingPickup(true);
    try {
      final permission = await Geolocator.checkPermission();
      var resolved = permission;
      if (permission == LocationPermission.denied) {
        resolved = await Geolocator.requestPermission();
      }
      if (resolved == LocationPermission.denied ||
          resolved == LocationPermission.deniedForever) {
        notifier.markPickupNeedsSearch();
        notifier.setLocatingPickup(false);
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      context.read<SearchBloc>().add(
        SearchReverseRequested(
          lat: position.latitude,
          lng: position.longitude,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      notifier.markPickupNeedsSearch();
      notifier.setLocatingPickup(false);
    }
  }

  Future<void> _continue() async {
    final draft = ref.read(bookingDraftProvider);
    if (draft.pickup == null || draft.dropoff == null) {
      setState(() => _error = 'Choose a pickup and destination');
      return;
    }
    setState(() => _error = null);
    context.push('/options');
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    return BlocListener<SearchBloc, SearchState>(
      listener: (context, state) {
        final notifier = ref.read(bookingDraftProvider.notifier);
        notifier.setLocatingPickup(state.locating);
        final stop = state.stop;
        if (stop != null) {
          notifier.setPickup(stop);
          _pickup.setText(stop.address);
          return;
        }
        if (state.missed) notifier.markPickupNeedsSearch();
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Where to?'),
        actions: [
          TextButton(
            onPressed: () => ref
                .read(sessionProvider.notifier)
                .signOutWithPushCleanup(
                  () => ref
                      .read(pushControllerProvider.notifier)
                      .unregisterAndDeleteToken(),
                ),
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: Column(
        children: [
          const Expanded(child: MapPlaceholder(label: 'Pickup area')),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (draft.locatingPickup)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: LinearProgressIndicator(),
                    ),
                  PlaceField(
                    label: draft.pickupNeedsSearch
                        ? 'Pickup (search required)'
                        : 'Pickup',
                    controller: _pickup,
                    onSelected: (details) async {
                      ref
                          .read(bookingDraftProvider.notifier)
                          .setPickup(
                            PlaceStop(
                              address: details.address,
                              lat: details.lat,
                              lng: details.lng,
                              placeId: details.placeId,
                            ),
                          );
                    },
                  ),
                  const SizedBox(height: 12),
                  PlaceField(
                    label: 'Destination',
                    controller: _dropoff,
                    onSelected: (details) async {
                      ref
                          .read(bookingDraftProvider.notifier)
                          .setDropoff(
                            PlaceStop(
                              address: details.address,
                              lat: details.lat,
                              lng: details.lng,
                              placeId: details.placeId,
                            ),
                          );
                    },
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: draft.canQuote ? _continue : null,
                    child: const Text('See rides'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
