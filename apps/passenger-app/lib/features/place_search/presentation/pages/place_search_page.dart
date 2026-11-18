import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/place_search_bloc.dart';
import '../bloc/place_search_event.dart';
import '../bloc/place_search_state.dart';
import '../../data/models/lethbridge_place.dart';
import '../../data/models/place_search_config.dart';
import '../../data/repositories/place_search_repository.dart';
import '../widgets/place_input_card.dart';
import '../widgets/place_search_empty_view.dart';
import '../widgets/place_search_header.dart';
import '../widgets/place_search_initial_view.dart';
import '../widgets/place_search_keyboard_bar.dart';
import '../widgets/place_search_loading_view.dart';
import '../widgets/place_search_offline_view.dart';
import '../widgets/place_suggestions_list.dart';

/// Entry page for the Set Location / Place Search feature.
///
/// Implements all 5 UX states:
/// - Screen 1: Suggestions Loaded (autocomplete with distance & ETAs)
/// - Screen 2: Empty / Prompt (radar pulse with landmark suggestions)
/// - Screen 3: Searching (skeleton shimmers & searching indicator)
/// - Screen 4: No Places Found (zero results with pin on map action)
/// - Screen 5: Offline / Connection Error (retry, map fallback, and dispatch hotline)
class PlaceSearchPage extends StatelessWidget {
  final PlaceSearchRepository? repository;
  final PlaceSearchBloc? bloc;
  final String? initialPickup;
  final String? initialQuery;

  const PlaceSearchPage({
    super.key,
    this.repository,
    this.bloc,
    this.initialPickup,
    this.initialQuery,
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider.value(
        value: bloc!,
        child: const _PlaceSearchView(),
      );
    }

    return BlocProvider(
      create: (context) => PlaceSearchBloc(
        repository: repository ?? PlaceSearchRepositoryImpl(),
      )..add(PlaceSearchStarted(
          initialPickup: initialPickup,
          initialQuery: initialQuery,
        )),
      child: const _PlaceSearchView(),
    );
  }
}

class _PlaceSearchView extends StatefulWidget {
  const _PlaceSearchView();

  @override
  State<_PlaceSearchView> createState() => _PlaceSearchViewState();
}

class _PlaceSearchViewState extends State<_PlaceSearchView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlaceSearchBloc, PlaceSearchState>(
      listener: (context, state) {
        if (_controller.text != state.query) {
          _controller.text = state.query;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: state.query.length),
          );
        }

        if (state.targetRoute != null) {
          context.go(state.targetRoute!);
        }
      },
      builder: (context, state) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            body: SafeArea(
              child: Column(
                children: [
                  // Top App Bar
                  PlaceSearchHeader(
                    onBack: () => context
                        .read<PlaceSearchBloc>()
                        .add(const PlaceSearchCloseTapped()),
                  ),

                  // Main Scrollable Area
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Location Input Box & Shortcut Pills
                          PlaceInputCard(
                            pickupAddress: state.pickup,
                            controller: _controller,
                            isSearching: state.isSearching,
                            onQueryChanged: (query) => context
                                .read<PlaceSearchBloc>()
                                .add(PlaceSearchQueryChanged(query)),
                            onClear: () {
                              _controller.clear();
                              context
                                  .read<PlaceSearchBloc>()
                                  .add(const PlaceSearchCleared());
                            },
                            onSwap: () => context
                                .read<PlaceSearchBloc>()
                                .add(const PlaceSearchSwapLocationsTapped()),
                            shortcuts: state.shortcuts,
                            onShortcutTap: (id) => context
                                .read<PlaceSearchBloc>()
                                .add(PlaceSearchShortcutTapped(id)),
                          ),
                          const SizedBox(height: 12),

                          // Dynamic Content by Status
                          _buildContent(context, state),
                        ],
                      ),
                    ),
                  ),

                  // Autocomplete Quick Chips Bar above keyboard
                  _buildKeyboardBar(context, state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, PlaceSearchState state) {
    switch (state.status) {
      case PlaceSearchStatus.initial:
        return PlaceSearchInitialView(
          onLandmarkSelected: (landmark) {
            _controller.text = landmark;
            context
                .read<PlaceSearchBloc>()
                .add(PlaceSearchQueryChanged(landmark));
          },
        );

      case PlaceSearchStatus.searching:
        return const PlaceSearchLoadingView();

      case PlaceSearchStatus.success:
        return PlaceSuggestionsList(
          places: state.suggestions,
          onPlaceTap: (place) => context
              .read<PlaceSearchBloc>()
              .add(PlaceSearchPlaceSelected(place)),
        );

      case PlaceSearchStatus.empty:
        return PlaceSearchEmptyView(
          onSetPinOnMap: () => context
              .read<PlaceSearchBloc>()
              .add(const PlaceSearchPinOnMapTapped()),
        );

      case PlaceSearchStatus.failure:
        return PlaceSearchOfflineView(
          onTryAgain: () => context
              .read<PlaceSearchBloc>()
              .add(const PlaceSearchRetryTapped()),
          onChooseOnMap: () => context
              .read<PlaceSearchBloc>()
              .add(const PlaceSearchPinOnMapTapped()),
        );
    }
  }

  Widget _buildKeyboardBar(BuildContext context, PlaceSearchState state) {
    List<String> chips;
    String? label;

    if (state.isSuccess) {
      chips = const ['"Park Place Mall"', '"Park Place"', '"Cineplex"'];
    } else if (state.isInitial) {
      chips = const ['"Park Place Mall"', '"Whoop-Up Dr"', '"Galt Museum"'];
    } else if (state.isEmpty) {
      label = 'LETHBRIDGE TRANSIT';
      chips = const ['"Whoop-Up Dr"', '"Mayor Magrath"', '"Scenic Dr"'];
    } else if (state.isFailure) {
      chips = const ['Enmax', '"Enmax Centre"', 'Lethbridge'];
    } else {
      label = '🚗 Quick Match';
      chips = const ['Park Place', 'U of L', 'Enmax Centre'];
    }

    return PlaceSearchKeyboardBar(
      prefixLabel: label,
      suggestions: chips,
      onSelected: (query) {
        final clean = query.replaceAll('"', '');
        _controller.text = clean;
        context
            .read<PlaceSearchBloc>()
            .add(PlaceSearchQueryChanged(clean));
      },
    );
  }
}
