import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/driver_flag_ride_config.dart';
import '../data/models/driver_flag_ride_model.dart';
import '../data/models/driver_flag_ride_status.dart';
import '../data/repositories/driver_flag_ride_repository.dart';
import 'driver_flag_ride_event.dart';
import 'driver_flag_ride_state.dart';

class DriverFlagRideBloc
    extends Bloc<DriverFlagRideEvent, DriverFlagRideState> {
  final DriverFlagRideRepository repository;

  DriverFlagRideBloc({
    required this.repository,
    DriverFlagRideStatus? initialStatus,
  }) : super(DriverFlagRideState.initial(initialStatus: initialStatus)) {
    on<DriverFlagRideStarted>(_onStarted);
    on<DriverFlagPassengerCountIncremented>(_onPassengerIncremented);
    on<DriverFlagPassengerCountDecremented>(_onPassengerDecremented);
    on<DriverFlagDestinationSelected>(_onDestinationSelected);
    on<DriverFlagStartRidePressed>(_onStartRidePressed);
    on<DriverFlagEndTripPressed>(_onEndTripPressed);
    on<DriverFlagCashCollectedPressed>(_onCashCollectedPressed);
    on<DriverFlagEdgeCategorySelected>(_onEdgeCategorySelected);
    on<DriverFlagRetryTelemetryPressed>(_onRetryTelemetryPressed);
    on<DriverFlagRefreshCalculationPressed>(_onRefreshCalculationPressed);
    on<DriverFlagHoldMeterPressed>(_onHoldMeterPressed);
    on<DriverFlagEndOfflineRidePressed>(_onEndOfflineRidePressed);
    on<DriverFlagStateForced>(_onStateForced);
  }

  Future<void> _onStarted(
    DriverFlagRideStarted event,
    Emitter<DriverFlagRideState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final model = await repository.fetchFlagRideState();
      emit(state.copyWith(
        isLoading: false,
        ride: model,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load flag ride state: $e',
      ));
    }
  }

  void _onPassengerIncremented(
    DriverFlagPassengerCountIncremented event,
    Emitter<DriverFlagRideState> emit,
  ) {
    if (state.ride.passengerCount < 4) {
      emit(state.copyWith(
        ride: state.ride.copyWith(
          passengerCount: state.ride.passengerCount + 1,
        ),
      ));
    }
  }

  void _onPassengerDecremented(
    DriverFlagPassengerCountDecremented event,
    Emitter<DriverFlagRideState> emit,
  ) {
    if (state.ride.passengerCount > 1) {
      emit(state.copyWith(
        ride: state.ride.copyWith(
          passengerCount: state.ride.passengerCount - 1,
        ),
      ));
    }
  }

  void _onDestinationSelected(
    DriverFlagDestinationSelected event,
    Emitter<DriverFlagRideState> emit,
  ) {
    emit(state.copyWith(
      ride: state.ride.copyWith(dropoffAddress: event.destination),
    ));
  }

  Future<void> _onStartRidePressed(
    DriverFlagStartRidePressed event,
    Emitter<DriverFlagRideState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await repository.startFlagRide(
        passengerCount: state.ride.passengerCount,
        destination: state.ride.dropoffAddress.isNotEmpty
            ? state.ride.dropoffAddress
            : null,
      );
      emit(state.copyWith(
        isLoading: false,
        status: DriverFlagRideStatus.flagInProgress,
        ride: DriverFlagRideConfig.flagInProgressPreset.copyWith(
          passengerCount: state.ride.passengerCount,
        ),
        toastMessage:
            'Virtual taximeter activated. City of Lethbridge Bylaw 6138 compliant.',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Could not activate flag meter: $e',
      ));
    }
  }

  Future<void> _onEndTripPressed(
    DriverFlagEndTripPressed event,
    Emitter<DriverFlagRideState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await repository.endFlagRide(state.ride.flagTripId);
      emit(state.copyWith(
        isLoading: false,
        status: DriverFlagRideStatus.flagComplete,
        ride: DriverFlagRideConfig.flagCompletePreset,
        toastMessage: 'Flag ride ended. Fare calculated: \$18.60 CAD',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to terminate trip: $e',
      ));
    }
  }

  Future<void> _onCashCollectedPressed(
    DriverFlagCashCollectedPressed event,
    Emitter<DriverFlagRideState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await repository.collectCashPayment(
        flagTripId: state.ride.flagTripId,
        amount: state.ride.computedFareCad,
      );
      emit(state.copyWith(
        isLoading: false,
        ride: state.ride.copyWith(isCashCollected: true),
        isReturnedToHome: true,
        toastMessage:
            'Cash payment of \$18.60 confirmed. Shift ledger auto-credited.',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to record cash payment: $e',
      ));
    }
  }

  void _onEdgeCategorySelected(
    DriverFlagEdgeCategorySelected event,
    Emitter<DriverFlagRideState> emit,
  ) {
    emit(state.copyWith(
      ride: state.ride.copyWith(
        edgeModel: state.ride.edgeModel.copyWith(
          activeCategory: event.categoryIndex,
        ),
      ),
    ));
  }

  Future<void> _onRetryTelemetryPressed(
    DriverFlagRetryTelemetryPressed event,
    Emitter<DriverFlagRideState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await repository.retryTelemetry(state.ride.flagTripId);
      emit(state.copyWith(
        isLoading: false,
        toastMessage: 'Re-connecting with River Valley cell relay...',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Retry failed: $e',
      ));
    }
  }

  Future<void> _onRefreshCalculationPressed(
    DriverFlagRefreshCalculationPressed event,
    Emitter<DriverFlagRideState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await repository.refreshFareCalculation(state.ride.flagTripId);
      emit(state.copyWith(
        isLoading: false,
        toastMessage: 'Tariff audit refreshed with City of Lethbridge rates.',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Calculation refresh failed: $e',
      ));
    }
  }

  void _onHoldMeterPressed(
    DriverFlagHoldMeterPressed event,
    Emitter<DriverFlagRideState> emit,
  ) {
    emit(state.copyWith(
      toastMessage: 'Meter held. Temporary pause state recorded.',
    ));
  }

  void _onEndOfflineRidePressed(
    DriverFlagEndOfflineRidePressed event,
    Emitter<DriverFlagRideState> emit,
  ) {
    emit(state.copyWith(
      status: DriverFlagRideStatus.flagComplete,
      ride: DriverFlagRideConfig.flagCompletePreset,
      toastMessage: 'Offline ride completed. In-cab vault hash secured.',
    ));
  }

  void _onStateForced(
    DriverFlagRideStateForced event,
    Emitter<DriverFlagRideState> emit,
  ) {
    DriverFlagRideModel model;
    switch (event.status) {
      case DriverFlagRideStatus.startFlagRide:
        model = DriverFlagRideConfig.startFlagRidePreset;
        break;
      case DriverFlagRideStatus.flagInProgress:
        model = DriverFlagRideConfig.flagInProgressPreset;
        break;
      case DriverFlagRideStatus.flagComplete:
        model = DriverFlagRideConfig.flagCompletePreset;
        break;
      case DriverFlagRideStatus.edgeStates:
        model = DriverFlagRideConfig.edgeStatesPreset;
        break;
      case DriverFlagRideStatus.returnedToHome:
        model = DriverFlagRideConfig.startFlagRidePreset;
        break;
    }

    emit(state.copyWith(
      status: event.status,
      ride: model,
      clearError: true,
      clearToast: true,
      isReturnedToHome: event.status == DriverFlagRideStatus.returnedToHome,
    ));
  }
}
