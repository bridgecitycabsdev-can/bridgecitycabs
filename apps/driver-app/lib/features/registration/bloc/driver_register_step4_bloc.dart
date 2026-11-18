import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/driver_application_milestone.dart';
import '../data/models/driver_register_config.dart';
import '../data/models/driver_register_step4_data.dart';
import '../data/models/driver_register_step4_status.dart';
import '../data/repositories/driver_register_repository.dart';
import 'driver_register_step4_event.dart';
import 'driver_register_step4_state.dart';

class DriverRegisterStep4Bloc
    extends Bloc<DriverRegisterStep4Event, DriverRegisterStep4State> {
  final DriverRegisterRepository repository;

  DriverRegisterStep4Bloc({DriverRegisterRepository? repository})
      : repository = repository ?? MockDriverRegisterRepository(),
        super(const DriverRegisterStep4State()) {
    on<DriverRegisterStep4Started>(_onStarted);
    on<DriverRegisterStep4RefreshRequested>(_onRefreshRequested);
    on<DriverRegisterStep4ReconnectRequested>(_onReconnectRequested);
    on<DriverRegisterStep4GoHomeRequested>(_onGoHomeRequested);
    on<DriverRegisterStep4FixDocumentsRequested>(_onFixDocumentsRequested);
    on<DriverRegisterStep4UpdateVehicleRequested>(_onUpdateVehicleRequested);
    on<DriverRegisterStep4ContactSupportRequested>(_onContactSupportRequested);
    on<DriverRegisterStep4StateSwitched>(_onStateSwitched);
  }

  void _onStarted(
    DriverRegisterStep4Started event,
    Emitter<DriverRegisterStep4State> emit,
  ) {
    if (event.initialStatus != DriverRegisterStep4Status.reviewing) {
      add(DriverRegisterStep4StateSwitched(event.initialStatus));
      return;
    }

    add(const DriverRegisterStep4StateSwitched(
        DriverRegisterStep4Status.reviewing));
  }

  Future<void> _onRefreshRequested(
    DriverRegisterStep4RefreshRequested event,
    Emitter<DriverRegisterStep4State> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true));
    final data = await repository.checkApplicationStatus();
    emit(state.copyWith(
      isRefreshing: false,
      data: data,
      feedbackMessage: 'Status updated from Lethbridge dispatch',
    ));
  }

  Future<void> _onReconnectRequested(
    DriverRegisterStep4ReconnectRequested event,
    Emitter<DriverRegisterStep4State> emit,
  ) async {
    emit(state.copyWith(isReconnecting: true));
    final connected = await repository.retryConnection();
    if (connected) {
      emit(state.copyWith(
        isReconnecting: false,
        status: DriverRegisterStep4Status.reviewing,
        feedbackMessage: 'Connection restored to Lethbridge fleet server!',
      ));
    } else {
      emit(state.copyWith(
        isReconnecting: false,
        feedbackMessage:
            'Unable to reconnect. Please call offline dispatch at 403-328-8888.',
      ));
    }
  }

  void _onGoHomeRequested(
    DriverRegisterStep4GoHomeRequested event,
    Emitter<DriverRegisterStep4State> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage: 'Redirecting to Driver Home dashboard...',
    ));
  }

  void _onFixDocumentsRequested(
    DriverRegisterStep4FixDocumentsRequested event,
    Emitter<DriverRegisterStep4State> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage: 'Navigating to document re-upload...',
    ));
  }

  void _onUpdateVehicleRequested(
    DriverRegisterStep4UpdateVehicleRequested event,
    Emitter<DriverRegisterStep4State> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage: 'Navigating to vehicle update...',
    ));
  }

  void _onContactSupportRequested(
    DriverRegisterStep4ContactSupportRequested event,
    Emitter<DriverRegisterStep4State> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage:
          'Connecting to Lethbridge Fleet Support (${state.data.offlinePhone})...',
    ));
  }

  void _onStateSwitched(
    DriverRegisterStep4StateSwitched event,
    Emitter<DriverRegisterStep4State> emit,
  ) {
    switch (event.status) {
      case DriverRegisterStep4Status.approved:
        // Image 1: You're approved!
        emit(state.copyWith(
          status: DriverRegisterStep4Status.approved,
          isRefreshing: false,
          isReconnecting: false,
          data: const DriverRegisterStep4Data(
            driverName: 'Marcus Vance',
            vehicleModel: 'Toyota Camry Hybrid',
            vehicleYear: 2021,
            licensePlate: 'AB · BCC-9482',
            fleetId: '#409',
            fleetTag: 'Active Partner',
            operatingHub: 'Lethbridge Downtown & Airport',
            milestones: [
              DriverApplicationMilestone(
                title: 'Application submitted',
                subtitle: 'Driver profile and provincial licensing received',
                timestamp: 'Oct 24, 2024',
                status: MilestoneStatus.completed,
              ),
              DriverApplicationMilestone(
                title: 'Documents reviewed & verified',
                subtitle: 'City of Lethbridge Bylaw 5834 passed',
                status: MilestoneStatus.completed,
                badgeText: 'Passed',
              ),
              DriverApplicationMilestone(
                title: 'Approved and ready to drive',
                subtitle: 'Vehicle inspection & insurance authenticated',
                status: MilestoneStatus.completed,
                badgeText: '● Ready',
              ),
            ],
          ),
        ));
        break;

      case DriverRegisterStep4Status.reviewing:
        // Image 2: Review In Progress
        emit(state.copyWith(
          status: DriverRegisterStep4Status.reviewing,
          isRefreshing: false,
          isReconnecting: false,
          data: const DriverRegisterStep4Data(
            driverName: 'Marcus Vance',
            vehicleModel: 'Toyota Camry Hybrid',
            vehicleYear: 2021,
            licensePlate: 'AB · BCC-9482',
            fleetId: '#8491',
            fleetTag: 'Hybrid Fleet',
            operatingHub: 'Lethbridge Downtown & Airport',
            milestones: [
              DriverApplicationMilestone(
                title: 'Application submitted',
                subtitle: 'Submitted yesterday, 4:15 PM',
                status: MilestoneStatus.completed,
              ),
              DriverApplicationMilestone(
                title: 'Documents under review',
                subtitle: 'Bridge City compliance check in progress',
                status: MilestoneStatus.inProgress,
                badgeText: '● IN PROGRESS',
                tags: [
                  'Class 4 License',
                  'Vulnerable Sector',
                  'City Inspection',
                ],
              ),
              DriverApplicationMilestone(
                title: 'Approved and ready to drive',
                subtitle: 'Pending compliance sign-off',
                status: MilestoneStatus.pending,
              ),
            ],
          ),
        ));
        break;

      case DriverRegisterStep4Status.actionRequired:
        // Image 3: Action Required / Document On Hold
        emit(state.copyWith(
          status: DriverRegisterStep4Status.actionRequired,
          isRefreshing: false,
          isReconnecting: false,
          data: const DriverRegisterStep4Data(
            driverName: 'Marcus Vance',
            vehicleModel: 'Toyota Camry Hybrid',
            vehicleYear: 2021,
            licensePlate: 'AB · BCC-9482',
            fleetId: '#8491',
            fleetTag: 'Review Hold',
            operatingHub: 'Lethbridge Downtown & Airport',
            alertTitle: 'Action needed on your application',
            alertMessage:
                'One of your documents needs to be re-uploaded before we can activate your driver account.',
            flaggedDocumentName: "Driver's Licence",
            flaggedDocumentReason: 'Blurry photo · 4 corners cut off',
            milestones: [
              DriverApplicationMilestone(
                title: 'Application submitted',
                subtitle: 'Profile data & vehicle history received',
                timestamp: 'Oct 24',
                status: MilestoneStatus.completed,
              ),
              DriverApplicationMilestone(
                title: 'Documents review',
                subtitle: '1 document requires driver re-upload',
                status: MilestoneStatus.actionRequired,
                badgeText: '! ACTION REQUIRED',
              ),
              DriverApplicationMilestone(
                title: 'Approved and ready to drive',
                subtitle: 'Unlocks Lethbridge dispatch meter & active queue',
                status: MilestoneStatus.locked,
              ),
            ],
          ),
        ));
        break;

      case DriverRegisterStep4Status.rejected:
        // Image 4: Application Ineligible (Vehicle Too Old - Bylaw 5834)
        emit(state.copyWith(
          status: DriverRegisterStep4Status.rejected,
          isRefreshing: false,
          isReconnecting: false,
          data: const DriverRegisterStep4Data(
            driverName: 'Marcus Vance',
            vehicleModel: 'Toyota Echo',
            vehicleYear: 2008,
            licensePlate: 'ABC-1234',
            fleetId: '#8491',
            fleetTag: 'INELIGIBLE VEHICLE',
            operatingHub: 'Lethbridge Downtown & Airport',
            alertTitle: 'Application could not be approved',
            alertMessage:
                'Your vehicle model year (2008) does not meet Lethbridge Taxi Commission Bylaw 5834 requirement (must be 2014 or newer).',
            milestones: [
              DriverApplicationMilestone(
                title: 'Application submitted',
                subtitle: 'All personal driver credentials verified',
                timestamp: 'Oct 24',
                status: MilestoneStatus.completed,
              ),
              DriverApplicationMilestone(
                title: 'Compliance inspection',
                subtitle: 'Vehicle eligibility rejected (Bylaw 5834)',
                timestamp: 'Oct 26',
                status: MilestoneStatus.rejected,
                badgeText: 'Rejected',
              ),
              DriverApplicationMilestone(
                title: 'Account activation',
                subtitle: 'Closed pending vehicle resolution',
                status: MilestoneStatus.locked,
              ),
            ],
          ),
        ));
        break;

      case DriverRegisterStep4Status.offline:
        // Image 5: Offline / Reconnecting State
        emit(state.copyWith(
          status: DriverRegisterStep4Status.offline,
          isRefreshing: false,
          isReconnecting: false,
          data: const DriverRegisterStep4Data(
            driverName: 'Marcus Vance',
            vehicleModel: 'Toyota Camry Hybrid',
            vehicleYear: 2021,
            licensePlate: 'AB · BCC-9482',
            fleetId: '#8491',
            fleetTag: 'Hybrid Fleet',
            operatingHub: 'Lethbridge Downtown & Airport',
            lastSyncedTime: '2:14 PM',
            offlinePhone: '403-328-8888',
            milestones: [
              DriverApplicationMilestone(
                title: 'Application submitted',
                subtitle: 'Yesterday at 4:32 PM',
                status: MilestoneStatus.completed,
              ),
              DriverApplicationMilestone(
                title: 'Documents under review',
                subtitle: 'Lethbridge City compliance & background screening',
                status: MilestoneStatus.inProgress,
                badgeText: 'In Progress',
              ),
              DriverApplicationMilestone(
                title: 'Approved and ready to drive',
                subtitle: 'Automated dispatch unlock',
                status: MilestoneStatus.locked,
              ),
            ],
          ),
        ));
        break;
    }
  }
}
