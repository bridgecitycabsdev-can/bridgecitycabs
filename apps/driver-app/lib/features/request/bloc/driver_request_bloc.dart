import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/driver_decline_reason.dart';
import '../data/models/driver_request_config.dart';
import '../data/models/driver_request_model.dart';
import '../data/models/driver_request_status.dart';
import '../data/repositories/driver_request_repository.dart';
import 'driver_request_event.dart';
import 'driver_request_state.dart';

class DriverRequestBloc extends Bloc<DriverRequestEvent, DriverRequestState> {
  final DriverRequestRepository repository;
  StreamSubscription<int>? _timerSubscription;

  DriverRequestBloc({required this.repository})
      : super(DriverRequestState.initial()) {
    on<DriverRequestStarted>(_onStarted);
    on<DriverRequestTimerTicked>(_onTimerTicked);
    on<DriverRequestAcceptPressed>(_onAcceptPressed);
    on<DriverRequestDeclinePressed>(_onDeclinePressed);
    on<DriverRequestReasonSelected>(_onReasonSelected);
    on<DriverRequestKeepAndAcceptPressed>(_onKeepAndAcceptPressed);
    on<DriverRequestDeclineConfirmed>(_onDeclineConfirmed);
    on<DriverRequestReturnToMapPressed>(_onReturnToMapPressed);
    on<DriverRequestStateForced>(_onStateForced);
  }

  void _onStarted(
    DriverRequestStarted event,
    Emitter<DriverRequestState> emit,
  ) {
    final req = event.initialRequest ?? DriverRequestConfig.instantPreset();
    emit(
      state.copyWith(
        status: event.initialStatus,
        request: req,
        impact: DriverRequestConfig.declineImpact(),
        queueInfo: DriverRequestConfig.takenQueueInfo(),
        selectedReason: null,
        isActionLoading: false,
        shouldNavigateToTrip: false,
        shouldNavigateToMap: false,
      ),
    );
  }

  void _onTimerTicked(
    DriverRequestTimerTicked event,
    Emitter<DriverRequestState> emit,
  ) {
    if (state.status == DriverRequestStatus.securingDispatch ||
        state.status == DriverRequestStatus.expired ||
        state.status == DriverRequestStatus.takenByAnother) {
      return;
    }

    final updatedRequest = state.request.copyWith(
      remainingSeconds: event.remainingSeconds,
    );

    if (event.remainingSeconds <= 0) {
      emit(
        state.copyWith(
          status: DriverRequestStatus.expired,
          request: updatedRequest,
          impact: DriverRequestConfig.expiredImpact(),
        ),
      );
    } else if (event.remainingSeconds <= 3 &&
        state.status == DriverRequestStatus.incomingInstant) {
      emit(
        state.copyWith(
          status: DriverRequestStatus.expiringUrgent,
          request: updatedRequest.copyWith(
            audioAlertText: 'HURRY! OFFER EXPIRING IN 4S',
          ),
        ),
      );
    } else {
      emit(state.copyWith(request: updatedRequest));
    }
  }

  Future<void> _onAcceptPressed(
    DriverRequestAcceptPressed event,
    Emitter<DriverRequestState> emit,
  ) async {
    _timerSubscription?.cancel();
    emit(
      state.copyWith(
        status: DriverRequestStatus.securingDispatch,
        isActionLoading: true,
      ),
    );

    try {
      await repository.acceptRequest(state.request.id);
      emit(
        state.copyWith(
          isActionLoading: false,
          shouldNavigateToTrip: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isActionLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onDeclinePressed(
    DriverRequestDeclinePressed event,
    Emitter<DriverRequestState> emit,
  ) {
    emit(
      state.copyWith(
        status: DriverRequestStatus.declineConfirmation,
        impact: DriverRequestConfig.declineImpact(),
      ),
    );
  }

  void _onReasonSelected(
    DriverRequestReasonSelected event,
    Emitter<DriverRequestState> emit,
  ) {
    emit(state.copyWith(selectedReason: event.reason));
  }

  Future<void> _onKeepAndAcceptPressed(
    DriverRequestKeepAndAcceptPressed event,
    Emitter<DriverRequestState> emit,
  ) async {
    add(const DriverRequestAcceptPressed());
  }

  Future<void> _onDeclineConfirmed(
    DriverRequestDeclineConfirmed event,
    Emitter<DriverRequestState> emit,
  ) async {
    _timerSubscription?.cancel();
    emit(state.copyWith(isActionLoading: true));
    try {
      await repository.declineRequest(
        state.request.id,
        reason: state.selectedReason,
      );
      emit(
        state.copyWith(
          isActionLoading: false,
          shouldNavigateToMap: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isActionLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onReturnToMapPressed(
    DriverRequestReturnToMapPressed event,
    Emitter<DriverRequestState> emit,
  ) {
    _timerSubscription?.cancel();
    emit(state.copyWith(shouldNavigateToMap: true));
  }

  void _onStateForced(
    DriverRequestStateForced event,
    Emitter<DriverRequestState> emit,
  ) {
    _timerSubscription?.cancel();
    switch (event.status) {
      case DriverRequestStatus.incomingInstant:
        emit(
          state.copyWith(
            status: DriverRequestStatus.incomingInstant,
            request: DriverRequestConfig.instantPreset(),
            impact: DriverRequestConfig.declineImpact(),
            isActionLoading: false,
            shouldNavigateToTrip: false,
            shouldNavigateToMap: false,
          ),
        );
        break;
      case DriverRequestStatus.securingDispatch:
        emit(
          state.copyWith(
            status: DriverRequestStatus.securingDispatch,
            request: DriverRequestConfig.instantPreset(),
            isActionLoading: true,
            shouldNavigateToTrip: false,
            shouldNavigateToMap: false,
          ),
        );
        break;
      case DriverRequestStatus.expiringUrgent:
        emit(
          state.copyWith(
            status: DriverRequestStatus.expiringUrgent,
            request: DriverRequestConfig.urgentPreset(),
            isActionLoading: false,
            shouldNavigateToTrip: false,
            shouldNavigateToMap: false,
          ),
        );
        break;
      case DriverRequestStatus.expired:
        emit(
          state.copyWith(
            status: DriverRequestStatus.expired,
            request: DriverRequestConfig.instantPreset().copyWith(
              remainingSeconds: 0,
            ),
            impact: DriverRequestConfig.expiredImpact(),
            isActionLoading: false,
            shouldNavigateToTrip: false,
            shouldNavigateToMap: false,
          ),
        );
        break;
      case DriverRequestStatus.takenByAnother:
        emit(
          state.copyWith(
            status: DriverRequestStatus.takenByAnother,
            request: DriverRequestConfig.instantPreset(),
            queueInfo: DriverRequestConfig.takenQueueInfo(),
            isActionLoading: false,
            shouldNavigateToTrip: false,
            shouldNavigateToMap: false,
          ),
        );
        break;
      case DriverRequestStatus.scheduled:
        emit(
          state.copyWith(
            status: DriverRequestStatus.scheduled,
            request: DriverRequestConfig.scheduledPreset(),
            isActionLoading: false,
            shouldNavigateToTrip: false,
            shouldNavigateToMap: false,
          ),
        );
        break;
      case DriverRequestStatus.declineConfirmation:
        emit(
          state.copyWith(
            status: DriverRequestStatus.declineConfirmation,
            request: DriverRequestConfig.declineTargetPreset(),
            impact: DriverRequestConfig.declineImpact(),
            selectedReason: null,
            isActionLoading: false,
            shouldNavigateToTrip: false,
            shouldNavigateToMap: false,
          ),
        );
        break;
    }
  }

  @override
  Future<void> close() {
    _timerSubscription?.cancel();
    return super.close();
  }
}
