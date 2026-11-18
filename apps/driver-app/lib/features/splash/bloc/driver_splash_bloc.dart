import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/driver_splash_model.dart';
import '../data/repositories/driver_splash_repository.dart';
import 'driver_splash_event.dart';
import 'driver_splash_state.dart';

class DriverSplashBloc extends Bloc<DriverSplashEvent, DriverSplashState> {
  final DriverSplashRepository repository;

  DriverSplashBloc({DriverSplashRepository? repository})
      : repository = repository ?? MockDriverSplashRepository(),
        super(const DriverSplashState()) {
    on<DriverSplashStarted>(_onStarted);
    on<DriverSplashRetryTapped>(_onRetryTapped);
    on<DriverSplashUpdateNowTapped>(_onUpdateNowTapped);
    on<DriverSplashStatusChanged>(_onStatusChanged);
  }

  Future<void> _onStarted(
    DriverSplashStarted event,
    Emitter<DriverSplashState> emit,
  ) async {
    final hub = await repository.getHubInfo();

    if (event.initialStatus != DriverSplashStatus.initial) {
      emit(state.copyWith(
        status: event.initialStatus,
        hubInfo: hub,
      ));
      return;
    }

    emit(state.copyWith(
      status: DriverSplashStatus.initial,
      hubInfo: hub,
    ));

    final isUpdateNeeded = await repository.isUpdateRequired();
    if (isUpdateNeeded) {
      emit(state.copyWith(status: DriverSplashStatus.updateRequired));
      return;
    }

    final isOnline = await repository.checkFleetConnectivity();
    if (!isOnline) {
      emit(state.copyWith(status: DriverSplashStatus.connectionError));
      return;
    }

    // Normal successful bootstrap completes to ready
    emit(state.copyWith(status: DriverSplashStatus.ready));
  }

  Future<void> _onRetryTapped(
    DriverSplashRetryTapped event,
    Emitter<DriverSplashState> emit,
  ) async {
    emit(state.copyWith(
      isRetrying: true,
      status: DriverSplashStatus.connecting,
      feedbackMessage: 'Reconnecting to Lethbridge Hub...',
      retryCount: state.retryCount + 1,
    ));

    final success = await repository.retryHubConnection();
    if (success) {
      emit(state.copyWith(
        isRetrying: false,
        status: DriverSplashStatus.ready,
        feedbackMessage: 'Connected to Lethbridge Fleet Dispatch.',
      ));
    } else {
      emit(state.copyWith(
        isRetrying: false,
        status: DriverSplashStatus.connectionError,
        feedbackMessage: "Couldn't connect. Check your internet and try again.",
      ));
    }
  }

  void _onUpdateNowTapped(
    DriverSplashUpdateNowTapped event,
    Emitter<DriverSplashState> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage: 'Opening store to update Bridge City Cabs Driver...',
    ));
  }

  void _onStatusChanged(
    DriverSplashStatusChanged event,
    Emitter<DriverSplashState> emit,
  ) {
    emit(state.copyWith(status: event.status));
  }
}
