import '../http/json_map.dart';

class DriverShiftSnapshot {
  const DriverShiftSnapshot({
    required this.version,
    required this.status,
    required this.shiftStartedAt,
    required this.unitNumber,
    required this.bookingTrackingId,
    required this.bookingStatus,
  });

  final int version;
  final String status;
  final DateTime? shiftStartedAt;
  final String? unitNumber;
  final String? bookingTrackingId;
  final String? bookingStatus;

  bool get onShift => shiftStartedAt != null;

  static DriverShiftSnapshot? tryParse(Object? data) {
    final json = jsonMap(data);
    if (json == null) return null;
    final version = json['v'];
    final status = json['status'];
    if (version is! int || status is! String) return null;
    final shift = jsonMap(json['shift']);
    final vehicle = jsonMap(shift?['vehicle']);
    final booking = jsonMap(json['booking']);
    final started = shift?['startedAt'];
    return DriverShiftSnapshot(
      version: version,
      status: status,
      shiftStartedAt: started is String ? DateTime.tryParse(started) : null,
      unitNumber: _text(vehicle?['unitNumber']),
      bookingTrackingId: _text(booking?['trackingId']),
      bookingStatus: _text(booking?['status']),
    );
  }
}

String? _text(Object? value) {
  if (value is String && value.isNotEmpty) return value;
  return null;
}
