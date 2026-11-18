import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/driver_delete_status.dart';
import '../data/repositories/driver_delete_account_repository.dart';
import 'driver_delete_account_event.dart';
import 'driver_delete_account_state.dart';

class DriverDeleteAccountBloc
    extends Bloc<DriverDeleteAccountEvent, DriverDeleteAccountState> {
  final DriverDeleteAccountRepository repository;

  DriverDeleteAccountBloc({
    required this.repository,
    DriverDeleteStatus initialStatus = DriverDeleteStatus.checklistReady,
  }) : super(DriverDeleteAccountState(status: initialStatus)) {
    on<DriverDeleteStarted>(_onStarted);
    on<DriverDeleteSwitchView>(_onSwitchView);
    on<DriverDeleteSelectSafeguardBlock>(_onSelectSafeguardBlock);
    on<DriverDeleteToggleTestHold>(_onToggleTestHold);
    on<DriverDeleteProceedToConfirmation>(_onProceedToConfirmation);
    on<DriverDeleteCancelRequested>(_onCancelRequested);
    on<DriverDeleteRestoreAccount>(_onRestoreAccount);
    on<DriverDeleteGoToActiveTrip>(_onGoToActiveTrip);
    on<DriverDeleteTriggerSos>(_onTriggerSos);
    on<DriverDeleteCompleteSignout>(_onCompleteSignout);
    on<DriverDeleteClearToast>(_onClearToast);
  }

  Future<void> _onStarted(
    DriverDeleteStarted event,
    Emitter<DriverDeleteAccountState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final checklist = await repository.getChecklist();
      final blocks = await repository.getSafeguardBlocks();
      final confirmation = await repository.getConfirmationData();
      emit(state.copyWith(
        isLoading: false,
        checklist: checklist,
        safeguardBlocks: blocks,
        confirmationData: confirmation,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        toastMessage: 'Failed to load account deletion safeguards: $e',
      ));
    }
  }

  void _onSwitchView(
    DriverDeleteSwitchView event,
    Emitter<DriverDeleteAccountState> emit,
  ) {
    emit(state.copyWith(status: event.status));
  }

  void _onSelectSafeguardBlock(
    DriverDeleteSelectSafeguardBlock event,
    Emitter<DriverDeleteAccountState> emit,
  ) {
    emit(state.copyWith(selectedBlockType: event.blockType));
  }

  void _onToggleTestHold(
    DriverDeleteToggleTestHold event,
    Emitter<DriverDeleteAccountState> emit,
  ) {
    final newHold = !state.isTestHoldActive;
    if (newHold) {
      emit(state.copyWith(
        isTestHoldActive: true,
        status: DriverDeleteStatus.safeguardsBlocked,
        toastMessage:
            'Test Hold activated: Protocol validation block triggered.',
      ));
    } else {
      emit(state.copyWith(
        isTestHoldActive: false,
        status: DriverDeleteStatus.checklistReady,
        toastMessage: 'Test Hold released: Checklist is ready to proceed.',
      ));
    }
  }

  Future<void> _onProceedToConfirmation(
    DriverDeleteProceedToConfirmation event,
    Emitter<DriverDeleteAccountState> emit,
  ) async {
    if (!state.canProceedWithDeletion) {
      emit(state.copyWith(
        status: DriverDeleteStatus.safeguardsBlocked,
        toastMessage:
            'Protocol Safeguards Active: Resolve active blocks before termination.',
      ));
      return;
    }

    emit(state.copyWith(isLoading: true));
    try {
      await repository.requestAccountDeletion();
      emit(state.copyWith(
        isLoading: false,
        status: DriverDeleteStatus.deletionRequested,
        toastMessage:
            'Account deletion requested. 30-day grace period initiated.',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        toastMessage: 'Failed to submit deletion request: $e',
      ));
    }
  }

  void _onCancelRequested(
    DriverDeleteCancelRequested event,
    Emitter<DriverDeleteAccountState> emit,
  ) {
    emit(state.copyWith(
      toastMessage: 'Account deletion cancelled. Your driver profile is safe.',
    ));
  }

  Future<void> _onRestoreAccount(
    DriverDeleteRestoreAccount event,
    Emitter<DriverDeleteAccountState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      await repository.cancelDeletionAndRestore();
      emit(state.copyWith(
        isLoading: false,
        status: DriverDeleteStatus.checklistReady,
        toastMessage:
            'Account fully restored! Dispatches and medallion profile reactivated.',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        toastMessage: 'Failed to restore driver account: $e',
      ));
    }
  }

  void _onGoToActiveTrip(
    DriverDeleteGoToActiveTrip event,
    Emitter<DriverDeleteAccountState> emit,
  ) {
    emit(state.copyWith(navigateToTrip: true));
  }

  void _onTriggerSos(
    DriverDeleteTriggerSos event,
    Emitter<DriverDeleteAccountState> emit,
  ) {
    emit(state.copyWith(
      toastMessage:
          '🚨 Distress signals instantly alert Lethbridge Police Services (LPS).',
    ));
  }

  void _onCompleteSignout(
    DriverDeleteCompleteSignout event,
    Emitter<DriverDeleteAccountState> emit,
  ) {
    emit(state.copyWith(
      isSignedOut: true,
      toastMessage: 'Signed out of Bridge City Cabs Fleet Network.',
    ));
  }

  void _onClearToast(
    DriverDeleteClearToast event,
    Emitter<DriverDeleteAccountState> emit,
  ) {
    emit(state.copyWith(clearToast: true));
  }
}
