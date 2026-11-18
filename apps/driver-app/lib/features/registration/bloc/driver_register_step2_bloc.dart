import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/driver_register_config.dart';
import '../data/models/driver_register_step2_data.dart';
import '../data/models/driver_register_step2_status.dart';
import '../data/models/driver_vehicle_class.dart';
import '../data/repositories/driver_register_repository.dart';
import 'driver_register_step2_event.dart';
import 'driver_register_step2_state.dart';

class DriverRegisterStep2Bloc
    extends Bloc<DriverRegisterStep2Event, DriverRegisterStep2State> {
  final DriverRegisterRepository repository;

  DriverRegisterStep2Bloc({DriverRegisterRepository? repository})
      : repository = repository ?? MockDriverRegisterRepository(),
        super(const DriverRegisterStep2State()) {
    on<DriverRegisterStep2Started>(_onStarted);
    on<DriverRegisterVehicleClassSelected>(_onVehicleClassSelected);
    on<DriverRegisterMakeChanged>(_onMakeChanged);
    on<DriverRegisterModelChanged>(_onModelChanged);
    on<DriverRegisterYearPickerOpened>(_onYearPickerOpened);
    on<DriverRegisterYearPickerDismissed>(_onYearPickerDismissed);
    on<DriverRegisterYearSelected>(_onYearSelected);
    on<DriverRegisterColourChanged>(_onColourChanged);
    on<DriverRegisterPlateChanged>(_onPlateChanged);
    on<DriverRegisterVanOnlyToggled>(_onVanOnlyToggled);
    on<DriverRegisterFemaleDriverToggled>(_onFemaleDriverToggled);
    on<DriverRegisterStep2Submitted>(_onSubmitted);
    on<DriverRegisterStep2StateSwitched>(_onStateSwitched);
  }

  void _onStarted(
    DriverRegisterStep2Started event,
    Emitter<DriverRegisterStep2State> emit,
  ) {
    final initialData = event.initialData ?? const DriverRegisterStep2Data();
    emit(state.copyWith(
      status: event.initialStatus,
      data: initialData,
      yearError: null,
      plateError: null,
      generalAlertMessage: null,
      isYearPickerOpen:
          event.initialStatus == DriverRegisterStep2Status.yearPickerModal,
    ));
  }

  void _onVehicleClassSelected(
    DriverRegisterVehicleClassSelected event,
    Emitter<DriverRegisterStep2State> emit,
  ) {
    final updated = state.data.copyWith(vehicleClass: event.vehicleClass);
    emit(state.copyWith(
      data: updated,
      status: updated.isFormValid
          ? DriverRegisterStep2Status.valid
          : DriverRegisterStep2Status.initial,
    ));
  }

  void _onMakeChanged(
    DriverRegisterMakeChanged event,
    Emitter<DriverRegisterStep2State> emit,
  ) {
    final updated = state.data.copyWith(make: event.make);
    emit(state.copyWith(
      data: updated,
      status: updated.isFormValid
          ? DriverRegisterStep2Status.valid
          : DriverRegisterStep2Status.initial,
    ));
  }

  void _onModelChanged(
    DriverRegisterModelChanged event,
    Emitter<DriverRegisterStep2State> emit,
  ) {
    final updated = state.data.copyWith(model: event.model);
    emit(state.copyWith(
      data: updated,
      status: updated.isFormValid
          ? DriverRegisterStep2Status.valid
          : DriverRegisterStep2Status.initial,
    ));
  }

  void _onYearPickerOpened(
    DriverRegisterYearPickerOpened event,
    Emitter<DriverRegisterStep2State> emit,
  ) {
    emit(state.copyWith(
      isYearPickerOpen: true,
      selectedYearInPicker: state.data.year ?? 2021,
      status: DriverRegisterStep2Status.yearPickerModal,
    ));
  }

  void _onYearPickerDismissed(
    DriverRegisterYearPickerDismissed event,
    Emitter<DriverRegisterStep2State> emit,
  ) {
    final newStatus = state.data.isFormValid
        ? DriverRegisterStep2Status.valid
        : (state.hasAnyError
            ? DriverRegisterStep2Status.invalid
            : DriverRegisterStep2Status.initial);

    emit(state.copyWith(
      isYearPickerOpen: false,
      status: newStatus,
    ));
  }

  void _onYearSelected(
    DriverRegisterYearSelected event,
    Emitter<DriverRegisterStep2State> emit,
  ) {
    final isTooOld = event.year < DriverRegisterStep2Data.minimumVehicleYear;
    final updated = state.data.copyWith(year: event.year);

    emit(state.copyWith(
      data: updated,
      isYearPickerOpen: false,
      selectedYearInPicker: event.year,
      yearError: isTooOld ? DriverRegisterConfig.yearTooOldError : null,
      status: updated.isFormValid && !isTooOld
          ? DriverRegisterStep2Status.valid
          : (isTooOld
              ? DriverRegisterStep2Status.invalid
              : DriverRegisterStep2Status.initial),
    ));
  }

  void _onColourChanged(
    DriverRegisterColourChanged event,
    Emitter<DriverRegisterStep2State> emit,
  ) {
    final updated = state.data.copyWith(colour: event.colour);
    emit(state.copyWith(
      data: updated,
      status: updated.isFormValid
          ? DriverRegisterStep2Status.valid
          : DriverRegisterStep2Status.initial,
    ));
  }

  void _onPlateChanged(
    DriverRegisterPlateChanged event,
    Emitter<DriverRegisterStep2State> emit,
  ) {
    final updated = state.data.copyWith(plateNumber: event.plateNumber);
    final isPlateValid = updated.isPlateValid;

    emit(state.copyWith(
      data: updated,
      plateError: isPlateValid ? null : state.plateError,
      status: updated.isFormValid
          ? DriverRegisterStep2Status.valid
          : (state.hasAnyError
              ? DriverRegisterStep2Status.invalid
              : DriverRegisterStep2Status.initial),
    ));
  }

  void _onVanOnlyToggled(
    DriverRegisterVanOnlyToggled event,
    Emitter<DriverRegisterStep2State> emit,
  ) {
    final updated = state.data.copyWith(suitableForVanOnly: event.enabled);
    emit(state.copyWith(data: updated));
  }

  void _onFemaleDriverToggled(
    DriverRegisterFemaleDriverToggled event,
    Emitter<DriverRegisterStep2State> emit,
  ) {
    final updated = state.data.copyWith(femaleDriverOnly: event.enabled);
    emit(state.copyWith(data: updated));
  }

  Future<void> _onSubmitted(
    DriverRegisterStep2Submitted event,
    Emitter<DriverRegisterStep2State> emit,
  ) async {
    String? yearErr;
    String? plateErr;

    if (state.data.year == null ||
        state.data.year! < DriverRegisterStep2Data.minimumVehicleYear) {
      yearErr = DriverRegisterConfig.yearTooOldError;
    }
    if (!state.data.isPlateValid) {
      plateErr = DriverRegisterConfig.plateInvalidError;
    }

    final hasErrors = yearErr != null ||
        plateErr != null ||
        !state.data.isVehicleClassSelected ||
        !state.data.isMakeValid ||
        !state.data.isModelValid;

    if (hasErrors) {
      emit(state.copyWith(
        status: DriverRegisterStep2Status.invalid,
        yearError: yearErr,
        plateError: plateErr,
        generalAlertMessage: DriverRegisterConfig.generalValidationAlert,
      ));
      return;
    }

    emit(state.copyWith(
      status: DriverRegisterStep2Status.submitting,
      yearError: null,
      plateError: null,
      generalAlertMessage: null,
    ));

    final success = await repository.saveStep2VehicleDetails(state.data);
    if (success) {
      emit(state.copyWith(
        status: DriverRegisterStep2Status.success,
        feedbackMessage:
            'Vehicle details saved! Proceeding to Driver documents...',
      ));
    } else {
      emit(state.copyWith(
        status: DriverRegisterStep2Status.valid,
        feedbackMessage: 'Failed to save vehicle details. Please try again.',
      ));
    }
  }

  void _onStateSwitched(
    DriverRegisterStep2StateSwitched event,
    Emitter<DriverRegisterStep2State> emit,
  ) {
    switch (event.status) {
      case DriverRegisterStep2Status.initial:
        emit(state.copyWith(
          status: DriverRegisterStep2Status.initial,
          data: const DriverRegisterStep2Data(
            vehicleClass: null,
            make: '',
            model: '',
            year: null,
            colour: '',
            plateNumber: '',
            suitableForVanOnly: false,
            femaleDriverOnly: false,
          ),
          yearError: null,
          plateError: null,
          generalAlertMessage: null,
          isYearPickerOpen: false,
        ));
        break;

      case DriverRegisterStep2Status.valid:
        emit(state.copyWith(
          status: DriverRegisterStep2Status.valid,
          data: const DriverRegisterStep2Data(
            vehicleClass: DriverVehicleClass.medium,
            make: 'Toyota',
            model: 'Camry Hybrid',
            year: 2021,
            colour: 'Midnight Black',
            plateNumber: 'BCC-9482',
            suitableForVanOnly: false,
            femaleDriverOnly: true,
          ),
          yearError: null,
          plateError: null,
          generalAlertMessage: null,
          isYearPickerOpen: false,
        ));
        break;

      case DriverRegisterStep2Status.invalid:
        emit(state.copyWith(
          status: DriverRegisterStep2Status.invalid,
          data: const DriverRegisterStep2Data(
            vehicleClass: DriverVehicleClass.medium,
            make: 'Toyota',
            model: 'Echo',
            year: 2008,
            colour: 'Silver',
            plateNumber: 'ABC',
            suitableForVanOnly: false,
            femaleDriverOnly: false,
          ),
          yearError: DriverRegisterConfig.yearTooOldError,
          plateError: DriverRegisterConfig.plateInvalidError,
          generalAlertMessage: DriverRegisterConfig.generalValidationAlert,
          isYearPickerOpen: false,
        ));
        break;

      case DriverRegisterStep2Status.yearPickerModal:
        emit(state.copyWith(
          status: DriverRegisterStep2Status.yearPickerModal,
          isYearPickerOpen: true,
          selectedYearInPicker: 2021,
        ));
        break;

      case DriverRegisterStep2Status.submitting:
        emit(state.copyWith(
          status: DriverRegisterStep2Status.submitting,
          isYearPickerOpen: false,
        ));
        break;

      case DriverRegisterStep2Status.success:
        emit(state.copyWith(
          status: DriverRegisterStep2Status.success,
          isYearPickerOpen: false,
          feedbackMessage: 'Step 2 complete!',
        ));
        break;
    }
  }
}
