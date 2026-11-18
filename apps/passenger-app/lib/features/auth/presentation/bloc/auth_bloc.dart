import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/cooldown_timer.dart';
import '../../data/models/phone_number_validation.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;
  Timer? _cooldownTimer;

  AuthBloc({required AuthRepository repository})
      : _repository = repository,
        super(const AuthPhoneEmpty()) {
    on<AuthPhoneChanged>(_onPhoneChanged);
    on<AuthSubmitRequested>(_onSubmitRequested);
    on<AuthCooldownTicked>(_onCooldownTicked);
    on<AuthCooldownExpired>(_onCooldownExpired);
    on<AuthEditPhoneTapped>(_onEditPhoneTapped);
    on<AuthHelpTapped>(_onHelpTapped);
    on<AuthTriggerCooldown>(_onTriggerCooldown);
  }

  void _onPhoneChanged(
    AuthPhoneChanged event,
    Emitter<AuthState> emit,
  ) {
    if (state is AuthRateLimited || state is AuthSubmitting) {
      return;
    }

    final digits = CanadianPhoneUtils.extractDigits(event.rawPhone);
    if (digits.isEmpty) {
      emit(const AuthPhoneEmpty());
      return;
    }

    final formatted = CanadianPhoneUtils.format(digits);
    if (CanadianPhoneUtils.isValid(digits)) {
      emit(AuthPhoneValid(
        rawPhone: digits,
        formattedPhone: formatted,
      ));
    } else {
      emit(AuthPhoneInvalid(
        rawPhone: digits,
        formattedPhone: formatted,
      ));
    }
  }

  Future<void> _onSubmitRequested(
    AuthSubmitRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (!state.canSubmit) return;

    emit(AuthSubmitting(
      rawPhone: state.rawPhone,
      formattedPhone: state.formattedPhone,
    ));

    try {
      final e164 = await _repository.requestOtp(state.rawPhone);
      emit(AuthCodeSentSuccess(
        rawPhone: state.rawPhone,
        formattedPhone: state.formattedPhone,
        targetRoute: '/code?phone=${Uri.encodeQueryComponent(e164)}',
      ));
    } on RateLimitException catch (e) {
      _startCooldown(emit, e.cooldownSeconds);
    } catch (e) {
      emit(AuthPhoneInvalid(
        rawPhone: state.rawPhone,
        formattedPhone: state.formattedPhone,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onCooldownTicked(
    AuthCooldownTicked event,
    Emitter<AuthState> emit,
  ) {
    if (event.remainingSeconds <= 0) {
      add(const AuthCooldownExpired());
      return;
    }

    final total = state.cooldown?.totalSeconds ?? 300;
    emit(AuthRateLimited(
      rawPhone: state.rawPhone,
      formattedPhone: state.formattedPhone,
      cooldown: CooldownTimer(
        totalSeconds: total,
        remainingSeconds: event.remainingSeconds,
      ),
    ));
  }

  void _onCooldownExpired(
    AuthCooldownExpired event,
    Emitter<AuthState> emit,
  ) {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;

    if (CanadianPhoneUtils.isValid(state.rawPhone)) {
      emit(AuthPhoneValid(
        rawPhone: state.rawPhone,
        formattedPhone: state.formattedPhone,
      ));
    } else if (state.rawPhone.isNotEmpty) {
      emit(AuthPhoneInvalid(
        rawPhone: state.rawPhone,
        formattedPhone: state.formattedPhone,
      ));
    } else {
      emit(const AuthPhoneEmpty());
    }
  }

  void _onEditPhoneTapped(
    AuthEditPhoneTapped event,
    Emitter<AuthState> emit,
  ) {
    if (state is AuthSubmitting) {
      emit(AuthPhoneValid(
        rawPhone: state.rawPhone,
        formattedPhone: state.formattedPhone,
      ));
    }
  }

  Future<void> _onHelpTapped(
    AuthHelpTapped event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.callDispatchSupport();
  }

  void _onTriggerCooldown(
    AuthTriggerCooldown event,
    Emitter<AuthState> emit,
  ) {
    _startCooldown(emit, event.totalSeconds);
  }

  void _startCooldown(Emitter<AuthState> emit, int seconds) {
    _cooldownTimer?.cancel();
    var remaining = seconds;

    emit(AuthRateLimited(
      rawPhone: state.rawPhone,
      formattedPhone: state.formattedPhone,
      cooldown: CooldownTimer(
        totalSeconds: seconds,
        remainingSeconds: remaining,
      ),
    ));

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;
      if (remaining <= 0) {
        timer.cancel();
        add(const AuthCooldownExpired());
      } else {
        add(AuthCooldownTicked(remaining));
      }
    });
  }

  @override
  Future<void> close() {
    _cooldownTimer?.cancel();
    return super.close();
  }
}
