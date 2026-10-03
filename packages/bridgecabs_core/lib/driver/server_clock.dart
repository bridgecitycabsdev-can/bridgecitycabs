import 'package:clock/clock.dart';

/// Aligns local countdowns with the server clock carried on offer snapshots.
class ServerClock {
  Duration _offset = Duration.zero;

  void sync(DateTime serverNow) {
    _offset = serverNow.toUtc().difference(clock.now().toUtc());
  }

  DateTime now() => clock.now().toUtc().add(_offset);
}
