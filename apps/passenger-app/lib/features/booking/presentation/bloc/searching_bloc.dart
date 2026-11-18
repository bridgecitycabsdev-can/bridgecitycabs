import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passenger_app/data/repositories/booking_repository.dart';

class SearchingCancelRequested {
  const SearchingCancelRequested(this.bookingId);

  final String bookingId;
}

class SearchingRetryRequested {
  const SearchingRetryRequested(this.bookingId);

  final String bookingId;
}

enum SearchingStatus { idle, busy, cancelled, retried, failure }

class SearchingState {
  const SearchingState({
    this.status = SearchingStatus.idle,
    this.error,
    this.booking,
  });

  final SearchingStatus status;
  final String? error;
  final ActiveBooking? booking;
}

class SearchingBloc extends Bloc<Object, SearchingState> {
  SearchingBloc(this._bookings) : super(const SearchingState()) {
    on<SearchingCancelRequested>(_onCancel);
    on<SearchingRetryRequested>(_onRetry);
  }

  final BookingRepository _bookings;

  Future<void> _onCancel(
    SearchingCancelRequested event,
    Emitter<SearchingState> emit,
  ) async {
    emit(const SearchingState(status: SearchingStatus.busy));
    try {
      await _bookings.cancel(event.bookingId);
      emit(const SearchingState(status: SearchingStatus.cancelled));
    } catch (error) {
      emit(
        SearchingState(
          status: SearchingStatus.failure,
          error: errorMessage(error),
        ),
      );
    }
  }

  Future<void> _onRetry(
    SearchingRetryRequested event,
    Emitter<SearchingState> emit,
  ) async {
    emit(const SearchingState(status: SearchingStatus.busy));
    try {
      final next = await _bookings.retry(event.bookingId);
      emit(SearchingState(status: SearchingStatus.retried, booking: next));
    } catch (error) {
      emit(
        SearchingState(
          status: SearchingStatus.failure,
          error: errorMessage(error),
        ),
      );
    }
  }
}
