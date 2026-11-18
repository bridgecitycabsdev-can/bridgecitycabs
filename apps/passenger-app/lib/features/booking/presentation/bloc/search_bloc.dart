import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passenger_app/data/repositories/places_repository.dart';
import 'package:passenger_app/features/booking/draft.dart';

class SearchReverseRequested {
  const SearchReverseRequested({required this.lat, required this.lng});

  final double lat;
  final double lng;
}

class SearchState {
  const SearchState({this.stop, this.missed = false, this.locating = false});

  final PlaceStop? stop;
  final bool missed;
  final bool locating;
}

class SearchBloc extends Bloc<SearchReverseRequested, SearchState> {
  SearchBloc(this.places) : super(const SearchState()) {
    on<SearchReverseRequested>(_onReverse);
  }

  final PlacesRepository places;

  Future<void> _onReverse(
    SearchReverseRequested event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchState(locating: true));
    try {
      final stop = await places.reverse(lat: event.lat, lng: event.lng);
      if (stop == null) {
        emit(const SearchState(missed: true));
        return;
      }
      emit(SearchState(stop: stop));
    } catch (_) {
      emit(const SearchState(missed: true));
    }
  }
}
