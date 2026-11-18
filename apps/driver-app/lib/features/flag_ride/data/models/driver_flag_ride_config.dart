import 'driver_flag_edge_state.dart';
import 'driver_flag_quick_change.dart';
import 'driver_flag_ride_model.dart';

class DriverFlagRideConfig {
  // Screenshot 1: Start A Flag Ride Preset
  static const DriverFlagRideModel startFlagRidePreset = DriverFlagRideModel(
    flagTripId: 'FL-88214',
    unitNumber: 42,
    assignedVehicle: 'Medium (Camry Hybrid)',
    assignedCarId: 'Car #104 Assigned',
    gpsSignalLevel: 'HIGH',
    zone: 'Downtown Zone 1',
    pickupAddress: '524 4th Ave S, Downtown Lethbridge',
    dropoffAddress: '',
    passengerCount: 2,
    estimatedFareCad: 15.00,
    computedFareCad: 0.0,
    isMeterRunning: false,
  );

  // Screenshot 2: Flag Ride In Progress Preset
  static const DriverFlagRideModel flagInProgressPreset = DriverFlagRideModel(
    flagTripId: 'FL-88214',
    unitNumber: 42,
    assignedVehicle: 'Medium (Camry Hybrid)',
    assignedCarId: 'Car #104 Assigned',
    gpsSignalLevel: 'HIGH',
    zone: 'Lethbridge Downtown',
    pickupAddress: '524 4th Ave S, Downtown Lethbridge',
    dropoffAddress: '440 University Dr W',
    dropoffPostal: 'West Lethbridge, AB T1K 3M4',
    passengerCount: 2,
    estimatedFareCad: 15.00,
    computedFareCad: 12.40,
    tripProgressPercent: 57,
    distanceRemainingKm: 1.8,
    distanceTotalKm: 4.2,
    durationFormatted: '06:35',
    etaText: '~4 mins to West Side',
    currentSpeedKmh: 48,
    baseRateCad: 3.80,
    perKmRateCad: 1.85,
    isMeterRunning: true,
  );

  // Screenshot 3: Flag Ride Complete Preset
  static const DriverFlagRideModel flagCompletePreset = DriverFlagRideModel(
    flagTripId: 'FL-88214',
    unitNumber: 42,
    assignedVehicle: 'Medium (Camry Hybrid)',
    assignedCarId: 'Car #104 Assigned',
    gpsSignalLevel: 'HIGH',
    zone: 'Lethbridge Metro',
    pickupAddress: '524 4th Ave S (Downtown)',
    dropoffAddress: '440 University Dr W (West Camp...)',
    dropoffPostal: 'West Lethbridge, AB T1K 3M4',
    passengerCount: 2,
    estimatedFareCad: 15.00,
    computedFareCad: 18.60,
    subtotalMeterFare: 17.71,
    gstAlberta: 0.89,
    netEarning: 15.81,
    tripProgressPercent: 100,
    distanceRemainingKm: 0.0,
    distanceTotalKm: 4.2,
    durationMinutes: 12,
    durationFormatted: '12:00',
    etaText: 'Arrived',
    currentSpeedKmh: 0,
    isMeterRunning: false,
    isCashCollected: false,
    quickChangeOptions: [
      DriverFlagQuickChange(tenderAmount: 20.00, fareAmount: 18.60),
      DriverFlagQuickChange(tenderAmount: 25.00, fareAmount: 18.60),
    ],
  );

  // Screenshot 4: Flag Ride Edge States Preset
  static const DriverFlagRideModel edgeStatesPreset = DriverFlagRideModel(
    flagTripId: 'FL-88214',
    unitNumber: 42,
    edgeModel: DriverFlagEdgeModel(activeCategory: 1),
  );
}
