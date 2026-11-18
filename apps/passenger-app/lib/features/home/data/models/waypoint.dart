import 'package:equatable/equatable.dart';

enum WaypointType {
  pickup,
  stop,
  dropoff,
}

/// Represents a pickup, intermediate stop, or final destination dropoff.
class Waypoint extends Equatable {
  final String id;
  final WaypointType type;
  final String title;
  final String subtitle;
  final double lat;
  final double lng;
  final String? tag;
  final int? waitTimeMinutes;

  const Waypoint({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.lat,
    required this.lng,
    this.tag,
    this.waitTimeMinutes,
  });

  bool get isPickup => type == WaypointType.pickup;
  bool get isStop => type == WaypointType.stop;
  bool get isDropoff => type == WaypointType.dropoff;

  Waypoint copyWith({
    String? id,
    WaypointType? type,
    String? title,
    String? subtitle,
    double? lat,
    double? lng,
    String? tag,
    int? waitTimeMinutes,
  }) {
    return Waypoint(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      tag: tag ?? this.tag,
      waitTimeMinutes: waitTimeMinutes ?? this.waitTimeMinutes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        subtitle,
        lat,
        lng,
        tag,
        waitTimeMinutes,
      ];
}
