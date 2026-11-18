import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passenger_app/data/repositories/booking_repository.dart';
import 'package:passenger_app/features/booking/draft.dart';

class OptionsRequested {
  const OptionsRequested(this.draft);

  final BookingDraft draft;
}

enum OptionsStatus { loading, ready, failure }

class OptionsState {
  const OptionsState({
    this.status = OptionsStatus.loading,
    this.quotes,
    this.error,
  });

  final OptionsStatus status;
  final FareQuotes? quotes;
  final String? error;
}

class OptionsBloc extends Bloc<OptionsRequested, OptionsState> {
  OptionsBloc(this._bookings) : super(const OptionsState()) {
    on<OptionsRequested>(_onRequested);
  }

  final BookingRepository _bookings;

  Future<void> _onRequested(
    OptionsRequested event,
    Emitter<OptionsState> emit,
  ) async {
    if (!event.draft.canQuote) {
      emit(
        const OptionsState(
          status: OptionsStatus.failure,
          error: 'Choose pickup and destination first',
        ),
      );
      return;
    }
    emit(const OptionsState());
    try {
      final quotes = await _bookings.quote(event.draft);
      emit(OptionsState(status: OptionsStatus.ready, quotes: quotes));
    } catch (error) {
      emit(
        OptionsState(
          status: OptionsStatus.failure,
          error: errorMessage(error),
        ),
      );
    }
  }
}
