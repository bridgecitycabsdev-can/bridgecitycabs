import 'package:equatable/equatable.dart';
import '../../data/models/lethbridge_place.dart';

abstract class PlaceSearchEvent extends Equatable {
  const PlaceSearchEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the place search screen opens.
class PlaceSearchStarted extends PlaceSearchEvent {
  final String? initialPickup;
  final String? initialQuery;

  const PlaceSearchStarted({
    this.initialPickup,
    this.initialQuery,
  });

  @override
  List<Object?> get props => [initialPickup, initialQuery];
}

/// Dispatched as the passenger types into the destination field.
class PlaceSearchQueryChanged extends PlaceSearchEvent {
  final String query;

  const PlaceSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Dispatched when passenger presses Search / Enter or an autocomplete chip.
class PlaceSearchSubmitted extends PlaceSearchEvent {
  final String query;

  const PlaceSearchSubmitted(this.query);

  @override
  List<Object?> get props => [query];
}

/// Dispatched when passenger taps the clear `✕` button on destination input.
class PlaceSearchCleared extends PlaceSearchEvent {
  const PlaceSearchCleared();
}

/// Dispatched when passenger taps "Try again" in offline error state.
class PlaceSearchRetryTapped extends PlaceSearchEvent {
  const PlaceSearchRetryTapped();
}

/// Dispatched when passenger taps a place result row.
class PlaceSearchPlaceSelected extends PlaceSearchEvent {
  final LethbridgePlace place;

  const PlaceSearchPlaceSelected(this.place);

  @override
  List<Object?> get props => [place];
}

/// Dispatched when passenger taps the swap icon `⇅` between pickup and dropoff.
class PlaceSearchSwapLocationsTapped extends PlaceSearchEvent {
  const PlaceSearchSwapLocationsTapped();
}

/// Dispatched when passenger taps "Pin on map" / "Set pin on map instead".
class PlaceSearchPinOnMapTapped extends PlaceSearchEvent {
  const PlaceSearchPinOnMapTapped();
}

/// Dispatched when passenger taps a shortcut button (Recents, Saved, Home, Work, etc.).
class PlaceSearchShortcutTapped extends PlaceSearchEvent {
  final String shortcutId;

  const PlaceSearchShortcutTapped(this.shortcutId);

  @override
  List<Object?> get props => [shortcutId];
}

/// Dispatched when passenger taps the top back button `←`.
class PlaceSearchCloseTapped extends PlaceSearchEvent {
  const PlaceSearchCloseTapped();
}
