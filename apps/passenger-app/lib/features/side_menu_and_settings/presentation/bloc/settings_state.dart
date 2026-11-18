import 'package:equatable/equatable.dart';
import '../../data/models/faq_item_model.dart';
import '../../data/models/side_menu_and_settings_config.dart';

class SettingsState extends Equatable {
  final bool pushNotificationsEnabled;
  final bool systemNotificationsDisabled;
  final String searchQuery;
  final FaqCategory selectedCategory;
  final List<FaqItem> faqs;
  final Set<String> expandedFaqIds;
  final String? feedbackMessage;
  final String? navigationTarget;

  const SettingsState({
    this.pushNotificationsEnabled = false,
    this.systemNotificationsDisabled = true,
    this.searchQuery = '',
    this.selectedCategory = FaqCategory.all,
    this.faqs = SideMenuAndSettingsConfig.defaultFaqs,
    this.expandedFaqIds = const {'faq_fare_calc'},
    this.feedbackMessage,
    this.navigationTarget,
  });

  bool isFaqExpanded(String id) => expandedFaqIds.contains(id);

  bool get showSystemWarningAlert => systemNotificationsDisabled;

  List<FaqItem> get filteredFaqs => faqs;

  SettingsState copyWith({
    bool? pushNotificationsEnabled,
    bool? systemNotificationsDisabled,
    String? searchQuery,
    FaqCategory? selectedCategory,
    List<FaqItem>? faqs,
    Set<String>? expandedFaqIds,
    String? Function()? feedbackMessage,
    String? Function()? navigationTarget,
  }) {
    return SettingsState(
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      systemNotificationsDisabled:
          systemNotificationsDisabled ?? this.systemNotificationsDisabled,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      faqs: faqs ?? this.faqs,
      expandedFaqIds: expandedFaqIds ?? this.expandedFaqIds,
      feedbackMessage: feedbackMessage != null
          ? feedbackMessage()
          : this.feedbackMessage,
      navigationTarget: navigationTarget != null
          ? navigationTarget()
          : this.navigationTarget,
    );
  }

  @override
  List<Object?> get props => [
        pushNotificationsEnabled,
        systemNotificationsDisabled,
        searchQuery,
        selectedCategory,
        faqs,
        expandedFaqIds,
        feedbackMessage,
        navigationTarget,
      ];
}
