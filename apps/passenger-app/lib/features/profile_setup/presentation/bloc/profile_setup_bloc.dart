import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/canadian_postal_code.dart';
import '../../data/models/passenger_profile.dart';
import '../../data/models/profile_setup_config.dart';
import '../../data/repositories/profile_setup_repository.dart';
import 'profile_setup_event.dart';
import 'profile_setup_state.dart';

class ProfileSetupBloc extends Bloc<ProfileSetupEvent, ProfileSetupState> {
  final ProfileSetupRepository _repository;
  static final RegExp _emailRegex =
      RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');

  ProfileSetupBloc({
    required ProfileSetupRepository repository,
    PassengerProfile? initialProfile,
  })  : _repository = repository,
        super(ProfileSetupState(
          status: ProfileSetupStatus.editing,
          profile: initialProfile ??
              const PassengerProfile(
                firstName: '',
                lastName: '',
                email: '',
                postalCode: '',
                gender: 'Female',
              ),
        )) {
    on<ProfileSetupStarted>(_onStarted);
    on<ProfileFirstNameChanged>(_onFirstNameChanged);
    on<ProfileLastNameChanged>(_onLastNameChanged);
    on<ProfileEmailChanged>(_onEmailChanged);
    on<ProfilePostalCodeChanged>(_onPostalCodeChanged);
    on<ProfileGenderChanged>(_onGenderChanged);
    on<ProfilePhotoChanged>(_onPhotoChanged);
    on<ProfileSubmitRequested>(_onSubmitRequested);
    on<ProfileSkipRequested>(_onSkipRequested);
  }

  void _onStarted(
    ProfileSetupStarted event,
    Emitter<ProfileSetupState> emit,
  ) {
    final profile = event.initialProfile ?? state.profile;
    final isValid = _isProfileFullyValid(profile);

    emit(ProfileSetupState(
      status: isValid ? ProfileSetupStatus.valid : ProfileSetupStatus.editing,
      profile: profile,
    ));
  }

  void _onFirstNameChanged(
    ProfileFirstNameChanged event,
    Emitter<ProfileSetupState> emit,
  ) {
    final updated = state.profile.copyWith(firstName: event.firstName);
    final error = state.hasAttemptedSubmit && event.firstName.trim().isEmpty
        ? ProfileSetupConfig.firstNameRequired
        : null;

    _emitUpdated(emit, updated, firstNameError: error, clearFirstNameError: error == null);
  }

  void _onLastNameChanged(
    ProfileLastNameChanged event,
    Emitter<ProfileSetupState> emit,
  ) {
    final updated = state.profile.copyWith(lastName: event.lastName);
    final error = state.hasAttemptedSubmit && event.lastName.trim().isEmpty
        ? ProfileSetupConfig.lastNameRequired
        : null;

    _emitUpdated(emit, updated, lastNameError: error, clearLastNameError: error == null);
  }

  void _onEmailChanged(
    ProfileEmailChanged event,
    Emitter<ProfileSetupState> emit,
  ) {
    final updated = state.profile.copyWith(email: event.email);
    final error = state.hasAttemptedSubmit && !_emailRegex.hasMatch(event.email.trim())
        ? ProfileSetupConfig.emailInvalid
        : null;

    _emitUpdated(emit, updated, emailError: error, clearEmailError: error == null);
  }

  void _onPostalCodeChanged(
    ProfilePostalCodeChanged event,
    Emitter<ProfileSetupState> emit,
  ) {
    final formatted = CanadianPostalCode.format(event.postalCode);
    final updated = state.profile.copyWith(postalCode: formatted);
    final error = state.hasAttemptedSubmit && !CanadianPostalCode.isValid(formatted)
        ? ProfileSetupConfig.postalCodeInvalid
        : null;

    _emitUpdated(emit, updated, postalCodeError: error, clearPostalCodeError: error == null);
  }

  void _onGenderChanged(
    ProfileGenderChanged event,
    Emitter<ProfileSetupState> emit,
  ) {
    final updated = state.profile.copyWith(gender: event.gender);
    _emitUpdated(emit, updated);
  }

  void _onPhotoChanged(
    ProfilePhotoChanged event,
    Emitter<ProfileSetupState> emit,
  ) {
    final updated = state.profile.copyWith(photoUrl: event.photoUrl);
    _emitUpdated(emit, updated);
  }

  Future<void> _onSubmitRequested(
    ProfileSubmitRequested event,
    Emitter<ProfileSetupState> emit,
  ) async {
    // Validate all fields
    String? fnError;
    if (state.profile.firstName.trim().isEmpty) {
      fnError = ProfileSetupConfig.firstNameRequired;
    }

    String? lnError;
    if (state.profile.lastName.trim().isEmpty) {
      lnError = ProfileSetupConfig.lastNameRequired;
    }

    String? emailError;
    if (!_emailRegex.hasMatch(state.profile.email.trim())) {
      emailError = ProfileSetupConfig.emailInvalid;
    }

    String? pcError;
    if (!CanadianPostalCode.isValid(state.profile.postalCode)) {
      pcError = ProfileSetupConfig.postalCodeInvalid;
    }

    final hasErrors = fnError != null || lnError != null || emailError != null || pcError != null;

    if (hasErrors) {
      emit(state.copyWith(
        status: ProfileSetupStatus.invalid,
        hasAttemptedSubmit: true,
        firstNameError: fnError,
        lastNameError: lnError,
        emailError: emailError,
        postalCodeError: pcError,
        clearFirstNameError: fnError == null,
        clearLastNameError: lnError == null,
        clearEmailError: emailError == null,
        clearPostalCodeError: pcError == null,
      ));
      return;
    }

    // Submit state
    emit(state.copyWith(
      status: ProfileSetupStatus.submitting,
      hasAttemptedSubmit: true,
      clearFirstNameError: true,
      clearLastNameError: true,
      clearEmailError: true,
      clearPostalCodeError: true,
    ));

    try {
      await _repository.saveProfile(state.profile);
      emit(state.copyWith(
        status: ProfileSetupStatus.success,
        targetRoute: '/home',
      ));
    } catch (_) {
      emit(state.copyWith(status: ProfileSetupStatus.valid));
    }
  }

  void _onSkipRequested(
    ProfileSkipRequested event,
    Emitter<ProfileSetupState> emit,
  ) {
    emit(state.copyWith(
      status: ProfileSetupStatus.skipped,
      targetRoute: '/home',
    ));
  }

  void _emitUpdated(
    Emitter<ProfileSetupState> emit,
    PassengerProfile updated, {
    String? firstNameError,
    String? lastNameError,
    String? emailError,
    String? postalCodeError,
    bool clearFirstNameError = false,
    bool clearLastNameError = false,
    bool clearEmailError = false,
    bool clearPostalCodeError = false,
  }) {
    final isValid = _isProfileFullyValid(updated);
    emit(state.copyWith(
      profile: updated,
      status: isValid ? ProfileSetupStatus.valid : (state.hasAttemptedSubmit ? ProfileSetupStatus.invalid : ProfileSetupStatus.editing),
      firstNameError: firstNameError,
      lastNameError: lastNameError,
      emailError: emailError,
      postalCodeError: postalCodeError,
      clearFirstNameError: clearFirstNameError,
      clearLastNameError: clearLastNameError,
      clearEmailError: clearEmailError,
      clearPostalCodeError: clearPostalCodeError,
    ));
  }

  bool _isProfileFullyValid(PassengerProfile profile) {
    return profile.firstName.trim().isNotEmpty &&
        profile.lastName.trim().isNotEmpty &&
        _emailRegex.hasMatch(profile.email.trim()) &&
        CanadianPostalCode.isValid(profile.postalCode);
  }
}
