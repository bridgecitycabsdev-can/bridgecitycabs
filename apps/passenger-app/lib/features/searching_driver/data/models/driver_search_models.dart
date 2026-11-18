import 'package:equatable/equatable.dart';

enum SearchingDriverStatus {
  searching,
  driverFound,
  cancelling,
  cancelled,
  scheduled,
  reconnecting,
  noDriverFound,
}

class SearchBookingDetails extends Equatable {
  final String trackingId;
  final String pickupAddress;
  final String dropoffAddress;
  final String? dropoffEntrance;
  final String vehicleTier;
  final int seats;
  final String paymentMethodText;
  final double fareAmountCad;
  final String? fareLabel;
  final bool isScheduled;
  final String? scheduledDateTime;
  final String? scheduledDayText;
  final String? scheduledDispatchNotice;
  final bool pickupConfirmed;

  const SearchBookingDetails({
    this.trackingId = 'BC-123456',
    this.pickupAddress = '515 5th Ave S, Downtown',
    this.dropoffAddress = 'Park Place Mall',
    this.dropoffEntrance = 'Main Entrance (North Bay)',
    this.vehicleTier = 'SUV • Big',
    this.seats = 6,
    this.paymentMethodText = '•••• 4242',
    this.fareAmountCad = 22.10,
    this.fareLabel,
    this.isScheduled = false,
    this.scheduledDateTime,
    this.scheduledDayText,
    this.scheduledDispatchNotice,
    this.pickupConfirmed = false,
  });

  String get formattedFare => '\$${fareAmountCad.toStringAsFixed(2)} CAD';

  String get fullDropoffText {
    if (dropoffEntrance != null && dropoffEntrance!.isNotEmpty) {
      return '$dropoffAddress ($dropoffEntrance)';
    }
    return dropoffAddress;
  }

  SearchBookingDetails copyWith({
    String? trackingId,
    String? pickupAddress,
    String? dropoffAddress,
    String? dropoffEntrance,
    String? vehicleTier,
    int? seats,
    String? paymentMethodText,
    double? fareAmountCad,
    String? fareLabel,
    bool? isScheduled,
    String? scheduledDateTime,
    String? scheduledDayText,
    String? scheduledDispatchNotice,
    bool? pickupConfirmed,
  }) {
    return SearchBookingDetails(
      trackingId: trackingId ?? this.trackingId,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      dropoffEntrance: dropoffEntrance ?? this.dropoffEntrance,
      vehicleTier: vehicleTier ?? this.vehicleTier,
      seats: seats ?? this.seats,
      paymentMethodText: paymentMethodText ?? this.paymentMethodText,
      fareAmountCad: fareAmountCad ?? this.fareAmountCad,
      fareLabel: fareLabel ?? this.fareLabel,
      isScheduled: isScheduled ?? this.isScheduled,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      scheduledDayText: scheduledDayText ?? this.scheduledDayText,
      scheduledDispatchNotice:
          scheduledDispatchNotice ?? this.scheduledDispatchNotice,
      pickupConfirmed: pickupConfirmed ?? this.pickupConfirmed,
    );
  }

  @override
  List<Object?> get props => [
        trackingId,
        pickupAddress,
        dropoffAddress,
        dropoffEntrance,
        vehicleTier,
        seats,
        paymentMethodText,
        fareAmountCad,
        fareLabel,
        isScheduled,
        scheduledDateTime,
        scheduledDayText,
        scheduledDispatchNotice,
        pickupConfirmed,
      ];
}

class MatchedDriverInfo extends Equatable {
  final String driverId;
  final String name;
  final double rating;
  final String vehicleModel;
  final String licensePlate;
  final String phone;
  final String? photoUrl;
  final int etaMinutes;

  const MatchedDriverInfo({
    required this.driverId,
    required this.name,
    required this.rating,
    required this.vehicleModel,
    required this.licensePlate,
    required this.phone,
    this.photoUrl,
    this.etaMinutes = 3,
  });

  static const sample = MatchedDriverInfo(
    driverId: 'drv-771',
    name: 'Harpreet Singh',
    rating: 4.94,
    vehicleModel: 'Black Toyota Highlander Hybrid',
    licensePlate: 'BC-YQL-88',
    phone: '403-555-0199',
    etaMinutes: 3,
  );

  @override
  List<Object?> get props => [
        driverId,
        name,
        rating,
        vehicleModel,
        licensePlate,
        phone,
        photoUrl,
        etaMinutes,
      ];
}
