import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passenger_app/data/repositories/booking_repository.dart';
import 'package:passenger_app/data/repositories/payment_repository.dart';
import 'package:passenger_app/features/booking/draft.dart';
import 'package:passenger_app/features/booking/saved_card.dart';

class ConfirmCardsRequested {
  const ConfirmCardsRequested();
}

class ConfirmBookRequested {
  const ConfirmBookRequested({
    required this.body,
    required this.idempotencyKey,
    required this.vehicleTypeId,
  });

  final Map<String, dynamic> body;
  final String idempotencyKey;
  final String? vehicleTypeId;
}

enum ConfirmStatus { idle, booking, booked, quoteExpired, activeTrip, failure }

class ConfirmState {
  const ConfirmState({
    this.cards = const [],
    this.status = ConfirmStatus.idle,
    this.error,
    this.created,
    this.refreshedQuote,
    this.keepVehicleTypeId,
  });

  final List<SavedCard> cards;
  final ConfirmStatus status;
  final String? error;
  final ActiveBooking? created;
  final FareQuotes? refreshedQuote;
  final String? keepVehicleTypeId;

  ConfirmState copyWith({
    List<SavedCard>? cards,
    ConfirmStatus? status,
    String? error,
    ActiveBooking? created,
    FareQuotes? refreshedQuote,
    String? keepVehicleTypeId,
    bool clearError = false,
    bool clearCreated = false,
    bool clearQuote = false,
  }) {
    return ConfirmState(
      cards: cards ?? this.cards,
      status: status ?? this.status,
      error: clearError ? null : error ?? this.error,
      created: clearCreated ? null : created ?? this.created,
      refreshedQuote: clearQuote ? null : refreshedQuote ?? this.refreshedQuote,
      keepVehicleTypeId: keepVehicleTypeId ?? this.keepVehicleTypeId,
    );
  }
}

class ConfirmBloc extends Bloc<Object, ConfirmState> {
  ConfirmBloc(this._bookings, this._payments) : super(const ConfirmState()) {
    on<ConfirmCardsRequested>(_onCards);
    on<ConfirmBookRequested>(_onBook);
  }

  final BookingRepository _bookings;
  final PaymentRepository _payments;

  Future<void> _onCards(
    ConfirmCardsRequested event,
    Emitter<ConfirmState> emit,
  ) async {
    try {
      final cards = await _payments.list();
      emit(state.copyWith(cards: cards));
    } catch (_) {
      // Cash remains available when the card list cannot be loaded.
    }
  }

  Future<void> _onBook(
    ConfirmBookRequested event,
    Emitter<ConfirmState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ConfirmStatus.booking,
        clearError: true,
        clearCreated: true,
        clearQuote: true,
      ),
    );
    try {
      final booking = await _bookings.create(
        body: event.body,
        idempotencyKey: event.idempotencyKey,
      );
      emit(state.copyWith(status: ConfirmStatus.booked, created: booking));
    } on DioException catch (error) {
      final code = errorCode(error);
      final body = errorBody(error);
      if (error.response?.statusCode == 409 && code == 'QUOTE_EXPIRED') {
        final fresh = FareQuotes.tryParse(body?['quote'], priceChanged: true);
        emit(
          state.copyWith(
            status: ConfirmStatus.quoteExpired,
            refreshedQuote: fresh,
            keepVehicleTypeId: event.vehicleTypeId,
            error: 'The price changed. Confirm the new total, then book again.',
          ),
        );
        return;
      }
      if (error.response?.statusCode == 409) {
        emit(
          state.copyWith(
            status: ConfirmStatus.activeTrip,
            error:
                'You already have an active trip. Finish or cancel it before '
                'booking another.',
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: ConfirmStatus.failure,
          error: errorMessage(error),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ConfirmStatus.failure,
          error: errorMessage(error),
        ),
      );
    }
  }
}
