import 'package:equatable/equatable.dart';
import '../../data/models/side_menu_model.dart';

class SideMenuState extends Equatable {
  final SideMenuLayout layout;
  final QaSideMenuState qaState;
  final SideMenuProfile profile;
  final ActiveTripBannerData? activeTrip;
  final int unreadCount;
  final String? feedbackMessage;
  final String? navigationTarget;
  final bool isClosed;

  const SideMenuState({
    this.layout = SideMenuLayout.grid,
    this.qaState = QaSideMenuState.defaultState,
    this.profile = SideMenuProfile.marcus,
    this.activeTrip,
    this.unreadCount = 3,
    this.feedbackMessage,
    this.navigationTarget,
    this.isClosed = false,
  });

  bool get isGrid => layout == SideMenuLayout.grid;
  bool get isList => layout == SideMenuLayout.list;
  bool get hasActiveTrip => activeTrip != null;
  bool get isLogoutLocked => hasActiveTrip;

  SideMenuState copyWith({
    SideMenuLayout? layout,
    QaSideMenuState? qaState,
    SideMenuProfile? profile,
    ActiveTripBannerData? Function()? activeTrip,
    int? unreadCount,
    String? Function()? feedbackMessage,
    String? Function()? navigationTarget,
    bool? isClosed,
  }) {
    return SideMenuState(
      layout: layout ?? this.layout,
      qaState: qaState ?? this.qaState,
      profile: profile ?? this.profile,
      activeTrip: activeTrip != null ? activeTrip() : this.activeTrip,
      unreadCount: unreadCount ?? this.unreadCount,
      feedbackMessage: feedbackMessage != null
          ? feedbackMessage()
          : this.feedbackMessage,
      navigationTarget: navigationTarget != null
          ? navigationTarget()
          : this.navigationTarget,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  @override
  List<Object?> get props => [
        layout,
        qaState,
        profile,
        activeTrip,
        unreadCount,
        feedbackMessage,
        navigationTarget,
        isClosed,
      ];
}
