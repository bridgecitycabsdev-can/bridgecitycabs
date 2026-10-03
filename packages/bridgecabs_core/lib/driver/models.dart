import '../http/json_map.dart';

enum DriverStatus {
  offline,
  available,
  offered,
  assigned,
  enRoutePickup,
  arrived,
  onTrip,
  away;

  static DriverStatus parse(String raw) {
    return switch (raw) {
      'AVAILABLE' => DriverStatus.available,
      'OFFERED' => DriverStatus.offered,
      'ASSIGNED' => DriverStatus.assigned,
      'EN_ROUTE_PICKUP' => DriverStatus.enRoutePickup,
      'ARRIVED' => DriverStatus.arrived,
      'ON_TRIP' => DriverStatus.onTrip,
      'AWAY' => DriverStatus.away,
      _ => DriverStatus.offline,
    };
  }

  String get wire {
    return switch (this) {
      DriverStatus.offline => 'OFFLINE',
      DriverStatus.available => 'AVAILABLE',
      DriverStatus.offered => 'OFFERED',
      DriverStatus.assigned => 'ASSIGNED',
      DriverStatus.enRoutePickup => 'EN_ROUTE_PICKUP',
      DriverStatus.arrived => 'ARRIVED',
      DriverStatus.onTrip => 'ON_TRIP',
      DriverStatus.away => 'AWAY',
    };
  }
}

class OfferPlace {
  const OfferPlace({
    required this.address,
    required this.lat,
    required this.lng,
  });

  final String address;
  final double lat;
  final double lng;

  static OfferPlace? tryParse(Object? data) {
    final json = jsonMap(data);
    if (json == null) return null;
    final address = json['address'];
    final lat = json['lat'];
    final lng = json['lng'];
    if (address is! String || lat is! num || lng is! num) return null;
    return OfferPlace(address: address, lat: lat.toDouble(), lng: lng.toDouble());
  }
}

class Offer {
  const Offer({
    required this.id,
    required this.bookingId,
    required this.expiresAt,
    required this.serverNow,
    required this.pickup,
    required this.dropoff,
    required this.distanceToPickupM,
    required this.tripDistanceM,
    required this.quotedFareCents,
    required this.paymentMethod,
    required this.vanOnly,
    required this.ladyDriverOnly,
    required this.passengerFirstName,
    required this.notes,
  });

  final String id;
  final String? bookingId;
  final DateTime expiresAt;
  final DateTime serverNow;
  final OfferPlace pickup;
  final OfferPlace dropoff;
  final int distanceToPickupM;
  final int tripDistanceM;
  final int quotedFareCents;
  final String paymentMethod;
  final bool vanOnly;
  final bool ladyDriverOnly;
  final String passengerFirstName;
  final String? notes;

  static Offer? tryParse(Object? data, {String? bookingId}) {
    final json = jsonMap(data);
    if (json == null) return null;
    final id = json['id'] ?? json['offerId'];
    final expiresAt = _date(json['expiresAt']);
    final serverNow = _date(json['serverNow']);
    final pickup = OfferPlace.tryParse(json['pickup']);
    final dropoff = OfferPlace.tryParse(json['dropoff']);
    final distanceToPickupM = json['distanceToPickupM'];
    final tripDistanceM = json['tripDistanceM'];
    final quotedFareCents = json['quotedFareCents'];
    final paymentMethod = json['paymentMethod'];
    final vanOnly = json['vanOnly'];
    final ladyDriverOnly = json['ladyDriverOnly'];
    final passengerFirstName = json['passengerFirstName'];
    if (id is! String ||
        expiresAt == null ||
        serverNow == null ||
        pickup == null ||
        dropoff == null ||
        distanceToPickupM is! int ||
        tripDistanceM is! int ||
        quotedFareCents is! int ||
        paymentMethod is! String ||
        vanOnly is! bool ||
        ladyDriverOnly is! bool ||
        passengerFirstName is! String) {
      return null;
    }
    final notes = json['notes'];
    return Offer(
      id: id,
      bookingId: (json['bookingId'] as String?) ?? bookingId,
      expiresAt: expiresAt,
      serverNow: serverNow,
      pickup: pickup,
      dropoff: dropoff,
      distanceToPickupM: distanceToPickupM,
      tripDistanceM: tripDistanceM,
      quotedFareCents: quotedFareCents,
      paymentMethod: paymentMethod,
      vanOnly: vanOnly,
      ladyDriverOnly: ladyDriverOnly,
      passengerFirstName: passengerFirstName,
      notes: notes is String ? notes : null,
    );
  }
}

class DriverBookingStop {
  const DriverBookingStop({
    required this.sequence,
    required this.type,
    required this.address,
    required this.lat,
    required this.lng,
  });

  final int sequence;
  final String type;
  final String address;
  final double lat;
  final double lng;
}

class DriverBooking {
  const DriverBooking({
    required this.id,
    required this.trackingId,
    required this.status,
    required this.stops,
    required this.passengerFirstName,
    required this.quotedFareCents,
    required this.notes,
  });

  final String id;
  final String trackingId;
  final String status;
  final List<DriverBookingStop> stops;
  final String passengerFirstName;
  final int quotedFareCents;
  final String? notes;

  OfferPlace? get pickup {
    for (final stop in stops) {
      if (stop.type == 'PICKUP') {
        return OfferPlace(address: stop.address, lat: stop.lat, lng: stop.lng);
      }
    }
    if (stops.isEmpty) return null;
    final stop = stops.first;
    return OfferPlace(address: stop.address, lat: stop.lat, lng: stop.lng);
  }

  OfferPlace? get dropoff {
    for (final stop in stops.reversed) {
      if (stop.type == 'DROPOFF') {
        return OfferPlace(address: stop.address, lat: stop.lat, lng: stop.lng);
      }
    }
    if (stops.isEmpty) return null;
    final stop = stops.last;
    return OfferPlace(address: stop.address, lat: stop.lat, lng: stop.lng);
  }

  static DriverBooking? tryParse(Object? data) {
    final json = jsonMap(data);
    if (json == null) return null;
    final id = json['id'];
    final trackingId = json['trackingId'];
    final status = json['status'];
    final passengerFirstName = json['passengerFirstName'];
    final quotedFareCents = json['quotedFareCents'];
    final rawStops = json['stops'];
    if (id is! String ||
        trackingId is! String ||
        status is! String ||
        passengerFirstName is! String ||
        quotedFareCents is! int ||
        rawStops is! List) {
      return null;
    }
    final stops = <DriverBookingStop>[];
    for (final row in rawStops) {
      final map = jsonMap(row);
      if (map == null) continue;
      final sequence = map['sequence'];
      final type = map['type'];
      final address = map['address'];
      final lat = map['lat'];
      final lng = map['lng'];
      if (sequence is! int ||
          type is! String ||
          address is! String ||
          lat is! num ||
          lng is! num) {
        continue;
      }
      stops.add(
        DriverBookingStop(
          sequence: sequence,
          type: type,
          address: address,
          lat: lat.toDouble(),
          lng: lng.toDouble(),
        ),
      );
    }
    final notes = json['notes'];
    return DriverBooking(
      id: id,
      trackingId: trackingId,
      status: status,
      stops: stops,
      passengerFirstName: passengerFirstName,
      quotedFareCents: quotedFareCents,
      notes: notes is String ? notes : null,
    );
  }
}

class DriverSnapshot {
  const DriverSnapshot({
    required this.version,
    required this.status,
    required this.shiftStartedAt,
    required this.unitNumber,
    required this.booking,
    required this.offer,
  });

  final int version;
  final DriverStatus status;
  final DateTime? shiftStartedAt;
  final String? unitNumber;
  final DriverBooking? booking;
  final Offer? offer;

  bool get onShift => shiftStartedAt != null;

  DriverSnapshot copyWith({
    int? version,
    DriverStatus? status,
    DateTime? shiftStartedAt,
    String? unitNumber,
    DriverBooking? booking,
    Offer? offer,
    bool clearOffer = false,
    bool clearBooking = false,
  }) {
    return DriverSnapshot(
      version: version ?? this.version,
      status: status ?? this.status,
      shiftStartedAt: shiftStartedAt ?? this.shiftStartedAt,
      unitNumber: unitNumber ?? this.unitNumber,
      booking: clearBooking ? null : (booking ?? this.booking),
      offer: clearOffer ? null : (offer ?? this.offer),
    );
  }

  static DriverSnapshot? tryParse(Object? data) {
    final json = jsonMap(data);
    if (json == null) return null;
    final version = json['v'];
    final statusRaw = json['status'];
    if (version is! int || statusRaw is! String) return null;
    final shift = jsonMap(json['shift']);
    final vehicle = jsonMap(shift?['vehicle']);
    final started = shift?['startedAt'];
    final booking = DriverBooking.tryParse(json['booking']);
    final offer = Offer.tryParse(json['offer'], bookingId: booking?.id);
    return DriverSnapshot(
      version: version,
      status: DriverStatus.parse(statusRaw),
      shiftStartedAt: started is String ? DateTime.tryParse(started) : null,
      unitNumber: _text(vehicle?['unitNumber']),
      booking: booking,
      offer: offer,
    );
  }
}

DateTime? _date(Object? value) {
  if (value is! String) return null;
  return DateTime.tryParse(value)?.toUtc();
}

String? _text(Object? value) {
  if (value is String && value.isNotEmpty) return value;
  return null;
}
