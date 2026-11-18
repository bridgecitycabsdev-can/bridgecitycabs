import 'package:equatable/equatable.dart';
import '../../data/models/lethbridge_place.dart';
import '../../data/models/place_search_config.dart';
import '../../data/models/quick_search_shortcut.dart';

enum PlaceSearchStatus {
  /// Screen 2: Query is empty. Displays "Search address or place" radar prompt.
  initial,

  /// Screen 3: Query submitted or debounced. Displays animated shimmer skeletons.
  searching,

  /// Screen 1: Query returned results. Displays places list with distance/ETAs.
  success,

  /// Screen 4: 0 places matched query. Displays "No places found" and map pin CTA.
  empty,

  /// Screen 5: Network or timeout error. Displays "Unable to connect to place search".
  failure,
}

class PlaceSearchState extends Equatable {
  final PlaceSearchStatus status;
  final String pickup;
  final String query;
  final List<LethbridgePlace> suggestions;
  final LethbridgePlace? selectedPlace;
  final String? errorMessage;
  final bool isOffline;
  final List<QuickSearchShortcut> shortcuts;
  final String? targetRoute;

  const PlaceSearchState({
    this.status = PlaceSearchStatus.initial,
    this.pickup = PlaceSearchConfig.defaultPickupAddress,
    this.query = '',
    this.suggestions = const [],
    this.selectedPlace,
    this.errorMessage,
    this.isOffline = false,
    this.shortcuts = QuickSearchShortcut.defaultShortcuts,
    this.targetRoute,
  });

  bool get isInitial => status == PlaceSearchStatus.initial;
  bool get isSearching => status == PlaceSearchStatus.searching;
  bool get isSuccess => status == PlaceSearchStatus.success;
  bool get isEmpty => status == PlaceSearchStatus.empty;
  bool get isFailure => status == PlaceSearchStatus.failure;

  int get resultCount => suggestions.length;

  PlaceSearchState copyWith({
    PlaceSearchStatus? status,
    String? pickup,
    String? query,
    List<LethbridgePlace>? suggestions,
    LethbridgePlace? selectedPlace,
    String? errorMessage,
    bool? isOffline,
    List<QuickSearchShortcut>? shortcuts,
    String? targetRoute,
  }) {
    return PlaceSearchState(
      status: status ?? this.status,
      pickup: pickup ?? this.pickup,
      query: query ?? this.query,
      suggestions: suggestions ?? this.suggestions,
      selectedPlace: selectedPlace ?? this.selectedPlace,
      errorMessage: errorMessage ?? this.errorMessage,
      isOffline: isOffline ?? this.isOffline,
      shortcuts: shortcuts ?? this.shortcuts,
      targetRoute: targetRoute,
    );
  }

  @override
  List<Object?> get props => [
        status,
        pickup,
        query,
        suggestions,
        selectedPlace,
        errorMessage,
        isOffline,
        shortcuts,
        targetRoute,
      ];
}
