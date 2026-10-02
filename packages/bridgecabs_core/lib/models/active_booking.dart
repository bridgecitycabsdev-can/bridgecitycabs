import '../http/json_map.dart';

class ActiveBooking {
  const ActiveBooking({
    required this.trackingId,
    required this.status,
    required this.pickupAddress,
  });

  final String trackingId;
  final String status;
  final String? pickupAddress;

  static ActiveBooking? tryParse(Object? data) {
    final json = jsonMap(data);
    if (json == null) return null;
    final trackingId = json['trackingId'];
    final status = json['status'];
    if (trackingId is! String || status is! String) return null;
    return ActiveBooking(
      trackingId: trackingId,
      status: status,
      pickupAddress: _pickup(json['stops']),
    );
  }

  static String? _pickup(Object? stops) {
    if (stops is! List) return null;
    Map<String, dynamic>? fallback;
    for (final stop in stops) {
      final json = jsonMap(stop);
      if (json == null) continue;
      fallback ??= json;
      if (json['type'] == 'PICKUP' && json['address'] is String) {
        return json['address'] as String;
      }
    }
    final address = fallback?['address'];
    return address is String ? address : null;
  }
}
