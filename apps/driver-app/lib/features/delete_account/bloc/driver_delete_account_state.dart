import 'package:equatable/equatable.dart';

import '../data/models/driver_delete_checklist.dart';
import '../data/models/driver_delete_confirmation_data.dart';
import '../data/models/driver_delete_safeguard_block.dart';
import '../data/models/driver_delete_status.dart';

class DriverDeleteAccountState extends Equatable {
  final DriverDeleteStatus status;
  final DriverDeleteChecklist? checklist;
  final List<DriverDeleteSafeguardBlock> safeguardBlocks;
  final DriverDeleteSafeguardBlockType selectedBlockType;
  final DriverDeleteConfirmationData confirmationData;
  final bool isTestHoldActive;
  final bool isLoading;
  final bool isSignedOut;
  final bool navigateToTrip;
  final String? toastMessage;

  const DriverDeleteAccountState({
    this.status = DriverDeleteStatus.checklistReady,
    this.checklist,
    this.safeguardBlocks = const [],
    this.selectedBlockType = DriverDeleteSafeguardBlockType.tripActive,
    this.confirmationData = const DriverDeleteConfirmationData(),
    this.isTestHoldActive = false,
    this.isLoading = false,
    this.isSignedOut = false,
    this.navigateToTrip = false,
    this.toastMessage,
  });

  DriverDeleteSafeguardBlock get activeSafeguardBlock {
    return safeguardBlocks.firstWhere(
      (b) => b.type == selectedBlockType,
      orElse: () => safeguardBlocks.isNotEmpty
          ? safeguardBlocks.first
          : const DriverDeleteSafeguardBlock(
              type: DriverDeleteSafeguardBlockType.tripActive,
              tag: 'BLOCK CRITICAL',
              cabUnit: 'Cab #429',
              title: 'Active trip underway',
              description: 'Finish your current trip before deleting your account.',
              actionButtonText: 'Go to trip',
            ),
    );
  }

  bool get canProceedWithDeletion {
    if (isTestHoldActive) return false;
    return checklist?.isReadyToProceed ?? false;
  }

  DriverDeleteAccountState copyWith({
    DriverDeleteStatus? status,
    DriverDeleteChecklist? checklist,
    List<DriverDeleteSafeguardBlock>? safeguardBlocks,
    DriverDeleteSafeguardBlockType? selectedBlockType,
    DriverDeleteConfirmationData? confirmationData,
    bool? isTestHoldActive,
    bool? isLoading,
    bool? isSignedOut,
    bool? navigateToTrip,
    String? toastMessage,
    bool clearToast = false,
  }) {
    return DriverDeleteAccountState(
      status: status ?? this.status,
      checklist: checklist ?? this.checklist,
      safeguardBlocks: safeguardBlocks ?? this.safeguardBlocks,
      selectedBlockType: selectedBlockType ?? this.selectedBlockType,
      confirmationData: confirmationData ?? this.confirmationData,
      isTestHoldActive: isTestHoldActive ?? this.isTestHoldActive,
      isLoading: isLoading ?? this.isLoading,
      isSignedOut: isSignedOut ?? this.isSignedOut,
      navigateToTrip: navigateToTrip ?? this.navigateToTrip,
      toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        checklist,
        safeguardBlocks,
        selectedBlockType,
        confirmationData,
        isTestHoldActive,
        isLoading,
        isSignedOut,
        navigateToTrip,
        toastMessage,
      ];
}
