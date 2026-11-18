import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/place_search_config.dart';
import '../../data/models/quick_search_shortcut.dart';
import '../../data/repositories/place_search_repository.dart';
import 'place_search_event.dart';
import 'place_search_state.dart';

class PlaceSearchBloc extends Bloc<PlaceSearchEvent, PlaceSearchState> {
  final PlaceSearchRepository _repository;

  PlaceSearchBloc({required PlaceSearchRepository repository})
      : _repository = repository,
        super(const PlaceSearchState()) {
    on<PlaceSearchStarted>(_onStarted);
    on<PlaceSearchQueryChanged>(_onQueryChanged);
    on<PlaceSearchSubmitted>(_onSubmitted);
    on<PlaceSearchCleared>(_onCleared);
    on<PlaceSearchRetryTapped>(_onRetryTapped);
    on<PlaceSearchPlaceSelected>(_onPlaceSelected);
    on<PlaceSearchSwapLocationsTapped>(_onSwapLocationsTapped);
    on<PlaceSearchPinOnMapTapped>(_onPinOnMapTapped);
    on<PlaceSearchShortcutTapped>(_onShortcutTapped);
    on<PlaceSearchCloseTapped>(_onCloseTapped);
  }

  Future<void> _onStarted(
    PlaceSearchStarted event,
    Emitter<PlaceSearchState> emit,
  ) async {
    final pickup = event.initialPickup ?? PlaceSearchConfig.defaultPickupAddress;
    final query = event.initialQuery ?? '';

    if (query.isEmpty) {
      emit(state.copyWith(
        status: PlaceSearchStatus.initial,
        pickup: pickup,
        query: '',
        suggestions: const [],
        shortcuts: QuickSearchShortcut.promptShortcuts,
      ));
    } else {
      emit(state.copyWith(
        status: PlaceSearchStatus.searching,
        pickup: pickup,
        query: query,
      ));
      await _executeSearch(query, emit);
    }
  }

  Future<void> _onQueryChanged(
    PlaceSearchQueryChanged event,
    Emitter<PlaceSearchState> emit,
  ) async {
    final query = event.query;
    if (query.trim().isEmpty) {
      emit(state.copyWith(
        status: PlaceSearchStatus.initial,
        query: '',
        suggestions: const [],
        shortcuts: QuickSearchShortcut.promptShortcuts,
      ));
      return;
    }

    emit(state.copyWith(
      status: PlaceSearchStatus.searching,
      query: query,
    ));

    await _executeSearch(query, emit);
  }

  Future<void> _onSubmitted(
    PlaceSearchSubmitted event,
    Emitter<PlaceSearchState> emit,
  ) async {
    add(PlaceSearchQueryChanged(event.query));
  }

  void _onCleared(
    PlaceSearchCleared event,
    Emitter<PlaceSearchState> emit,
  ) {
    emit(state.copyWith(
      status: PlaceSearchStatus.initial,
      query: '',
      suggestions: const [],
      shortcuts: QuickSearchShortcut.promptShortcuts,
    ));
  }

  Future<void> _onRetryTapped(
    PlaceSearchRetryTapped event,
    Emitter<PlaceSearchState> emit,
  ) async {
    emit(state.copyWith(
      status: PlaceSearchStatus.searching,
      isOffline: false,
    ));
    await _executeSearch(state.query, emit);
  }

  void _onPlaceSelected(
    PlaceSearchPlaceSelected event,
    Emitter<PlaceSearchState> emit,
  ) {
    emit(state.copyWith(
      selectedPlace: event.place,
      query: event.place.title,
      targetRoute: '/home',
    ));
  }

  void _onSwapLocationsTapped(
    PlaceSearchSwapLocationsTapped event,
    Emitter<PlaceSearchState> emit,
  ) {
    final currentPickup = state.pickup;
    final currentQuery = state.query;

    emit(state.copyWith(
      pickup: currentQuery.isNotEmpty ? currentQuery : PlaceSearchConfig.defaultPickupAddress,
      query: currentPickup,
    ));

    if (currentPickup.isNotEmpty) {
      add(PlaceSearchQueryChanged(currentPickup));
    }
  }

  void _onPinOnMapTapped(
    PlaceSearchPinOnMapTapped event,
    Emitter<PlaceSearchState> emit,
  ) {
    emit(state.copyWith(targetRoute: '/home'));
  }

  void _onShortcutTapped(
    PlaceSearchShortcutTapped event,
    Emitter<PlaceSearchState> emit,
  ) {
    if (event.shortcutId == 'pin_on_map') {
      emit(state.copyWith(targetRoute: '/home'));
    } else if (event.shortcutId == 'home') {
      add(const PlaceSearchQueryChanged('Home, Lethbridge'));
    } else if (event.shortcutId == 'work') {
      add(const PlaceSearchQueryChanged('Downtown Lethbridge'));
    }
  }

  void _onCloseTapped(
    PlaceSearchCloseTapped event,
    Emitter<PlaceSearchState> emit,
  ) {
    emit(state.copyWith(targetRoute: '/home'));
  }

  Future<void> _executeSearch(
    String query,
    Emitter<PlaceSearchState> emit,
  ) async {
    try {
      final results = await _repository.searchPlaces(query);

      if (results.isEmpty) {
        emit(state.copyWith(
          status: PlaceSearchStatus.empty,
          suggestions: const [],
          isOffline: false,
          shortcuts: QuickSearchShortcut.defaultShortcuts,
        ));
      } else {
        emit(state.copyWith(
          status: PlaceSearchStatus.success,
          suggestions: results,
          isOffline: false,
          shortcuts: QuickSearchShortcut.defaultShortcuts,
        ));
      }
    } catch (_) {
      emit(state.copyWith(
        status: PlaceSearchStatus.failure,
        suggestions: const [],
        isOffline: true,
        shortcuts: QuickSearchShortcut.offlineShortcuts,
      ));
    }
  }
}
