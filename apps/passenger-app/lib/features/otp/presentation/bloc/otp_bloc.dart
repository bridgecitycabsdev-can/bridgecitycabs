import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/otp_config.dart';
import '../../data/models/otp_timer.dart';
import '../../data/repositories/otp_repository.dart';
import 'otp_event.dart';
import 'otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final OtpRepository _repository;
  Timer? _countdownTimer;

  OtpBloc({
    required OtpRepository repository,
    String initialPhone = '',
  })  : _repository = repository,
        super(OtpInitialState(phone: initialPhone)) {
    on<OtpStarted>(_onStarted);
    on<OtpDigitEntered>(_onDigitEntered);
    on<OtpDigitDeleted>(_onDigitDeleted);
    on<OtpCodeAutofilled>(_onCodeAutofilled);
    on<OtpSubmitRequested>(_onSubmitRequested);
    on<OtpResendRequested>(_onResendRequested);
    on<OtpResendTicked>(_onResendTicked);
    on<OtpExpiredTriggered>(_onExpiredTriggered);
    on<OtpEditPhoneTapped>(_onEditPhoneTapped);

    if (initialPhone.isNotEmpty) {
      _startResendTimer(OtpConfig.defaultResendSeconds);
    }
  }

  void _onStarted(
    OtpStarted event,
    Emitter<OtpState> emit,
  ) {
    _startResendTimer(OtpConfig.defaultResendSeconds);
    emit(OtpInitialState(
      phone: event.phone,
      resendTimer: const OtpTimer(remainingSeconds: OtpConfig.defaultResendSeconds),
    ));
  }

  void _onDigitEntered(
    OtpDigitEntered event,
    Emitter<OtpState> emit,
  ) {
    if (state.isVerifying || state.isExpired) return;
    if (state.code.length >= OtpConfig.codeLength) return;

    final newCode = '${state.code}${event.digit}';
    if (newCode.length == OtpConfig.codeLength) {
      emit(OtpAutofilledState(
        phone: state.phone,
        code: newCode,
        resendTimer: state.resendTimer,
        attemptsRemaining: state.attemptsRemaining,
      ));
    } else {
      emit(OtpTypingState(
        phone: state.phone,
        code: newCode,
        resendTimer: state.resendTimer,
        attemptsRemaining: state.attemptsRemaining,
      ));
    }
  }

  void _onDigitDeleted(
    OtpDigitDeleted event,
    Emitter<OtpState> emit,
  ) {
    if (state.isVerifying || state.isExpired) return;
    if (state.code.isEmpty) return;

    final newCode = state.code.substring(0, state.code.length - 1);
    if (newCode.isEmpty) {
      emit(OtpInitialState(
        phone: state.phone,
        showSuccessToast: false,
        resendTimer: state.resendTimer,
        attemptsRemaining: state.attemptsRemaining,
      ));
    } else {
      emit(OtpTypingState(
        phone: state.phone,
        code: newCode,
        resendTimer: state.resendTimer,
        attemptsRemaining: state.attemptsRemaining,
      ));
    }
  }

  void _onCodeAutofilled(
    OtpCodeAutofilled event,
    Emitter<OtpState> emit,
  ) {
    if (state.isVerifying || state.isExpired) return;
    emit(OtpAutofilledState(
      phone: state.phone,
      code: event.code,
      resendTimer: state.resendTimer,
      attemptsRemaining: state.attemptsRemaining,
    ));
  }

  Future<void> _onSubmitRequested(
    OtpSubmitRequested event,
    Emitter<OtpState> emit,
  ) async {
    if (!state.canSubmit) return;

    emit(OtpVerifyingState(
      phone: state.phone,
      code: state.code,
      resendTimer: state.resendTimer,
      attemptsRemaining: state.attemptsRemaining,
    ));

    try {
      final success = await _repository.verifyOtp(state.phone, state.code);
      if (success) {
        emit(OtpSuccessState(
          phone: state.phone,
          code: state.code,
          targetRoute: '/home',
        ));
      }
    } catch (e) {
      final remaining = (state.attemptsRemaining - 1).clamp(0, OtpConfig.maxAttempts);
      if (remaining <= 0) {
        emit(OtpExpiredState(
          phone: state.phone,
          code: state.code,
        ));
      } else {
        emit(OtpErrorState(
          phone: state.phone,
          code: state.code,
          attemptsRemaining: remaining,
          resendTimer: state.resendTimer,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  Future<void> _onResendRequested(
    OtpResendRequested event,
    Emitter<OtpState> emit,
  ) async {
    _startResendTimer(OtpConfig.defaultResendSeconds);
    await _repository.resendOtp(state.phone);

    emit(OtpInitialState(
      phone: state.phone,
      code: '',
      showSuccessToast: true,
      resendTimer: const OtpTimer(remainingSeconds: OtpConfig.defaultResendSeconds),
      attemptsRemaining: OtpConfig.maxAttempts,
    ));
  }

  void _onResendTicked(
    OtpResendTicked event,
    Emitter<OtpState> emit,
  ) {
    final timer = OtpTimer(remainingSeconds: event.remainingSeconds);

    if (state is OtpInitialState) {
      emit(OtpInitialState(
        phone: state.phone,
        code: state.code,
        resendTimer: timer,
        attemptsRemaining: state.attemptsRemaining,
        showSuccessToast: (state as OtpInitialState).showSuccessToast,
      ));
    } else if (state is OtpTypingState) {
      emit(OtpTypingState(
        phone: state.phone,
        code: state.code,
        resendTimer: timer,
        attemptsRemaining: state.attemptsRemaining,
      ));
    } else if (state is OtpAutofilledState) {
      emit(OtpAutofilledState(
        phone: state.phone,
        code: state.code,
        resendTimer: timer,
        attemptsRemaining: state.attemptsRemaining,
      ));
    } else if (state is OtpVerifyingState) {
      emit(OtpVerifyingState(
        phone: state.phone,
        code: state.code,
        resendTimer: timer,
        attemptsRemaining: state.attemptsRemaining,
      ));
    } else if (state is OtpErrorState) {
      emit(OtpErrorState(
        phone: state.phone,
        code: state.code,
        attemptsRemaining: state.attemptsRemaining,
        resendTimer: timer,
        errorMessage: state.errorMessage,
      ));
    }
  }

  void _onExpiredTriggered(
    OtpExpiredTriggered event,
    Emitter<OtpState> emit,
  ) {
    _countdownTimer?.cancel();
    emit(OtpExpiredState(
      phone: state.phone,
      code: state.code,
    ));
  }

  void _onEditPhoneTapped(
    OtpEditPhoneTapped event,
    Emitter<OtpState> emit,
  ) {
    _countdownTimer?.cancel();
    emit(OtpNavigateToPhoneState(phone: state.phone));
  }

  void _startResendTimer(int seconds) {
    _countdownTimer?.cancel();
    var remaining = seconds;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;
      if (remaining <= 0) {
        timer.cancel();
      }
      add(OtpResendTicked(remaining));
    });
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}
