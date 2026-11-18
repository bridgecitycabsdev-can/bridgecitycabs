import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/driver_register_config.dart';
import '../data/models/driver_register_step1_data.dart';
import '../data/models/driver_register_step1_status.dart';
import '../data/repositories/driver_register_repository.dart';
import 'driver_register_step1_event.dart';
import 'driver_register_step1_state.dart';

class DriverRegisterStep1Bloc
    extends Bloc<DriverRegisterStep1Event, DriverRegisterStep1State> {
  final DriverRegisterRepository repository;

  DriverRegisterStep1Bloc({DriverRegisterRepository? repository})
      : repository = repository ?? MockDriverRegisterRepository(),
        super(const DriverRegisterStep1State()) {
    on<DriverRegisterStep1Started>(_onStarted);
    on<DriverRegisterPhotoModalOpened>(_onPhotoModalOpened);
    on<DriverRegisterPhotoModalDismissed>(_onPhotoModalDismissed);
    on<DriverRegisterPhotoPicked>(_onPhotoPicked);
    on<DriverRegisterFirstNameChanged>(_onFirstNameChanged);
    on<DriverRegisterLastNameChanged>(_onLastNameChanged);
    on<DriverRegisterEmailChanged>(_onEmailChanged);
    on<DriverRegisterLicenceChanged>(_onLicenceChanged);
    on<DriverRegisterPostalCodeChanged>(_onPostalCodeChanged);
    on<DriverRegisterGenderSelected>(_onGenderSelected);
    on<DriverRegisterSubmitted>(_onSubmitted);
    on<DriverRegisterStateSwitched>(_onStateSwitched);
  }

  void _onStarted(
    DriverRegisterStep1Started event,
    Emitter<DriverRegisterStep1State> emit,
  ) {
    final initialData = event.initialData ?? const DriverRegisterStep1Data();
    emit(state.copyWith(
      status: event.initialStatus,
      data: initialData,
      photoError: null,
      emailError: null,
      licenceError: null,
      postalCodeError: null,
      generalAlertMessage: null,
      isPhotoModalOpen:
          event.initialStatus == DriverRegisterStep1Status.photoModal,
    ));
  }

  void _onPhotoModalOpened(
    DriverRegisterPhotoModalOpened event,
    Emitter<DriverRegisterStep1State> emit,
  ) {
    emit(state.copyWith(
      isPhotoModalOpen: true,
      status: DriverRegisterStep1Status.photoModal,
    ));
  }

  void _onPhotoModalDismissed(
    DriverRegisterPhotoModalDismissed event,
    Emitter<DriverRegisterStep1State> emit,
  ) {
    final newStatus = state.data.isFormValid
        ? DriverRegisterStep1Status.valid
        : (state.hasAnyError
            ? DriverRegisterStep1Status.invalid
            : DriverRegisterStep1Status.initial);

    emit(state.copyWith(
      isPhotoModalOpen: false,
      status: newStatus,
    ));
  }

  Future<void> _onPhotoPicked(
    DriverRegisterPhotoPicked event,
    Emitter<DriverRegisterStep1State> emit,
  ) async {
    final url = await repository.pickProfilePhoto(source: event.source);
    final updatedData = state.data.copyWith(
      hasPhoto: true,
      photoUrl: url ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
    );

    final isNowValid = updatedData.isFormValid;

    emit(state.copyWith(
      data: updatedData,
      photoError: null,
      isPhotoModalOpen: false,
      status: isNowValid
          ? DriverRegisterStep1Status.valid
          : DriverRegisterStep1Status.initial,
      feedbackMessage: 'Profile photo selected successfully.',
    ));
  }

  void _onFirstNameChanged(
    DriverRegisterFirstNameChanged event,
    Emitter<DriverRegisterStep1State> emit,
  ) {
    final updatedData = state.data.copyWith(firstName: event.firstName);
    emit(state.copyWith(
      data: updatedData,
      status: updatedData.isFormValid
          ? DriverRegisterStep1Status.valid
          : DriverRegisterStep1Status.initial,
    ));
  }

  void _onLastNameChanged(
    DriverRegisterLastNameChanged event,
    Emitter<DriverRegisterStep1State> emit,
  ) {
    final updatedData = state.data.copyWith(lastName: event.lastName);
    emit(state.copyWith(
      data: updatedData,
      status: updatedData.isFormValid
          ? DriverRegisterStep1Status.valid
          : DriverRegisterStep1Status.initial,
    ));
  }

  void _onEmailChanged(
    DriverRegisterEmailChanged event,
    Emitter<DriverRegisterStep1State> emit,
  ) {
    final updatedData = state.data.copyWith(email: event.email);
    final clearError = updatedData.isEmailValid;

    emit(state.copyWith(
      data: updatedData,
      emailError: clearError ? null : state.emailError,
      status: updatedData.isFormValid
          ? DriverRegisterStep1Status.valid
          : (state.hasAnyError
              ? DriverRegisterStep1Status.invalid
              : DriverRegisterStep1Status.initial),
    ));
  }

  void _onLicenceChanged(
    DriverRegisterLicenceChanged event,
    Emitter<DriverRegisterStep1State> emit,
  ) {
    final updatedData =
        state.data.copyWith(driverLicenceNumber: event.licenceNumber);
    final clearError = updatedData.isLicenceValid;

    emit(state.copyWith(
      data: updatedData,
      licenceError: clearError ? null : state.licenceError,
      status: updatedData.isFormValid
          ? DriverRegisterStep1Status.valid
          : (state.hasAnyError
              ? DriverRegisterStep1Status.invalid
              : DriverRegisterStep1Status.initial),
    ));
  }

  void _onPostalCodeChanged(
    DriverRegisterPostalCodeChanged event,
    Emitter<DriverRegisterStep1State> emit,
  ) {
    final updatedData = state.data.copyWith(postalCode: event.postalCode);
    final clearError = updatedData.isPostalCodeValid;

    emit(state.copyWith(
      data: updatedData,
      postalCodeError: clearError ? null : state.postalCodeError,
      status: updatedData.isFormValid
          ? DriverRegisterStep1Status.valid
          : (state.hasAnyError
              ? DriverRegisterStep1Status.invalid
              : DriverRegisterStep1Status.initial),
    ));
  }

  void _onGenderSelected(
    DriverRegisterGenderSelected event,
    Emitter<DriverRegisterStep1State> emit,
  ) {
    final updatedData = state.data.copyWith(gender: event.gender);
    emit(state.copyWith(data: updatedData));
  }

  Future<void> _onSubmitted(
    DriverRegisterSubmitted event,
    Emitter<DriverRegisterStep1State> emit,
  ) async {
    String? photoErr;
    String? emailErr;
    String? licenceErr;
    String? postalErr;
    String? generalAlert;

    if (!state.data.hasPhoto) {
      photoErr = DriverRegisterConfig.photoRequiredError;
    }
    if (!state.data.isEmailValid) {
      emailErr = DriverRegisterConfig.invalidEmailError;
    }
    if (!state.data.isLicenceValid) {
      licenceErr = DriverRegisterConfig.licenceRequiredError;
    }
    if (!state.data.isPostalCodeValid) {
      postalErr = DriverRegisterConfig.postalCodeInvalidError;
    }

    final hasErrors = photoErr != null ||
        emailErr != null ||
        licenceErr != null ||
        postalErr != null ||
        !state.data.isFirstNameValid ||
        !state.data.isLastNameValid;

    if (hasErrors) {
      generalAlert = DriverRegisterConfig.generalValidationAlert;
      emit(state.copyWith(
        status: DriverRegisterStep1Status.invalid,
        photoError: photoErr,
        emailError: emailErr,
        licenceError: licenceErr,
        postalCodeError: postalErr,
        generalAlertMessage: generalAlert,
      ));
      return;
    }

    emit(state.copyWith(
      status: DriverRegisterStep1Status.submitting,
      photoError: null,
      emailError: null,
      licenceError: null,
      postalCodeError: null,
      generalAlertMessage: null,
    ));

    final success = await repository.saveStep1Details(state.data);
    if (success) {
      emit(state.copyWith(
        status: DriverRegisterStep1Status.success,
        feedbackMessage:
            'Personal details saved. Proceeding to Vehicle details...',
      ));
    } else {
      emit(state.copyWith(
        status: DriverRegisterStep1Status.valid,
        feedbackMessage: 'Failed to save details. Please try again.',
      ));
    }
  }

  void _onStateSwitched(
    DriverRegisterStateSwitched event,
    Emitter<DriverRegisterStep1State> emit,
  ) {
    switch (event.status) {
      case DriverRegisterStep1Status.initial:
        emit(state.copyWith(
          status: DriverRegisterStep1Status.initial,
          data: const DriverRegisterStep1Data(
            hasPhoto: false,
            firstName: '',
            lastName: '',
            email: '',
            phone: '+1 (403) 555-0192',
            driverLicenceNumber: '',
            postalCode: '',
            gender: DriverGender.unspecified,
          ),
          photoError: null,
          emailError: null,
          licenceError: null,
          postalCodeError: null,
          generalAlertMessage: null,
          isPhotoModalOpen: false,
        ));
        break;

      case DriverRegisterStep1Status.valid:
        emit(state.copyWith(
          status: DriverRegisterStep1Status.valid,
          data: const DriverRegisterStep1Data(
            hasPhoto: true,
            photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
            firstName: 'Marcus',
            lastName: 'Vance',
            email: 'marcus.vance@gmail.com',
            phone: '+1 (403) 555-0192',
            driverLicenceNumber: '948201-442',
            postalCode: 'T1K 4V7',
            gender: DriverGender.male,
          ),
          photoError: null,
          emailError: null,
          licenceError: null,
          postalCodeError: null,
          generalAlertMessage: null,
          isPhotoModalOpen: false,
        ));
        break;

      case DriverRegisterStep1Status.invalid:
        emit(state.copyWith(
          status: DriverRegisterStep1Status.invalid,
          data: const DriverRegisterStep1Data(
            hasPhoto: false,
            firstName: 'Marcus',
            lastName: 'Vance',
            email: 'marcus.vance@',
            phone: '+1 (403) 555-0192',
            driverLicenceNumber: '',
            postalCode: '12345',
            gender: DriverGender.male,
          ),
          photoError: DriverRegisterConfig.photoRequiredError,
          emailError: DriverRegisterConfig.invalidEmailError,
          licenceError: DriverRegisterConfig.licenceRequiredError,
          postalCodeError: DriverRegisterConfig.postalCodeInvalidError,
          generalAlertMessage: DriverRegisterConfig.generalValidationAlert,
          isPhotoModalOpen: false,
        ));
        break;

      case DriverRegisterStep1Status.photoModal:
        emit(state.copyWith(
          status: DriverRegisterStep1Status.photoModal,
          isPhotoModalOpen: true,
        ));
        break;

      case DriverRegisterStep1Status.submitting:
        emit(state.copyWith(
          status: DriverRegisterStep1Status.submitting,
          isPhotoModalOpen: false,
        ));
        break;

      case DriverRegisterStep1Status.success:
        emit(state.copyWith(
          status: DriverRegisterStep1Status.success,
          isPhotoModalOpen: false,
          feedbackMessage: 'Step 1 complete!',
        ));
        break;
    }
  }
}
