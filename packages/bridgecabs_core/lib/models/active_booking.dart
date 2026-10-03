import '../http/json_map.dart';

const _searchingStatuses = {
  'SCHEDULED',
  'CREATED',
  'SEARCHING_DRIVER',
  'MATCHED',
  'NO_DRIVER_FOUND',
};

const _trackingStatuses = {
  'DRIVER_ASSIGNED',
  'DRIVER_ARRIVING',
  'DRIVER_ARRIVED',
  'TRIP_STARTED',
};

const _terminalStatuses = {
  'TRIP_COMPLETED',
  'PAYMENT_PENDING',
  'PAYMENT_COMPLETED',
  'CLOSED',
  'CANCELLED',
};

const _cancelableStatuses = {
  'SCHEDULED',
  'CREATED',
  'SEARCHING_DRIVER',
  'MATCHED',
  'NO_DRIVER_FOUND',
  'DRIVER_ASSIGNED',
  'DRIVER_ARRIVING',
  'DRIVER_ARRIVED',
};

class BookingStop {
  const BookingStop({
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

  static BookingStop? tryParse(Object? data) {
    final json = jsonMap(data);
    if (json == null) return null;
    final sequence = json['sequence'];
    final type = json['type'];
    final address = json['address'];
    final lat = json['lat'];
    final lng = json['lng'];
    if (sequence is! int ||
        type is! String ||
        address is! String ||
        lat is! num ||
        lng is! num) {
      return null;
    }
    return BookingStop(
      sequence: sequence,
      type: type,
      address: address,
      lat: lat.toDouble(),
      lng: lng.toDouble(),
    );
  }
}

class PassengerVehicle {
  const PassengerVehicle({
    required this.make,
    required this.model,
    required this.plate,
    this.colour,
    this.unitNumber,
  });

  final String make;
  final String model;
  final String? colour;
  final String plate;
  final String? unitNumber;

  static PassengerVehicle? tryParse(Object? data) {
    final json = jsonMap(data);
    if (json == null) return null;
    final make = json['make'];
    final model = json['model'];
    final plate = json['plate'];
    if (make is! String || model is! String || plate is! String) return null;
    final colour = json['colour'];
    final unitNumber = json['unitNumber'];
    return PassengerVehicle(
      make: make,
      model: model,
      colour: colour is String ? colour : null,
      plate: plate,
      unitNumber: unitNumber is String ? unitNumber : null,
    );
  }
}

class PassengerDriver {
  const PassengerDriver({
    required this.firstName,
    required this.rating,
    this.vehicle,
  });

  final String firstName;
  final double rating;
  final PassengerVehicle? vehicle;

  static PassengerDriver? tryParse(Object? data) {
    final json = jsonMap(data);
    if (json == null) return null;
    final firstName = json['firstName'];
    final rating = json['rating'];
    if (firstName is! String || rating is! num) return null;
    return PassengerDriver(
      firstName: firstName,
      rating: rating.toDouble(),
      vehicle: PassengerVehicle.tryParse(json['vehicle']),
    );
  }
}

class ActiveBooking {
  const ActiveBooking({
    required this.id,
    required this.trackingId,
    required this.status,
    required this.etaSeconds,
    required this.quotedFareCents,
    required this.quotedTaxCents,
    required this.passengerName,
    required this.vehicleTypeId,
    required this.vehicleTypeName,
    required this.stops,
    this.scheduledAt,
    this.notes,
    this.driver,
  });

  final String id;
  final String trackingId;
  final String status;
  final int? etaSeconds;
  final String? scheduledAt;
  final int quotedFareCents;
  final int quotedTaxCents;
  final String? notes;
  final String passengerName;
  final String vehicleTypeId;
  final String vehicleTypeName;
  final List<BookingStop> stops;
  final PassengerDriver? driver;

  String? get pickupAddress {
    for (final stop in stops) {
      if (stop.type == 'PICKUP') return stop.address;
    }
    return stops.isEmpty ? null : stops.first.address;
  }

  String? get dropoffAddress {
    for (final stop in stops.reversed) {
      if (stop.type == 'DROPOFF') return stop.address;
    }
    return stops.length < 2 ? null : stops.last.address;
  }

  bool get isTerminal => _terminalStatuses.contains(status);

  bool get isSearching => _searchingStatuses.contains(status);

  bool get isTracking => _trackingStatuses.contains(status);

  /// Non-terminal bookings occupy the passenger and drive router redirects.
  bool get isLive => !isTerminal;

  bool get canCancel => _cancelableStatuses.contains(status);

  bool get noDriverFound => status == 'NO_DRIVER_FOUND';

  static ActiveBooking? tryParse(Object? data) {
    final json = jsonMap(data);
    if (json == null) return null;
    final id = json['id'];
    final trackingId = json['trackingId'];
    final status = json['status'];
    final quotedFareCents = json['quotedFareCents'];
    final quotedTaxCents = json['quotedTaxCents'];
    final passengerName = json['passengerName'];
    final vehicleType = jsonMap(json['vehicleType']);
    if (id is! String ||
        trackingId is! String ||
        status is! String ||
        quotedFareCents is! int ||
        quotedTaxCents is! int ||
        passengerName is! String ||
        vehicleType == null) {
      return null;
    }
    final vehicleTypeId = vehicleType['id'];
    final vehicleTypeName = vehicleType['name'];
    if (vehicleTypeId is! String || vehicleTypeName is! String) return null;

    final eta = json['etaSeconds'];
    final scheduledAt = json['scheduledAt'];
    final notes = json['notes'];
    final rawStops = json['stops'];
    final stops = <BookingStop>[];
    if (rawStops is List) {
      for (final row in rawStops) {
        final stop = BookingStop.tryParse(row);
        if (stop != null) stops.add(stop);
      }
    }

    return ActiveBooking(
      id: id,
      trackingId: trackingId,
      status: status,
      etaSeconds: eta is int ? eta : null,
      scheduledAt: scheduledAt is String ? scheduledAt : null,
      quotedFareCents: quotedFareCents,
      quotedTaxCents: quotedTaxCents,
      notes: notes is String ? notes : null,
      passengerName: passengerName,
      vehicleTypeId: vehicleTypeId,
      vehicleTypeName: vehicleTypeName,
      stops: stops,
      driver: PassengerDriver.tryParse(json['driver']),
    );
  }
}

class DriverLocationPing {
  const DriverLocationPing({
    required this.bookingId,
    required this.lat,
    required this.lng,
    this.heading,
    this.ts,
  });

  final String bookingId;
  final double lat;
  final double lng;
  final double? heading;
  final int? ts;

  static DriverLocationPing? tryParse(Object? data) {
    final json = jsonMap(data);
    if (json == null) return null;
    final bookingId = json['bookingId'];
    final lat = json['lat'];
    final lng = json['lng'];
    if (bookingId is! String || lat is! num || lng is! num) return null;
    final heading = json['heading'];
    final ts = json['ts'];
    return DriverLocationPing(
      bookingId: bookingId,
      lat: lat.toDouble(),
      lng: lng.toDouble(),
      heading: heading is num ? heading.toDouble() : null,
      ts: ts is int ? ts : null,
    );
  }
}
