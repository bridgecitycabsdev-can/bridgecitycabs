enum DriverMenuItemId {
  profile('My Profile'),
  earnings('Earnings'),
  history('History'),
  reviews('Reviews'),
  settings('Settings'),
  flagRide('Flag Ride');

  final String label;
  const DriverMenuItemId(this.label);
}

class DriverMenuItemState {
  final DriverMenuItemId id;
  final bool isSelected;
  final bool isLocked;
  final bool hasNotificationBadge;
  final String? badgeText;

  const DriverMenuItemState({
    required this.id,
    this.isSelected = false,
    this.isLocked = false,
    this.hasNotificationBadge = false,
    this.badgeText,
  });

  DriverMenuItemState copyWith({
    bool? isSelected,
    bool? isLocked,
    bool? hasNotificationBadge,
    String? badgeText,
  }) {
    return DriverMenuItemState(
      id: id,
      isSelected: isSelected ?? this.isSelected,
      isLocked: isLocked ?? this.isLocked,
      hasNotificationBadge:
          hasNotificationBadge ?? this.hasNotificationBadge,
      badgeText: badgeText ?? this.badgeText,
    );
  }
}
