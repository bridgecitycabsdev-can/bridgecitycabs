import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passenger_app/data/repositories/payment_repository.dart';
import 'package:passenger_app/features/booking/saved_card.dart';

class CardsLoadRequested {
  const CardsLoadRequested();
}

class CardsSetDefaultRequested {
  const CardsSetDefaultRequested(this.id);

  final String id;
}

class CardsRemoveRequested {
  const CardsRemoveRequested(this.id);

  final String id;
}

enum CardsStatus { loading, ready, failure }

class CardsState {
  const CardsState({
    this.status = CardsStatus.loading,
    this.cards = const [],
    this.error,
  });

  final CardsStatus status;
  final List<SavedCard> cards;
  final String? error;
}

class CardsBloc extends Bloc<Object, CardsState> {
  CardsBloc(this._payments) : super(const CardsState()) {
    on<CardsLoadRequested>(_onLoad);
    on<CardsSetDefaultRequested>(_onDefault);
    on<CardsRemoveRequested>(_onRemove);
  }

  final PaymentRepository _payments;

  Future<void> _onLoad(
    CardsLoadRequested event,
    Emitter<CardsState> emit,
  ) async {
    emit(CardsState(cards: state.cards));
    try {
      final cards = await _payments.list();
      emit(CardsState(status: CardsStatus.ready, cards: cards));
    } catch (error) {
      emit(
        CardsState(
          status: CardsStatus.failure,
          cards: state.cards,
          error: errorMessage(error),
        ),
      );
    }
  }

  Future<void> _onDefault(
    CardsSetDefaultRequested event,
    Emitter<CardsState> emit,
  ) async {
    await _payments.setDefault(event.id);
    add(const CardsLoadRequested());
  }

  Future<void> _onRemove(
    CardsRemoveRequested event,
    Emitter<CardsState> emit,
  ) async {
    await _payments.remove(event.id);
    add(const CardsLoadRequested());
  }
}
