import '../models/faq_item_model.dart';
import '../models/side_menu_and_settings_config.dart';

abstract class SettingsRepository {
  Future<bool> getPushNotificationsEnabled();
  Future<bool> setPushNotificationsEnabled(bool enabled);
  Future<bool> isSystemNotificationsDisabled();
  Future<List<FaqItem>> getFaqs({String? query, FaqCategory? category});
}

class SettingsRepositoryImpl implements SettingsRepository {
  bool _pushEnabled = false;
  final Duration latency;

  SettingsRepositoryImpl({
    this.latency = const Duration(milliseconds: 100),
  });

  @override
  Future<bool> getPushNotificationsEnabled() async {
    if (latency > Duration.zero) await Future.delayed(latency);
    return _pushEnabled;
  }

  @override
  Future<bool> setPushNotificationsEnabled(bool enabled) async {
    if (latency > Duration.zero) await Future.delayed(latency);
    _pushEnabled = enabled;
    return true;
  }

  @override
  Future<bool> isSystemNotificationsDisabled() async {
    if (latency > Duration.zero) await Future.delayed(latency);
    // Matches screenshot 3 where notifications are off in system settings
    return true;
  }

  @override
  Future<List<FaqItem>> getFaqs({
    String? query,
    FaqCategory? category,
  }) async {
    if (latency > Duration.zero) await Future.delayed(latency);

    var list = SideMenuAndSettingsConfig.defaultFaqs;

    if (category != null && category != FaqCategory.all) {
      list = list.where((item) => item.category == category).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      list = list.where((item) {
        return item.question.toLowerCase().contains(q) ||
            item.answer.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }
}
