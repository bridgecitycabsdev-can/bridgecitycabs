import 'package:equatable/equatable.dart';
import '../../data/models/faq_item_model.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsStarted extends SettingsEvent {
  const SettingsStarted();
}

class SettingsPushToggleChanged extends SettingsEvent {
  final bool enabled;

  const SettingsPushToggleChanged(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class SettingsOpenSystemSettingsTapped extends SettingsEvent {
  const SettingsOpenSystemSettingsTapped();
}

class SettingsSearchChanged extends SettingsEvent {
  final String query;

  const SettingsSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class SettingsCategorySelected extends SettingsEvent {
  final FaqCategory category;

  const SettingsCategorySelected(this.category);

  @override
  List<Object?> get props => [category];
}

class SettingsFaqItemToggled extends SettingsEvent {
  final String faqId;

  const SettingsFaqItemToggled(this.faqId);

  @override
  List<Object?> get props => [faqId];
}

class SettingsContactSupportTapped extends SettingsEvent {
  const SettingsContactSupportTapped();
}

class SettingsLogoutTapped extends SettingsEvent {
  const SettingsLogoutTapped();
}

class SettingsNavigationTapped extends SettingsEvent {
  final String route;

  const SettingsNavigationTapped(this.route);

  @override
  List<Object?> get props => [route];
}
