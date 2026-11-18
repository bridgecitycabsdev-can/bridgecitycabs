import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/connection_status.dart';
import '../../data/models/splash_config.dart';
import '../../data/repositories/splash_repository.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final SplashRepository _repository;
  Timer? _slowConnectionTimer;
  Timer? _timeoutTimer;

  SplashBloc({required SplashRepository repository})
      : _repository = repository,
        super(const SplashInitial()) {
    on<SplashStarted>(_onStarted);
    on<SplashSlowConnectionDetected>(_onSlowConnectionDetected);
    on<SplashConnectionFailed>(_onConnectionFailed);
    on<SplashRetryRequested>(_onRetryRequested);
    on<SplashHotlineCallRequested>(_onHotlineCallRequested);
    on<SplashBootstrapCompleted>(_onBootstrapCompleted);
  }

  Future<void> _onStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    _cancelTimers();
    emit(SplashLoading(retryCount: state.retryCount));
    await _performBootstrap(emit);
  }

  Future<void> _onRetryRequested(
    SplashRetryRequested event,
    Emitter<SplashState> emit,
  ) async {
    _cancelTimers();
    emit(SplashLoading(retryCount: state.retryCount + 1));
    await _performBootstrap(emit);
  }

  Future<void> _performBootstrap(Emitter<SplashState> emit) async {
    // 1. Setup fallback timer for slow connection (Screenshot 2: "Still connecting...")
    _slowConnectionTimer = Timer(SplashConfig.slowConnectionThreshold, () {
      if (!isClosed && state is SplashLoading) {
        add(const SplashSlowConnectionDetected());
      }
    });

    // 2. Setup hard timeout timer for offline/unreachable fallback (Screenshot 3: "Connection Interrupted")
    _timeoutTimer = Timer(SplashConfig.offlineTimeoutThreshold, () {
      if (!isClosed && (state is SplashLoading || state is SplashSlowConnection)) {
        add(const SplashConnectionFailed(
          errorMessage: SplashConfig.errorSubtitle,
          isOffline: true,
        ));
      }
    });

    try {
      final connectivity = await _repository.checkFleetDispatchConnectivity();
      _cancelTimers();

      if (connectivity.quality == NetworkQuality.offline ||
          !connectivity.isFleetDispatchReachable) {
        emit(SplashConnectionInterrupted(
          retryCount: state.retryCount,
          message: connectivity.detailMessage ?? SplashConfig.errorSubtitle,
          isOffline: true,
        ));
        return;
      }

      if (connectivity.quality == NetworkQuality.lowSignal) {
        emit(SplashSlowConnection(retryCount: state.retryCount));
        // Give an extra grace period before proceeding
        await Future<void>.delayed(const Duration(milliseconds: 1500));
      }

      // Check user session
      final hasSession = await _repository.hasStoredSession();
      final destination = hasSession ? '/home' : '/phone';

      emit(SplashSuccess(
        isAuthenticated: hasSession,
        destinationRoute: destination,
        retryCount: state.retryCount,
      ));
    } catch (e) {
      _cancelTimers();
      emit(SplashConnectionInterrupted(
        retryCount: state.retryCount,
        message: e.toString(),
        isOffline: true,
      ));
    }
  }

  void _onSlowConnectionDetected(
    SplashSlowConnectionDetected event,
    Emitter<SplashState> emit,
  ) {
    if (state is SplashLoading) {
      emit(SplashSlowConnection(
        retryCount: state.retryCount,
        dispatchNotice: event.notice,
      ));
    }
  }

  void _onConnectionFailed(
    SplashConnectionFailed event,
    Emitter<SplashState> emit,
  ) {
    _cancelTimers();
    emit(SplashConnectionInterrupted(
      retryCount: state.retryCount,
      message: event.errorMessage,
      isOffline: event.isOffline,
    ));
  }

  Future<void> _onHotlineCallRequested(
    SplashHotlineCallRequested event,
    Emitter<SplashState> emit,
  ) async {
    await _repository.callUrgentCabHotline();
  }

  void _onBootstrapCompleted(
    SplashBootstrapCompleted event,
    Emitter<SplashState> emit,
  ) {
    _cancelTimers();
    emit(SplashSuccess(
      isAuthenticated: event.isAuthenticated,
      destinationRoute: event.destinationRoute,
      retryCount: state.retryCount,
    ));
  }

  void _cancelTimers() {
    _slowConnectionTimer?.cancel();
    _slowConnectionTimer = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  @override
  Future<void> close() {
    _cancelTimers();
    return super.close();
  }
}
