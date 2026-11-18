import 'driver_active_trip_info.dart';
import 'driver_menu_item.dart';
import 'driver_menu_profile.dart';
import 'driver_menu_stats.dart';
import 'driver_menu_status.dart';

class DriverMenuConfig {
  const DriverMenuConfig._();

  static const String appVersion = 'Version 1.0.32';
  static const String supportHelpline = '403-328-8888';

  static List<DriverMenuItemState> defaultMenuItems({
    DriverMenuItemId? selectedId = DriverMenuItemId.earnings,
    Set<DriverMenuItemId> lockedIds = const {},
    bool flagRideNotification = false,
  }) {
    return DriverMenuItemId.values.map((id) {
      return DriverMenuItemState(
        id: id,
        isSelected: id == selectedId,
        isLocked: lockedIds.contains(id),
        hasNotificationBadge:
            id == DriverMenuItemId.flagRide && flagRideNotification,
      );
    }).toList();
  }

  static DriverMenuProfile defaultProfile() {
    return const DriverMenuProfile(
      name: 'Shajil Kunhumon',
      rating: 4.9,
      totalRides: 120,
      fleetUnit: 'LETHBRIDGE FLEET UNIT #42',
      municipalPermit: 'City Permit LIC-4812',
    );
  }

  static DriverMenuProfile dialogProfile() {
    return const DriverMenuProfile(
      name: 'Shajil Kunhumon',
      rating: 4.96,
      totalRides: 14,
      fleetUnit: 'Cab #408 • Lethbridge Central',
      municipalPermit: 'City Permit LIC-4812',
      shiftDuration: '4h 18m',
    );
  }

  static DriverMenuStats onlineStats() {
    return const DriverMenuStats(
      todayEarnings: 41.77,
      ridesCompleted: 1,
      distanceKm: 10.0,
    );
  }

  static DriverMenuStats dialogStats() {
    return const DriverMenuStats(
      todayEarnings: 184.50,
      ridesCompleted: 14,
      distanceKm: 42.5,
    );
  }

  static DriverMenuStats offlineStats() {
    return const DriverMenuStats(
      todayEarnings: 0.00,
      ridesCompleted: 0,
      distanceKm: 0.0,
      shiftPrompt: '● Go online to start shift',
    );
  }

  static DriverActiveTripInfo activeTripInfo() {
    return const DriverActiveTripInfo(
      unitNumber: 'Unit 42',
      destinationAddress: '501 1st Ave S',
      alertMessage:
          'Finish current trip before logging out.\nUnit 42 is on active dispatch to 501 1st Ave S.',
      hasFlagRideNotification: true,
      dispatchLinePhone: '403-328-8888',
    );
  }
}
