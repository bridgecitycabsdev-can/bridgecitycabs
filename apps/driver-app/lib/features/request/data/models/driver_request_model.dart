import 'package:equatable/equatable.dart';

class DriverRequestModel extends Equatable {
  final String id;
  final String cabUnit;
  final String title;
  final String subtitle;
  final bool isScheduled;
  final String? scheduledDateTimeText;
  final String? scheduledNotice;
  final double distanceKm;
  final int driveTimeMinutes;
  final String routeCorridor;
  final String pickupAddress;
  final String pickupLandmark;
  final String pickupEtaDistance;
  final String pickupZone;
  final String dropoffAddress;
  final String dropoffLandmark;
  final String dropoffEtaTime;
  final String dropoffZone;
  final double fareCad;
  final double baseRateCad;
  final String fareType;
  final String paymentMethod;
  final bool isPreAuthorized;
  final String vehicleClass;
  final String passengerName;
  final double passengerRating;
  final int? passengerTripsCount;
  final List<String> tags;
  final int acceptanceRate;
  final String acceptanceTier;
  final String acceptanceAdvice;
  final int totalTimeoutSeconds;
  final int remainingSeconds;
  final String audioAlertText;
  final bool isChimeActive;
  final bool isSimultaneousBroadcast;

  const DriverRequestModel({
    this.id = 'req_42_01',
    this.cabUnit = 'CAB #42',
    this.title = 'New ride request',
    this.subtitle = 'Instant local dispatch • Priority queue',
    this.isScheduled = false,
    this.scheduledDateTimeText,
    this.scheduledNotice,
    this.distanceKm = 4.52,
    this.driveTimeMinutes = 12,
    this.routeCorridor = 'Downtown to Southgate',
    this.pickupAddress = '440 University Dr W',
    this.pickupLandmark = 'Univ of Lethbridge Student Union',
    this.pickupEtaDistance = '3 min • 0.9 km away',
    this.pickupZone = 'Zone West',
    this.dropoffAddress = '501 1st Ave S',
    this.dropoffLandmark = 'Downtown Civic Centre, Lethbridge',
    this.dropoffEtaTime = 'Estimated arrival 14:48',
    this.dropoffZone = 'Downtown',
    this.fareCad = 15.00,
    this.baseRateCad = 4.25,
    this.fareType = 'Standard meter • incl. GST',
    this.paymentMethod = 'Cash on Arrival',
    this.isPreAuthorized = false,
    this.vehicleClass = 'Sedan • Medium',
    this.passengerName = 'Alex',
    this.passengerRating = 4.8,
    this.passengerTripsCount,
    this.tags = const ['Standard Ride', 'Immediate'],
    this.acceptanceRate = 50,
    this.acceptanceTier = 'POOR',
    this.acceptanceAdvice =
        'Accept more rides to improve rating and keep priority dispatch across downtown zones.',
    this.totalTimeoutSeconds = 15,
    this.remainingSeconds = 10,
    this.audioAlertText = 'AUDIO ALERT ACTIVE • LOUD CHIME',
    this.isChimeActive = true,
    this.isSimultaneousBroadcast = false,
  });

  DriverRequestModel copyWith({
    String? id,
    String? cabUnit,
    String? title,
    String? subtitle,
    bool? isScheduled,
    String? scheduledDateTimeText,
    String? scheduledNotice,
    double? distanceKm,
    int? driveTimeMinutes,
    String? routeCorridor,
    String? pickupAddress,
    String? pickupLandmark,
    String? pickupEtaDistance,
    String? pickupZone,
    String? dropoffAddress,
    String? dropoffLandmark,
    String? dropoffEtaTime,
    String? dropoffZone,
    double? fareCad,
    double? baseRateCad,
    String? fareType,
    String? paymentMethod,
    bool? isPreAuthorized,
    String? vehicleClass,
    String? passengerName,
    double? passengerRating,
    int? passengerTripsCount,
    List<String>? tags,
    int? acceptanceRate,
    String? acceptanceTier,
    String? acceptanceAdvice,
    int? totalTimeoutSeconds,
    int? remainingSeconds,
    String? audioAlertText,
    bool? isChimeActive,
    bool? isSimultaneousBroadcast,
  }) {
    return DriverRequestModel(
      id: id ?? this.id,
      cabUnit: cabUnit ?? this.cabUnit,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      isScheduled: isScheduled ?? this.isScheduled,
      scheduledDateTimeText:
          scheduledDateTimeText ?? this.scheduledDateTimeText,
      scheduledNotice: scheduledNotice ?? this.scheduledNotice,
      distanceKm: distanceKm ?? this.distanceKm,
      driveTimeMinutes: driveTimeMinutes ?? this.driveTimeMinutes,
      routeCorridor: routeCorridor ?? this.routeCorridor,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupLandmark: pickupLandmark ?? this.pickupLandmark,
      pickupEtaDistance: pickupEtaDistance ?? this.pickupEtaDistance,
      pickupZone: pickupZone ?? this.pickupZone,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      dropoffLandmark: dropoffLandmark ?? this.dropoffLandmark,
      dropoffEtaTime: dropoffEtaTime ?? this.dropoffEtaTime,
      dropoffZone: dropoffZone ?? this.dropoffZone,
      fareCad: fareCad ?? this.fareCad,
      baseRateCad: baseRateCad ?? this.baseRateCad,
      fareType: fareType ?? this.fareType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPreAuthorized: isPreAuthorized ?? this.isPreAuthorized,
      vehicleClass: vehicleClass ?? this.vehicleClass,
      passengerName: passengerName ?? this.passengerName,
      passengerRating: passengerRating ?? this.passengerRating,
      passengerTripsCount: passengerTripsCount ?? this.passengerTripsCount,
      tags: tags ?? this.tags,
      acceptanceRate: acceptanceRate ?? this.acceptanceRate,
      acceptanceTier: acceptanceTier ?? this.acceptanceTier,
      acceptanceAdvice: acceptanceAdvice ?? this.acceptanceAdvice,
      totalTimeoutSeconds: totalTimeoutSeconds ?? this.totalTimeoutSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      audioAlertText: audioAlertText ?? this.audioAlertText,
      isChimeActive: isChimeActive ?? this.isChimeActive,
      isSimultaneousBroadcast:
          isSimultaneousBroadcast ?? this.isSimultaneousBroadcast,
    );
  }

  @override
  List<Object?> get props => [
    id,
    cabUnit,
    title,
    subtitle,
    isScheduled,
    scheduledDateTimeText,
    scheduledNotice,
    distanceKm,
    driveTimeMinutes,
    routeCorridor,
    pickupAddress,
    pickupLandmark,
    pickupEtaDistance,
    pickupZone,
    dropoffAddress,
    dropoffLandmark,
    dropoffEtaTime,
    dropoffZone,
    fareCad,
    baseRateCad,
    fareType,
    paymentMethod,
    isPreAuthorized,
    vehicleClass,
    passengerName,
    passengerRating,
    passengerTripsCount,
    tags,
    acceptanceRate,
    acceptanceTier,
    acceptanceAdvice,
    totalTimeoutSeconds,
    remainingSeconds,
    audioAlertText,
    isChimeActive,
    isSimultaneousBroadcast,
  ];
}
