import 'package:equatable/equatable.dart';
import '../../data/models/side_menu_model.dart';

abstract class SideMenuEvent extends Equatable {
  const SideMenuEvent();

  @override
  List<Object?> get props => [];
}

class SideMenuStarted extends SideMenuEvent {
  final SideMenuLayout? initialLayout;
  final QaSideMenuState? initialQaState;

  const SideMenuStarted({
    this.initialLayout,
    this.initialQaState,
  });

  @override
  List<Object?> get props => [initialLayout, initialQaState];
}

class SideMenuLayoutToggled extends SideMenuEvent {
  const SideMenuLayoutToggled();
}

class SideMenuQaStateSelected extends SideMenuEvent {
  final QaSideMenuState qaState;

  const SideMenuQaStateSelected(this.qaState);

  @override
  List<Object?> get props => [qaState];
}

class SideMenuNavigationTapped extends SideMenuEvent {
  final String route;

  const SideMenuNavigationTapped(this.route);

  @override
  List<Object?> get props => [route];
}

class SideMenuLiveTripTapped extends SideMenuEvent {
  const SideMenuLiveTripTapped();
}

class SideMenuLogoutTapped extends SideMenuEvent {
  const SideMenuLogoutTapped();
}

class SideMenuDismissTapped extends SideMenuEvent {
  const SideMenuDismissTapped();
}
