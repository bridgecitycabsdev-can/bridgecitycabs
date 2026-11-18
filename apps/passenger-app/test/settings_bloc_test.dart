import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/side_menu_and_settings/side_menu_and_settings.dart';

void main() {
  group('SettingsBloc Tests', () {
    late SettingsBloc bloc;

    setUp(() {
      bloc = SettingsBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state contains defaults', () {
      expect(bloc.state.status, SettingsStatus.initial);
      expect(bloc.state.pushNotificationsEnabled, isTrue);
      expect(bloc.state.showSystemWarningAlert, isTrue);
      expect(bloc.state.selectedCategory, FaqCategory.all);
      expect(bloc.state.searchQuery, isEmpty);
      expect(bloc.state.expandedFaqIds, contains('faq_metered_rates'));
    });

    test('SettingsStarted loads FAQs and system warnings', () async {
      bloc.add(const SettingsStarted());
      await expectLater(
        bloc.stream,
        emits(predicate<SettingsState>((s) =>
            s.status == SettingsStatus.ready &&
            s.allFaqs.isNotEmpty &&
            s.filteredFaqs.isNotEmpty)),
      );
    });

    test('SettingsPushToggleChanged updates push toggle', () async {
      bloc.add(const SettingsPushToggleChanged(false));
      await expectLater(
        bloc.stream,
        emits(predicate<SettingsState>((s) =>
            s.pushNotificationsEnabled == false &&
            s.feedbackMessage != null &&
            s.feedbackMessage!.contains('disabled'))),
      );
    });

    test('SettingsCategorySelected filters FAQs by category', () async {
      bloc.add(const SettingsStarted());
      await Future.delayed(const Duration(milliseconds: 10));

      bloc.add(const SettingsCategorySelected(FaqCategory.payments));
      await expectLater(
        bloc.stream,
        emits(predicate<SettingsState>((s) =>
            s.selectedCategory == FaqCategory.payments &&
            s.filteredFaqs.every((faq) => faq.category == FaqCategory.payments))),
      );
    });

    test('SettingsSearchChanged filters FAQs by query', () async {
      bloc.add(const SettingsStarted());
      await Future.delayed(const Duration(milliseconds: 10));

      bloc.add(const SettingsSearchChanged('metered'));
      await expectLater(
        bloc.stream,
        emits(predicate<SettingsState>((s) =>
            s.searchQuery == 'metered' &&
            s.filteredFaqs.any((faq) => faq.id == 'faq_metered_rates'))),
      );
    });

    test('SettingsFaqItemToggled toggles expansion', () async {
      bloc.add(const SettingsStarted());
      await Future.delayed(const Duration(milliseconds: 10));

      // Initially 'faq_metered_rates' is expanded; toggling should collapse it
      bloc.add(const SettingsFaqItemToggled('faq_metered_rates'));
      await expectLater(
        bloc.stream,
        emits(predicate<SettingsState>((s) =>
            !s.expandedFaqIds.contains('faq_metered_rates'))),
      );

      // Toggling again expands it
      bloc.add(const SettingsFaqItemToggled('faq_metered_rates'));
      await expectLater(
        bloc.stream,
        emits(predicate<SettingsState>((s) =>
            s.expandedFaqIds.contains('faq_metered_rates'))),
      );
    });
  });
}
