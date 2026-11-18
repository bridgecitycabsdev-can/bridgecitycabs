import 'package:equatable/equatable.dart';

enum DriverDeleteSafeguardBlockType {
  tripActive,
  unpaidBalance,
  openDisputes,
  equipmentHold,
  bylawLock;

  String get label {
    switch (this) {
      case DriverDeleteSafeguardBlockType.tripActive:
        return '1. Trip active';
      case DriverDeleteSafeguardBlockType.unpaidBalance:
        return '2. Unpaid balance';
      case DriverDeleteSafeguardBlockType.openDisputes:
        return '3. Open disputes';
      case DriverDeleteSafeguardBlockType.equipmentHold:
        return '4. Equipment hold';
      case DriverDeleteSafeguardBlockType.bylawLock:
        return '5. Bylaw lock';
    }
  }
}

class DriverDeleteSafeguardBlock extends Equatable {
  final DriverDeleteSafeguardBlockType type;
  final String tag;
  final String cabUnit;
  final String title;
  final String description;
  final String? passengerName;
  final bool isMeterRunning;
  final String? pickupLocation;
  final String? dropoffLocation;
  final double? fareEstimate;
  final String? etaMinutes;
  final String actionButtonText;

  const DriverDeleteSafeguardBlock({
    required this.type,
    required this.tag,
    required this.cabUnit,
    required this.title,
    required this.description,
    this.passengerName,
    this.isMeterRunning = false,
    this.pickupLocation,
    this.dropoffLocation,
    this.fareEstimate,
    this.etaMinutes,
    required this.actionButtonText,
  });

  @override
  List<Object?> get props => [
        type,
        tag,
        cabUnit,
        title,
        description,
        passengerName,
        isMeterRunning,
        pickupLocation,
        dropoffLocation,
        fareEstimate,
        etaMinutes,
        actionButtonText,
      ];
}
