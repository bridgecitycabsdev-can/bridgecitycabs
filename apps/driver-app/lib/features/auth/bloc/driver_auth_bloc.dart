import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/driver_auth_config.dart';
import '../data/models/driver_auth_status.dart';
import '../data/models/driver_fleet_zone_info.dart';
import '../data/repositories/driver_auth_repository.dart';
import 'driver_auth_event.dart';
import 'driver_auth_state.dart';

class DriverAuthBloc extends Bloc<DriverAuthEvent, DriverAuthState> {
  final DriverAuthRepository repository;
  Timer? _lockoutTimer;

  DriverAuthBloc({DriverAuthRepository? repository})
      : repository = repository ?? MockDriverAuthRepository(),
        super(const DriverAuthState()) {
    on<DriverAuthPhoneChanged>(_onPhoneChanged);
    on<DriverAuthPhoneCleared>(_onPhoneCleared);
    on<DriverAuthSubmitted>(_onSubmitted);
    on<DriverAuthBecomeDriverTapped>(_onBecomeDriverTapped);
    on<DriverAuthLockoutTick>(_onLockoutTick);
    on<DriverAuthNotYourNumberTapped>(_onNotYourNumberTapped);
    on<DriverAuthStateSwitched>(_onStateSwitched);
  }

  @override
  Future<void> close() {
    _lockoutTimer?.cancel();
    return super.close();
  }

  static String _formatPhone(String rawDigits) {
    if (rawDigits.isEmpty) return '';
    if (rawDigits.length <= 3) return '($rawDigits';
    if (rawDigits.length <= 6) {
      return '(${rawDigits.substring(0, 3)}) ${rawDigits.substring(3)}';
    }
    final end = rawDigits.length > 10 ? 10 : rawDigits.length;
    return '(${rawDigits.substring(0, 3)}) ${rawDigits.substring(3, 6)}-${rawDigits.substring(6, end)}';
  }

  void _onPhoneChanged(
    DriverAuthPhoneChanged event,
    Emitter<DriverAuthState> emit,
  ) {
    if (state.isLocked) return;

    var digits = event.phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('1') && digits.length > 10) {
      digits = digits.substring(1);
    }
    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }

    final formatted = _formatPhone(digits);

    if (digits.isEmpty) {
      emit(state.copyWith(
        status: DriverAuthStatus.initial,
        rawInput: event.phone,
        digitsOnly: digits,
        formattedPhone: formatted,
        errorMessage: null,
      ));
      return;
    }

    if (digits.length < 10) {
      emit(state.copyWith(
        status: DriverAuthStatus.invalid,
        rawInput: event.phone,
        digitsOnly: digits,
        formattedPhone: formatted,
        fleetInfo: DriverFleetZoneInfo.registeredFleet,
        errorMessage: DriverAuthConfig.invalidPhoneMessage,
      ));
      return;
    }

    // 10 digits entered
    if (digits == '4035559876') {
      emit(state.copyWith(
        status: DriverAuthStatus.unregistered,
        rawInput: event.phone,
        digitsOnly: digits,
        formattedPhone: formatted,
        fleetInfo: DriverFleetZoneInfo.cityFleet,
        errorMessage: null,
      ));
      return;
    }

    emit(state.copyWith(
      status: DriverAuthStatus.valid,
      rawInput: event.phone,
      digitsOnly: digits,
      formattedPhone: formatted,
      fleetInfo: DriverFleetZoneInfo.surgeActive,
      errorMessage: null,
    ));
  }

  void _onPhoneCleared(
    DriverAuthPhoneCleared event,
    Emitter<DriverAuthState> emit,
  ) {
    if (state.isLocked) return;
    emit(state.copyWith(
      status: DriverAuthStatus.initial,
      rawInput: '',
      digitsOnly: '',
      formattedPhone: '',
      errorMessage: null,
      fleetInfo: DriverFleetZoneInfo.surgeActive,
    ));
  }

  Future<void> _onSubmitted(
    DriverAuthSubmitted event,
    Emitter<DriverAuthState> emit,
  ) async {
    if (!state.canContinue || state.isSubmitting || state.isLocked) return;

    emit(state.copyWith(
      status: DriverAuthStatus.submitting,
      feedbackMessage: 'Sending verification code...',
    ));

    final isRegistered = await repository.isRegisteredDriver(state.digitsOnly);
    if (!isRegistered) {
      emit(state.copyWith(
        status: DriverAuthStatus.unregistered,
        fleetInfo: DriverFleetZoneInfo.cityFleet,
        feedbackMessage: DriverAuthConfig.unregisteredAccountTitle,
      ));
      return;
    }

    final success = await repository.sendVerificationCode(state.digitsOnly);
    if (success) {
      emit(state.copyWith(
        status: DriverAuthStatus.codeSent,
        feedbackMessage: 'Verification code sent to ${state.formattedPhone}',
      ));
    } else {
      emit(state.copyWith(
        status: DriverAuthStatus.valid,
        feedbackMessage: 'Failed to send code. Please try again.',
      ));
    }
  }

  void _onBecomeDriverTapped(
    DriverAuthBecomeDriverTapped event,
    Emitter<DriverAuthState> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage: 'Redirecting to Bridge City Cabs driver onboarding...',
    ));
  }

  void _onNotYourNumberTapped(
    DriverAuthNotYourNumberTapped event,
    Emitter<DriverAuthState> emit,
  ) {
    _lockoutTimer?.cancel();
    emit(state.copyWith(
      status: DriverAuthStatus.initial,
      rawInput: '',
      digitsOnly: '',
      formattedPhone: '',
      failedAttempts: 0,
      errorMessage: null,
      fleetInfo: DriverFleetZoneInfo.surgeActive,
    ));
  }

  void _onLockoutTick(
    DriverAuthLockoutTick event,
    Emitter<DriverAuthState> emit,
  ) {
    if (state.lockoutRemainingSeconds > 1) {
      emit(state.copyWith(
        lockoutRemainingSeconds: state.lockoutRemainingSeconds - 1,
      ));
    } else {
      _lockoutTimer?.cancel();
      emit(state.copyWith(
        status: DriverAuthStatus.valid,
        lockoutRemainingSeconds: 0,
        failedAttempts: 0,
      ));
    }
  }

  void _onStateSwitched(
    DriverAuthStateSwitched event,
    Emitter<DriverAuthState> emit,
  ) {
    _lockoutTimer?.cancel();

    switch (event.status) {
      case DriverAuthStatus.initial:
        emit(state.copyWith(
          status: DriverAuthStatus.initial,
          rawInput: '',
          digitsOnly: '',
          formattedPhone: '',
          errorMessage: null,
          failedAttempts: 0,
          fleetInfo: DriverFleetZoneInfo.surgeActive,
        ));
        break;

      case DriverAuthStatus.valid:
        emit(state.copyWith(
          status: DriverAuthStatus.valid,
          rawInput: '4035550192',
          digitsOnly: '4035550192',
          formattedPhone: '(403) 555-0192',
          errorMessage: null,
          failedAttempts: 0,
          fleetInfo: DriverFleetZoneInfo.surgeActive,
        ));
        break;

      case DriverAuthStatus.invalid:
        emit(state.copyWith(
          status: DriverAuthStatus.invalid,
          rawInput: '40355501',
          digitsOnly: '40355501',
          formattedPhone: '(403) 555-01',
          errorMessage: DriverAuthConfig.invalidPhoneMessage,
          failedAttempts: 0,
          fleetInfo: DriverFleetZoneInfo.registeredFleet,
        ));
        break;

      case DriverAuthStatus.unregistered:
        emit(state.copyWith(
          status: DriverAuthStatus.unregistered,
          rawInput: '4035559876',
          digitsOnly: '4035559876',
          formattedPhone: '(403) 555-9876',
          errorMessage: null,
          failedAttempts: 0,
          fleetInfo: DriverFleetZoneInfo.cityFleet,
        ));
        break;

      case DriverAuthStatus.locked:
        emit(state.copyWith(
          status: DriverAuthStatus.locked,
          rawInput: '4035550192',
          digitsOnly: '4035550192',
          formattedPhone: '(403) 555-0192',
          errorMessage: null,
          failedAttempts: 5,
          lockoutRemainingSeconds: 897, // 14:57
          fleetInfo: DriverFleetZoneInfo.surgeActive,
        ));
        break;

      case DriverAuthStatus.submitting:
        emit(state.copyWith(
          status: DriverAuthStatus.submitting,
          rawInput: '4035550192',
          digitsOnly: '4035550192',
          formattedPhone: '(403) 555-0192',
          errorMessage: null,
          fleetInfo: DriverFleetZoneInfo.surgeActive,
        ));
        break;

      case DriverAuthStatus.codeSent:
        emit(state.copyWith(
          status: DriverAuthStatus.codeSent,
          feedbackMessage: 'Verification code sent to (403) 555-0192',
        ));
        break;
    }
  }
}
