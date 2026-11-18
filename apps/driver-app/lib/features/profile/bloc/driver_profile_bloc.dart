import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/driver_profile_config.dart';
import '../data/models/driver_profile_status.dart';
import '../data/models/driver_profile_tab.dart';
import '../data/repositories/driver_profile_repository.dart';
import 'driver_profile_event.dart';
import 'driver_profile_state.dart';

class DriverProfileBloc extends Bloc<DriverProfileEvent, DriverProfileState> {
  final DriverProfileRepository repository;

  DriverProfileBloc({required this.repository})
      : super(DriverProfileState.initial()) {
    on<DriverProfileStarted>(_onStarted);
    on<DriverProfileTabChanged>(_onTabChanged);
    on<DriverProfileCredentialTapped>(_onCredentialTapped);
    on<DriverProfileInspectionDismissed>(_onInspectionDismissed);
    on<DriverProfileUploadRequested>(_onUploadRequested);
    on<DriverProfileSyncRetryPressed>(_onSyncRetryPressed);
    on<DriverProfileContactSupportPressed>(_onContactSupportPressed);
    on<DriverProfileStateForced>(_onStateForced);
  }

  void _onStarted(
    DriverProfileStarted event,
    Emitter<DriverProfileState> emit,
  ) {
    add(DriverProfileStateForced(event.initialStatus));
  }

  void _onTabChanged(
    DriverProfileTabChanged event,
    Emitter<DriverProfileState> emit,
  ) {
    emit(state.copyWith(activeTab: event.tab));
  }

  void _onCredentialTapped(
    DriverProfileCredentialTapped event,
    Emitter<DriverProfileState> emit,
  ) {
    if (event.credential.isInspectionShielded ||
        event.credential.policyNumber != null) {
      emit(state.copyWith(inspectedCredential: event.credential));
    } else {
      emit(
        state.copyWith(
          feedbackMessage: 'Opening ${event.credential.title}...',
        ),
      );
    }
  }

  void _onInspectionDismissed(
    DriverProfileInspectionDismissed event,
    Emitter<DriverProfileState> emit,
  ) {
    emit(state.copyWith(clearInspection: true));
  }

  Future<void> _onUploadRequested(
    DriverProfileUploadRequested event,
    Emitter<DriverProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        feedbackMessage:
            'Opening document uploader for credential ${event.credentialId}...',
      ),
    );
  }

  Future<void> _onSyncRetryPressed(
    DriverProfileSyncRetryPressed event,
    Emitter<DriverProfileState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true));
    try {
      await repository.retryOfflineSync();
      emit(
        state.copyWith(
          isActionLoading: false,
          feedbackMessage: 'Profile telemetry synced with Lethbridge Dispatch.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isActionLoading: false,
          feedbackMessage: 'Sync error: $e',
        ),
      );
    }
  }

  void _onContactSupportPressed(
    DriverProfileContactSupportPressed event,
    Emitter<DriverProfileState> emit,
  ) {
    emit(
      state.copyWith(
        feedbackMessage:
            'Connecting to ${DriverProfileConfig.operationsDesk} (${DriverProfileConfig.dispatchHotline})...',
      ),
    );
  }

  void _onStateForced(
    DriverProfileStateForced event,
    Emitter<DriverProfileState> emit,
  ) {
    switch (event.status) {
      case DriverProfileStatus.activeOnline:
        emit(
          state.copyWith(
            status: DriverProfileStatus.activeOnline,
            activeTab: DriverProfileTab.info,
            profileData: DriverProfileConfig.activeOnlinePreset(),
            clearInspection: true,
            availableTabs: const [
              DriverProfileTab.info,
              DriverProfileTab.documents,
            ],
            isActionLoading: false,
          ),
        );
        break;
      case DriverProfileStatus.credentialExpiredLocked:
        emit(
          state.copyWith(
            status: DriverProfileStatus.credentialExpiredLocked,
            activeTab: DriverProfileTab.documents,
            profileData: DriverProfileConfig.expiredLockedPreset(),
            clearInspection: true,
            availableTabs: const [
              DriverProfileTab.info,
              DriverProfileTab.documents,
            ],
            isActionLoading: false,
          ),
        );
        break;
      case DriverProfileStatus.expiringSoonInspection:
        final expiringPreset = DriverProfileConfig.expiringSoonPreset();
        final insuranceCard = expiringPreset.credentials.firstWhere(
          (c) => c.isInspectionShielded,
          orElse: () => expiringPreset.credentials.first,
        );
        emit(
          state.copyWith(
            status: DriverProfileStatus.expiringSoonInspection,
            activeTab: DriverProfileTab.documents,
            profileData: expiringPreset,
            inspectedCredential: insuranceCard,
            availableTabs: const [
              DriverProfileTab.info,
              DriverProfileTab.documents,
            ],
            isActionLoading: false,
          ),
        );
        break;
      case DriverProfileStatus.offlineSyncAlert:
        emit(
          state.copyWith(
            status: DriverProfileStatus.offlineSyncAlert,
            activeTab: DriverProfileTab.info,
            profileData: DriverProfileConfig.offlinePartnerPreset(),
            clearInspection: true,
            availableTabs: const [
              DriverProfileTab.info,
              DriverProfileTab.documents,
              DriverProfileTab.activity,
            ],
            isActionLoading: false,
          ),
        );
        break;
    }
  }
}
