import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/driver_otp_config.dart';
import '../data/models/driver_otp_status.dart';
import '../data/models/driver_routing_pathway.dart';
import '../data/repositories/driver_otp_repository.dart';
import 'driver_otp_event.dart';
import 'driver_otp_state.dart';

class DriverOtpBloc extends Bloc<DriverOtpEvent, DriverOtpState> {
  final DriverOtpRepository repository;
  Timer? _cooldownTimer;

  DriverOtpBloc({DriverOtpRepository? repository})
      : repository = repository ?? MockDriverOtpRepository(),
        super(const DriverOtpState()) {
    on<DriverOtpStarted>(_onStarted);
    on<DriverOtpDigitPressed>(_onDigitPressed);
    on<DriverOtpBackspacePressed>(_onBackspacePressed);
    on<DriverOtpClearPressed>(_onClearPressed);
    on<DriverOtpSubmitted>(_onSubmitted);
    on<DriverOtpResendTapped>(_onResendTapped);
    on<DriverOtpTimerTick>(_onTimerTick);
    on<DriverOtpPathwaySelected>(_onPathwaySelected);
    on<DriverOtpStateSwitched>(_onStateSwitched);
  }

  @override
  Future<void> close() {
    _cooldownTimer?.cancel();
    return super.close();
  }

  void _startTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(const DriverOtpTimerTick());
    });
  }

  static String _maskPhoneNumber(String? raw) {
    if (raw == null || raw.isEmpty) return DriverOtpConfig.defaultMaskedPhone;
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 2) {
      final last2 = digits.substring(digits.length - 2);
      return '+1 (403) ••• ••$last2';
    }
    return DriverOtpConfig.defaultMaskedPhone;
  }

  void _onStarted(
    DriverOtpStarted event,
    Emitter<DriverOtpState> emit,
  ) {
    final phone = event.phone ?? '+14035550117';
    final masked = _maskPhoneNumber(phone);

    emit(state.copyWith(
      phone: phone,
      maskedPhone: masked,
      status: event.initialStatus,
      code: '',
      resendCooldownSeconds: DriverOtpConfig.defaultResendCooldownSeconds,
      errorMessage: null,
      feedbackMessage: event.initialStatus == DriverOtpStatus.initial
          ? DriverOtpConfig.otpSentSuccess
          : null,
    ));

    if (state.resendCooldownSeconds > 0) {
      _startTimer();
    }
  }

  void _onDigitPressed(
    DriverOtpDigitPressed event,
    Emitter<DriverOtpState> emit,
  ) {
    if (state.isExpired || state.isSubmitting) return;

    if (state.code.length < DriverOtpConfig.otpLength) {
      final newCode = state.code + event.digit;
      final isComplete = newCode.length == DriverOtpConfig.otpLength;

      emit(state.copyWith(
        code: newCode,
        status: isComplete ? DriverOtpStatus.ready : DriverOtpStatus.initial,
        errorMessage: null,
      ));
    }
  }

  void _onBackspacePressed(
    DriverOtpBackspacePressed event,
    Emitter<DriverOtpState> emit,
  ) {
    if (state.isExpired || state.isSubmitting) return;

    if (state.code.isNotEmpty) {
      final newCode = state.code.substring(0, state.code.length - 1);
      emit(state.copyWith(
        code: newCode,
        status: DriverOtpStatus.initial,
        errorMessage: null,
      ));
    }
  }

  void _onClearPressed(
    DriverOtpClearPressed event,
    Emitter<DriverOtpState> emit,
  ) {
    if (state.isSubmitting) return;
    emit(state.copyWith(
      code: '',
      status: DriverOtpStatus.initial,
      errorMessage: null,
    ));
  }

  Future<void> _onSubmitted(
    DriverOtpSubmitted event,
    Emitter<DriverOtpState> emit,
  ) async {
    if (!state.canSubmit || state.isSubmitting) return;

    emit(state.copyWith(
      status: DriverOtpStatus.submitting,
      errorMessage: null,
    ));

    final isSuccess = await repository.verifyOtp(
      phone: state.phone,
      code: state.code,
    );

    if (isSuccess) {
      final pathwayType = await repository.resolveDriverPathway(
        phone: state.phone,
      );
      final pathway = DriverRoutingPathway.pathways.firstWhere(
        (p) => p.type == pathwayType,
        orElse: () => DriverRoutingPathway.pathways.first,
      );

      emit(state.copyWith(
        status: DriverOtpStatus.verified,
        selectedPathway: pathwayType,
        targetRoute: pathway.routePath,
        feedbackMessage: 'Code verified! Routing to ${pathway.destinationText}...',
      ));
    } else {
      if (state.code == '409153') {
        emit(state.copyWith(
          status: DriverOtpStatus.expired,
          errorMessage: DriverOtpConfig.codeExpiredMessage,
        ));
      } else {
        emit(state.copyWith(
          status: DriverOtpStatus.incorrect,
          errorMessage: DriverOtpConfig.incorrectCodeError,
        ));
      }
    }
  }

  Future<void> _onResendTapped(
    DriverOtpResendTapped event,
    Emitter<DriverOtpState> emit,
  ) async {
    emit(state.copyWith(
      status: DriverOtpStatus.initial,
      code: '',
      errorMessage: null,
      resendCooldownSeconds: DriverOtpConfig.defaultResendCooldownSeconds,
      feedbackMessage: DriverOtpConfig.otpSentSuccess,
    ));

    _startTimer();
    await repository.resendOtp(phone: state.phone);
  }

  void _onTimerTick(
    DriverOtpTimerTick event,
    Emitter<DriverOtpState> emit,
  ) {
    if (state.resendCooldownSeconds > 1) {
      emit(state.copyWith(
        resendCooldownSeconds: state.resendCooldownSeconds - 1,
      ));
    } else {
      _cooldownTimer?.cancel();
      emit(state.copyWith(resendCooldownSeconds: 0));
    }
  }

  void _onPathwaySelected(
    DriverOtpPathwaySelected event,
    Emitter<DriverOtpState> emit,
  ) {
    emit(state.copyWith(
      selectedPathway: event.pathway.type,
      targetRoute: event.pathway.routePath,
      feedbackMessage: 'Selected pathway: ${event.pathway.destinationText}',
    ));
  }

  void _onStateSwitched(
    DriverOtpStateSwitched event,
    Emitter<DriverOtpState> emit,
  ) {
    _cooldownTimer?.cancel();

    switch (event.status) {
      case DriverOtpStatus.initial:
        emit(state.copyWith(
          status: DriverOtpStatus.initial,
          code: '',
          resendCooldownSeconds: 28,
          errorMessage: null,
          feedbackMessage: DriverOtpConfig.otpSentSuccess,
        ));
        _startTimer();
        break;

      case DriverOtpStatus.ready:
        emit(state.copyWith(
          status: DriverOtpStatus.ready,
          code: '842917',
          resendCooldownSeconds: 0,
          errorMessage: null,
        ));
        break;

      case DriverOtpStatus.incorrect:
        emit(state.copyWith(
          status: DriverOtpStatus.incorrect,
          code: '519482',
          resendCooldownSeconds: 0,
          errorMessage: DriverOtpConfig.incorrectCodeError,
        ));
        break;

      case DriverOtpStatus.expired:
        emit(state.copyWith(
          status: DriverOtpStatus.expired,
          code: '409153',
          resendCooldownSeconds: 0,
          errorMessage: DriverOtpConfig.codeExpiredMessage,
        ));
        break;

      case DriverOtpStatus.submitting:
        emit(state.copyWith(
          status: DriverOtpStatus.submitting,
          code: '842917',
          resendCooldownSeconds: 34,
          errorMessage: null,
        ));
        break;

      case DriverOtpStatus.verified:
        emit(state.copyWith(
          status: DriverOtpStatus.verified,
          code: '842917',
          targetRoute: '/home',
        ));
        break;
    }
  }
}
