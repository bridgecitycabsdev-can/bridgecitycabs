enum DriverShiftMode {
  active,
  away,
  locked;

  bool get isActive => this == DriverShiftMode.active;
  bool get isAway => this == DriverShiftMode.away;
  bool get isLocked => this == DriverShiftMode.locked;
}
