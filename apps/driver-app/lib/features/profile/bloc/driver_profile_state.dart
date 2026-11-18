import 'package:equatable/equatable.dart';
import '../data/models/driver_credential_model.dart';
import '../data/models/driver_profile_config.dart';
import '../data/models/driver_profile_data.dart';
import '../data/models/driver_profile_status.dart';
import '../data/models/driver_profile_tab.dart';

class DriverProfileState extends Equatable {
  final DriverProfileStatus status;
  final DriverProfileTab activeTab;
  final DriverProfileData profileData;
  final DriverCredentialModel? inspectedCredential;
  final List<DriverProfileTab> availableTabs;
  final bool isActionLoading;
  final String? feedbackMessage;

  const DriverProfileState({
    required this.status,
    required this.activeTab,
    required this.profileData,
    this.inspectedCredential,
    this.availableTabs = const [
      DriverProfileTab.info,
      DriverProfileTab.documents,
    ],
    this.isActionLoading = false,
    this.feedbackMessage,
  });

  factory DriverProfileState.initial() {
    return DriverProfileState(
      status: DriverProfileStatus.activeOnline,
      activeTab: DriverProfileTab.info,
      profileData: DriverProfileConfig.activeOnlinePreset(),
      inspectedCredential: null,
      availableTabs: const [
        DriverProfileTab.info,
        DriverProfileTab.documents,
      ],
      isActionLoading: false,
      feedbackMessage: null,
    );
  }

  DriverProfileState copyWith({
    DriverProfileStatus? status,
    DriverProfileTab? activeTab,
    DriverProfileData? profileData,
    DriverCredentialModel? inspectedCredential,
    bool clearInspection = false,
    List<DriverProfileTab>? availableTabs,
    bool? isActionLoading,
    String? feedbackMessage,
  }) {
    return DriverProfileState(
      status: status ?? this.status,
      activeTab: activeTab ?? this.activeTab,
      profileData: profileData ?? this.profileData,
      inspectedCredential: clearInspection
          ? null
          : (inspectedCredential ?? this.inspectedCredential),
      availableTabs: availableTabs ?? this.availableTabs,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      feedbackMessage: feedbackMessage,
    );
  }

  bool get isActiveOnline => status == DriverProfileStatus.activeOnline;
  bool get isCredentialExpiredLocked =>
      status == DriverProfileStatus.credentialExpiredLocked;
  bool get isExpiringSoonInspection =>
      status == DriverProfileStatus.expiringSoonInspection;
  bool get isOfflineSyncAlert => status == DriverProfileStatus.offlineSyncAlert;
  bool get isInspectionModalVisible => inspectedCredential != null;

  @override
  List<Object?> get props => [
    status,
    activeTab,
    profileData,
    inspectedCredential,
    availableTabs,
    isActionLoading,
    feedbackMessage,
  ];
}
