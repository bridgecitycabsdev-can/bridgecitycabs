import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passenger_app/data/repositories/booking_repository.dart';

class TrackingCancelRequested {
  const TrackingCancelRequested(this.bookingId);

  final String bookingId;
}

enum TrackingStatus { idle, busy, cancelled, failure }

class TrackingState {
  const TrackingState({this.status = TrackingStatus.idle, this.error});

  final TrackingStatus status;
  final String? error;
}

class TrackingBloc extends Bloc<TrackingCancelRequested, TrackingState> {
  TrackingBloc(this._bookings) : super(const TrackingState()) {
    on<TrackingCancelRequested>(_onCancel);
  }

  final BookingRepository _bookings;

  Future<void> _onCancel(
    TrackingCancelRequested event,
    Emitter<TrackingState> emit,
  ) async {
    emit(const TrackingState(status: TrackingStatus.busy));
    try {
      await _bookings.cancel(event.bookingId);
      emit(const TrackingState(status: TrackingStatus.cancelled));
    } catch (error) {
      emit(
        TrackingState(
          status: TrackingStatus.failure,
          error: errorMessage(error),
        ),
      );
    }
  }
}
