import 'package:flutter/foundation.dart';

/// Call phase representing the lifecycle of the masked voice call
enum CallPhase {
  preCallPrompt, // Screen 1: Masked number protection dialog
  connecting,    // Screen 3: Establishing encrypted cab relay
  ringing,       // Screen 3: Ringing the driver
  connected,     // Screen 3: Audio relay live (with call timer)
  ended,         // Screen 3: Call terminated
  outcomeFallback, // Screen 4: Driver didn't answer / busy / error
}

/// Simulated QA outcomes for failed or missed calls (Screen 4)
enum CallOutcomeScenario {
  didntAnswer,
  driverBusy,
  connectionError,
}

extension CallOutcomeScenarioExtension on CallOutcomeScenario {
  String get badgeText {
    switch (this) {
      case CallOutcomeScenario.didntAnswer:
        return 'NO RESPONSE';
      case CallOutcomeScenario.driverBusy:
        return 'DRIVER BUSY';
      case CallOutcomeScenario.connectionError:
        return 'NETWORK TIMEOUT';
    }
  }

  String get title {
    switch (this) {
      case CallOutcomeScenario.didntAnswer:
        return "Michael didn't answer";
      case CallOutcomeScenario.driverBusy:
        return "Driver is currently unavailable";
      case CallOutcomeScenario.connectionError:
        return "Call could not connect";
    }
  }

  String get description {
    switch (this) {
      case CallOutcomeScenario.didntAnswer:
        return "Michael didn't answer. Try again in a moment, or watch the map as your driver approaches.";
      case CallOutcomeScenario.driverBusy:
        return "Michael is currently maneuvering traffic or on another line. Please try again shortly.";
      case CallOutcomeScenario.connectionError:
        return "Encrypted audio relay timed out. Check your mobile connection and try again.";
    }
  }
}

/// Driver and Vehicle metadata for the Call Driver flow
@immutable
class DriverCallDetails {
  final String driverId;
  final String firstName;
  final String fullName;
  final double rating;
  final String ratingCount;
  final String vehicleModel;
  final String vehicleColor;
  final String licensePlate;
  final String vehicleFleetNumber;
  final int etaMinutes;
  final bool isVerified;
  final String regulatedTitle;
  final String pickupAddress;
  final String pickupNote;

  const DriverCallDetails({
    required this.driverId,
    required this.firstName,
    required this.fullName,
    required this.rating,
    required this.ratingCount,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.licensePlate,
    required this.vehicleFleetNumber,
    required this.etaMinutes,
    this.isVerified = true,
    this.regulatedTitle = 'Lethbridge City Regulated Driver',
    this.pickupAddress = '440 University Dr W',
    this.pickupNote = 'Meet at South Entrance (near bus loop)',
  });

  static const DriverCallDetails defaultMichael = DriverCallDetails(
    driverId: 'drv_michael_104',
    firstName: 'Michael',
    fullName: 'Michael R.',
    rating: 4.94,
    ratingCount: '1.2k',
    vehicleModel: 'Toyota Camry SE',
    vehicleColor: 'Silver',
    licensePlate: 'BCF-402',
    vehicleFleetNumber: '#104',
    etaMinutes: 3,
    isVerified: true,
    regulatedTitle: 'Lethbridge City Regulated Driver',
    pickupAddress: '440 University Dr W',
    pickupNote: 'Meet at South Entrance (near bus loop)',
  );
}
