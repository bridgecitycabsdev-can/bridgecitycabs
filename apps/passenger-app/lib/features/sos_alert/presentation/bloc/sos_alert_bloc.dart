import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/sos_alert_model.dart';
import '../../data/repositories/sos_alert_repository.dart';
import 'sos_alert_event.dart';
import 'sos_alert_state.dart';

class SosAlertBloc extends Bloc<SosAlertEvent, SosAlertState> {
  final SosAlertRepository _repository;

  SosAlertBloc({required SosAlertRepository repository})
      : _repository = repository,
        super(const SosAlertState()) {
    on<SosAlertStarted>(_onStarted);
    on<SosAlertSendTapped>(_onSendTapped);
    on<SosAlertUpdateLocationTapped>(_onUpdateLocationTapped);
    on<SosAlertRetryTapped>(_onRetryTapped);
    on<SosAlertLocationSettingsOpened>(_onLocationSettingsOpened);
    on<SosAlertSendAnywayTapped>(_onSendAnywayTapped);
    on<SosAlertCancelTapped>(_onCancelTapped);
    on<SosAlertCall911Tapped>(_onCall911Tapped);
    on<SosAlertCallSafetyLineTapped>(_onCallSafetyLineTapped);
    on<SosAlertBackToTripTapped>(_onBackToTripTapped);
  }

  Future<void> _onStarted(
    SosAlertStarted event,
    Emitter<SosAlertState> emit,
  ) async {
    final telemetry = event.telemetry ?? await _repository.getRideTelemetry();
    final locationStatus = event.locationEnabled != null
        ? (event.locationEnabled!
            ? LocationServiceStatus.enabled
            : LocationServiceStatus.disabled)
        : await _repository.checkLocationService();

    final status = event.initialStatus ?? SosAlertStatus.readyToSend;
    final errorMessage = event.simulateNetworkFailure == true
        ? 'Cellular handshake failed near Whoop-Up Dr corridor. Packet queued locally.'
        : null;

    emit(state.copyWith(
      telemetry: telemetry,
      locationStatus: locationStatus,
      status: status,
      networkErrorMessage: () => errorMessage,
    ));
  }

  Future<void> _onSendTapped(
    SosAlertSendTapped event,
    Emitter<SosAlertState> emit,
  ) async {
    emit(state.copyWith(
      status: SosAlertStatus.sending,
      networkErrorMessage: () => null,
    ));

    try {
      await _repository.sendEmergencyAlert(telemetry: state.telemetry);
      emit(state.copyWith(
        status: SosAlertStatus.active,
        alertSentTimestamp: () => DateTime.now(),
        beaconPingCount: 1,
        userFeedbackMessage: () => 'Emergency alert received by Lethbridge Safety Ops',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SosAlertStatus.failed,
        networkErrorMessage: () => e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onUpdateLocationTapped(
    SosAlertUpdateLocationTapped event,
    Emitter<SosAlertState> emit,
  ) async {
    emit(state.copyWith(isUpdatingLocation: true));
    try {
      await _repository.updateEmergencyLocation(
        address: state.telemetry.currentAddress,
      );
      emit(state.copyWith(
        isUpdatingLocation: false,
        beaconPingCount: state.beaconPingCount + 1,
        userFeedbackMessage: () => 'Coordinates re-synchronized with Lethbridge Patrol',
      ));
    } catch (_) {
      emit(state.copyWith(isUpdatingLocation: false));
    }
  }

  Future<void> _onRetryTapped(
    SosAlertRetryTapped event,
    Emitter<SosAlertState> emit,
  ) async {
    emit(state.copyWith(networkErrorMessage: () => null));
    add(const SosAlertSendTapped());
  }

  void _onLocationSettingsOpened(
    SosAlertLocationSettingsOpened event,
    Emitter<SosAlertState> emit,
  ) {
    emit(state.copyWith(
      locationStatus: LocationServiceStatus.enabled,
      dismissedLocationWarning: true,
      userFeedbackMessage: () => 'Location services enabled.',
    ));
  }

  void _onSendAnywayTapped(
    SosAlertSendAnywayTapped event,
    Emitter<SosAlertState> emit,
  ) {
    emit(state.copyWith(dismissedLocationWarning: true));
    add(const SosAlertSendTapped());
  }

  Future<void> _onCancelTapped(
    SosAlertCancelTapped event,
    Emitter<SosAlertState> emit,
  ) async {
    await _repository.cancelAlert();
    emit(state.copyWith(status: SosAlertStatus.cancelled));
  }

  void _onCall911Tapped(
    SosAlertCall911Tapped event,
    Emitter<SosAlertState> emit,
  ) {
    emit(state.copyWith(
      userFeedbackMessage: () => 'Dialing 911 Emergency Services...',
    ));
  }

  void _onCallSafetyLineTapped(
    SosAlertCallSafetyLineTapped event,
    Emitter<SosAlertState> emit,
  ) {
    emit(state.copyWith(
      userFeedbackMessage: () => 'Calling Lethbridge Safety Line: 403-328-8888',
    ));
  }

  void _onBackToTripTapped(
    SosAlertBackToTripTapped event,
    Emitter<SosAlertState> emit,
  ) {
    emit(state.copyWith(
      userFeedbackMessage: () => 'Returning to active trip tracking. Safety alert remains active.',
    ));
  }
}
