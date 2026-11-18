import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../data/models/driver_active_trip_info.dart';
import '../data/models/driver_menu_config.dart';
import '../data/models/driver_menu_item.dart';
import '../data/models/driver_menu_profile.dart';
import '../data/models/driver_menu_stats.dart';
import '../data/models/driver_menu_status.dart';

class DriverMenuState extends Equatable {
  final DriverMenuStatus status;
  final DriverMenuStatus previousStatus;
  final DriverMenuProfile profile;
  final DriverMenuStats stats;
  final DriverActiveTripInfo activeTrip;
  final List<DriverMenuItemState> menuItems;
  final bool isActionLoading;
  final bool shouldNavigateToLogin;
  final String? selectedRouteTarget;
  final String? feedbackMessage;

  const DriverMenuState({
    required this.status,
    required this.previousStatus,
    required this.profile,
    required this.stats,
    required this.activeTrip,
    required this.menuItems,
    this.isActionLoading = false,
    this.shouldNavigateToLogin = false,
    this.selectedRouteTarget,
    this.feedbackMessage,
  });

  factory DriverMenuState.initial({
    DriverMenuStatus status = DriverMenuStatus.online,
  }) {
    return DriverMenuState(
      status: status,
      previousStatus: DriverMenuStatus.online,
      profile: DriverMenuConfig.defaultProfile(),
      stats: DriverMenuConfig.onlineStats(),
      activeTrip: DriverMenuConfig.activeTripInfo(),
      menuItems: DriverMenuConfig.defaultMenuItems(
        selectedId: DriverMenuItemId.earnings,
      ),
      isActionLoading: false,
      shouldNavigateToLogin: false,
      selectedRouteTarget: null,
      feedbackMessage: null,
    );
  }

  DriverMenuState copyWith({
    DriverMenuStatus? status,
    DriverMenuStatus? previousStatus,
    DriverMenuProfile? profile,
    DriverMenuStats? stats,
    DriverActiveTripInfo? activeTrip,
    List<DriverMenuItemState>? menuItems,
    bool? isActionLoading,
    bool? shouldNavigateToLogin,
    String? selectedRouteTarget,
    String? feedbackMessage,
  }) {
    return DriverMenuState(
      status: status ?? this.status,
      previousStatus: previousStatus ?? this.previousStatus,
      profile: profile ?? this.profile,
      stats: stats ?? this.stats,
      activeTrip: activeTrip ?? this.activeTrip,
      menuItems: menuItems ?? this.menuItems,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      shouldNavigateToLogin:
          shouldNavigateToLogin ?? this.shouldNavigateToLogin,
      selectedRouteTarget: selectedRouteTarget,
      feedbackMessage: feedbackMessage,
    );
  }

  bool get isOnline => status == DriverMenuStatus.online;
  bool get isOffline => status == DriverMenuStatus.offline;
  bool get isActiveTrip => status == DriverMenuStatus.activeTrip;
  bool get isUnderReview => status == DriverMenuStatus.underReview;
  bool get isLogoutDialogVisible =>
      status == DriverMenuStatus.logoutConfirmation;
  bool get canLogout => status != DriverMenuStatus.activeTrip;

  String get statusBadgeLabel {
    switch (status) {
      case DriverMenuStatus.online:
        return 'ONLINE';
      case DriverMenuStatus.offline:
        return 'Offline';
      case DriverMenuStatus.activeTrip:
        return 'ACTIVE TRIP';
      case DriverMenuStatus.underReview:
        return 'PENDING REVIEW';
      case DriverMenuStatus.logoutConfirmation:
        return 'ONLINE';
    }
  }

  Color get statusBadgeColor {
    switch (status) {
      case DriverMenuStatus.online:
        return const Color(0xFF2E7D32);
      case DriverMenuStatus.offline:
        return Colors.black54;
      case DriverMenuStatus.activeTrip:
        return const Color(0xFF1B5E20);
      case DriverMenuStatus.underReview:
        return const Color(0xFFE65100);
      case DriverMenuStatus.logoutConfirmation:
        return const Color(0xFF2E7D32);
    }
  }

  @override
  List<Object?> get props => [
    status,
    previousStatus,
    profile,
    stats,
    activeTrip,
    menuItems,
    isActionLoading,
    shouldNavigateToLogin,
    selectedRouteTarget,
    feedbackMessage,
  ];
}
