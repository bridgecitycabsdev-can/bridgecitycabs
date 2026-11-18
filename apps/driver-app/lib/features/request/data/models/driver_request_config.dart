import 'driver_acceptance_impact.dart';
import 'driver_dispatch_queue_info.dart';
import 'driver_request_model.dart';
import 'driver_request_status.dart';

class DriverRequestConfig {
  const DriverRequestConfig._();

  static DriverRequestModel instantPreset() {
    return const DriverRequestModel(
      id: 'req_leth_001',
      cabUnit: 'CAB #42',
      title: 'New ride request',
      subtitle: 'Instant local dispatch • Priority queue',
      isScheduled: false,
      distanceKm: 4.52,
      driveTimeMinutes: 12,
      routeCorridor: 'Downtown to Southgate',
      pickupAddress: '440 University Dr W',
      pickupLandmark: 'Univ of Lethbridge Student Union',
      pickupEtaDistance: '3 min • 0.9 km away',
      pickupZone: 'Zone West',
      dropoffAddress: '501 1st Ave S',
      dropoffLandmark: 'Downtown Civic Centre, Lethbridge',
      dropoffEtaTime: 'Estimated arrival 14:48',
      dropoffZone: 'Downtown',
      fareCad: 15.00,
      baseRateCad: 4.25,
      fareType: 'Standard meter • incl. GST',
      paymentMethod: 'Cash on Arrival',
      isPreAuthorized: false,
      vehicleClass: 'Sedan • Medium',
      passengerName: 'Alex',
      passengerRating: 4.8,
      tags: ['Standard Ride', 'Immediate'],
      acceptanceRate: 50,
      acceptanceTier: 'POOR',
      acceptanceAdvice:
          'Accept more rides to improve rating and keep priority dispatch across downtown zones.',
      totalTimeoutSeconds: 15,
      remainingSeconds: 10,
      audioAlertText: 'AUDIO ALERT ACTIVE • LOUD CHIME',
      isChimeActive: true,
      isSimultaneousBroadcast: false,
    );
  }

  static DriverRequestModel urgentPreset() {
    return const DriverRequestModel(
      id: 'req_leth_001_urgent',
      cabUnit: 'CAB #42',
      title: 'New ride request',
      subtitle: 'Standard in-cab metered dispatch',
      isScheduled: false,
      distanceKm: 4.52,
      driveTimeMinutes: 12,
      routeCorridor: 'Downtown to Southgate',
      pickupAddress: '440 University Dr W, Lethbridge',
      pickupLandmark: 'Near 1st Ave Campus transit loop',
      pickupEtaDistance: '3 min away • 0.9 km',
      pickupZone: 'Zone West',
      dropoffAddress: '501 1st Ave S, Lethbridge',
      dropoffLandmark: 'Downtown Commercial District',
      dropoffEtaTime: 'Estimated arrival 14:48',
      dropoffZone: 'Downtown Commercial District',
      fareCad: 15.00,
      baseRateCad: 4.25,
      fareType: 'Incl. GST',
      paymentMethod: 'Cash',
      isPreAuthorized: false,
      vehicleClass: 'Sedan • Medium',
      passengerName: 'Alex',
      passengerRating: 4.8,
      tags: ['Quick Pickup', '1 Bag'],
      acceptanceRate: 50,
      acceptanceTier: 'POOR',
      acceptanceAdvice:
          'Accept more rides to improve rating and keep priority dispatch across downtown zones.',
      totalTimeoutSeconds: 15,
      remainingSeconds: 2,
      audioAlertText: 'HURRY! OFFER EXPIRING IN 4S',
      isChimeActive: true,
      isSimultaneousBroadcast: false,
    );
  }

  static DriverRequestModel scheduledPreset() {
    return const DriverRequestModel(
      id: 'req_sched_yql_09',
      cabUnit: 'CAB #42',
      title: 'Scheduled ride request',
      subtitle: 'NEW DISPATCH',
      isScheduled: true,
      scheduledDateTimeText: 'Pickup at Fri, 3:30 PM (Scheduled)',
      scheduledNotice:
          'Advance reservation • Arrive 5 min before pickup time',
      distanceKm: 8.40,
      driveTimeMinutes: 18,
      routeCorridor: 'Scenic High Level Bridge Corridor',
      pickupAddress: '920 2A Ave N, Lethbridge',
      pickupLandmark: 'Senator Buchanan Zone',
      pickupEtaDistance: 'Advance Booking',
      pickupZone: 'Senator Buchanan',
      dropoffAddress: 'Lethbridge Airport (YQL)',
      dropoffLandmark: 'Terminal Dr, Lethbridge County',
      dropoffEtaTime: 'Scheduled Dropoff',
      dropoffZone: 'Lethbridge County',
      fareCad: 34.50,
      baseRateCad: 8.50,
      fareType: 'Incl. GST & airport fee',
      paymentMethod: 'Card on file',
      isPreAuthorized: true,
      vehicleClass: 'SUV • Luggage Ready',
      passengerName: 'Sarah',
      passengerRating: 4.9,
      tags: [
        'Scheduled • Fri 3:30 PM',
        'Van only',
        'Airport run',
        'Sarah • 4.9 ★',
      ],
      acceptanceRate: 50,
      acceptanceTier: 'GOOD FOR SHIFT',
      acceptanceAdvice:
          'Good for shift planning • Stays on your schedule',
      totalTimeoutSeconds: 15,
      remainingSeconds: 12,
      audioAlertText: 'SCHEDULED BOOKING • ADVANCE',
      isChimeActive: false,
      isSimultaneousBroadcast: false,
    );
  }

  static DriverRequestModel declineTargetPreset() {
    return const DriverRequestModel(
      id: 'req_jordan_104',
      cabUnit: 'CAB #104',
      title: 'New ride request',
      subtitle: 'ONLINE • ZONE 4 (WEST LETHBRIDGE)',
      isScheduled: false,
      distanceKm: 4.52,
      driveTimeMinutes: 9,
      routeCorridor: 'Whoop-Up Drive Corridor',
      pickupAddress: 'University Campus Loop',
      pickupLandmark: 'Pickup: 6 mins away',
      pickupEtaDistance: '6 mins away',
      pickupZone: 'West Lethbridge',
      dropoffAddress: 'Park Place Mall',
      dropoffLandmark: 'Downtown Lethbridge',
      dropoffEtaTime: 'Est. Time 9 mins',
      dropoffZone: 'Park Place',
      fareCad: 15.00,
      baseRateCad: 4.25,
      fareType: 'Standard Fare',
      paymentMethod: 'Cash',
      isPreAuthorized: false,
      vehicleClass: 'Standard Sedan',
      passengerName: 'Jordan S.',
      passengerRating: 4.92,
      passengerTripsCount: 114,
      tags: ['Standard Sedan'],
      acceptanceRate: 50,
      acceptanceTier: 'POOR',
      acceptanceAdvice: 'Drivers with higher acceptance receive priority.',
      totalTimeoutSeconds: 15,
      remainingSeconds: 5,
      audioAlertText: 'ACCEPTANCE ALERT',
      isChimeActive: true,
      isSimultaneousBroadcast: false,
    );
  }

  static DriverAcceptanceImpact declineImpact() {
    return const DriverAcceptanceImpact(
      currentRate: 50,
      projectedRate: 48,
      penaltyPercent: -2,
      ratingTier: 'Poor',
      rollingWindow: 'Rolling 100 trips',
      targetAdvice:
          'Declining or letting requests expire lowers your acceptance rate. Drivers with higher acceptance rates receive dispatch priority and advance scheduled bookings across Lethbridge.',
    );
  }

  static DriverAcceptanceImpact expiredImpact() {
    return const DriverAcceptanceImpact(
      currentRate: 50,
      projectedRate: 49,
      penaltyPercent: -1,
      ratingTier: 'Poor',
      rollingWindow: 'Rolling 100 trips',
      targetAdvice:
          'Keep your acceptance rate above 85% for priority trips',
    );
  }

  static DriverDispatchQueueInfo takenQueueInfo() {
    return const DriverDispatchQueueInfo(
      broadcastId: '#8429',
      broadcastZone: 'Lethbridge Central',
      winningUnit: 'Unit 18 in Downtown Lethbridge',
      queuePosition: 1,
      queueStatus: 'STANDBY • POS 1',
      responseTime: '1.4s (High Priority)',
      areaDemand: 'High Surge (Downtown)',
      autoReturnSeconds: 4,
    );
  }
}
