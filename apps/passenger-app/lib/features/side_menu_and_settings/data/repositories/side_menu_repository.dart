import '../models/side_menu_model.dart';

abstract class SideMenuRepository {
  Future<SideMenuProfile> getProfile(QaSideMenuState state);
  Future<ActiveTripBannerData?> getActiveTrip(QaSideMenuState state);
  Future<int> getUnreadNotificationsCount(QaSideMenuState state);
  Future<bool> logout();
}

class SideMenuRepositoryImpl implements SideMenuRepository {
  final Duration latency;

  SideMenuRepositoryImpl({
    this.latency = const Duration(milliseconds: 100),
  });

  @override
  Future<SideMenuProfile> getProfile(QaSideMenuState state) async {
    if (latency > Duration.zero) await Future.delayed(latency);
    if (state == QaSideMenuState.liveTripActive) {
      return SideMenuProfile.clara;
    }
    return SideMenuProfile.marcus;
  }

  @override
  Future<ActiveTripBannerData?> getActiveTrip(QaSideMenuState state) async {
    if (latency > Duration.zero) await Future.delayed(latency);
    if (state == QaSideMenuState.liveTripActive) {
      return const ActiveTripBannerData();
    }
    return null;
  }

  @override
  Future<int> getUnreadNotificationsCount(QaSideMenuState state) async {
    if (latency > Duration.zero) await Future.delayed(latency);
    if (state == QaSideMenuState.unreadBadge ||
        state == QaSideMenuState.liveTripActive) {
      return 3;
    }
    return 0;
  }

  @override
  Future<bool> logout() async {
    if (latency > Duration.zero) await Future.delayed(latency);
    return true;
  }
}
