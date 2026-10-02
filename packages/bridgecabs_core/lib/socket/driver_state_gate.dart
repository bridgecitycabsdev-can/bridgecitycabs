/// Socket snapshots apply only when `v` is strictly newer than the last one kept.
/// A REST reload may replace the same version, because the user asked for a fresh copy.
class DriverStateGate {
  int? lastApplied;

  bool acceptSocket(int version) {
    final last = lastApplied;
    if (last != null && version <= last) return false;
    lastApplied = version;
    return true;
  }

  bool acceptRest(int version) {
    final last = lastApplied;
    if (last != null && version < last) return false;
    lastApplied = version;
    return true;
  }
}
