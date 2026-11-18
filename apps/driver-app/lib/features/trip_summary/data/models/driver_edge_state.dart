import 'package:equatable/equatable.dart';

enum DriverEdgeStateType {
  pendingVerification(
    'STATE 1 • PENDING VERIFICATION',
    'Terminal Sync',
    'Confirming cash on server...',
    'Validating \$18.78 against shift batch #84',
  ),
  successToast(
    'STATE 2 • SUCCESS TOAST',
    'Immediate Credit',
    'Payment confirmed',
    '\$18.78 credited to shift balance',
  ),
  networkError(
    'STATE 3 • NETWORK ERROR',
    '4042318 Alert',
    "Couldn't confirm payment",
    'Check network and try again. Fare record cached locally.',
  ),
  cardFailedCaution(
    'STATE 4 • AMBER CAUTION',
    'Customer Action Needed',
    "Card payment didn't go through",
    'The passenger will be asked to pay again on their terminal or switch method.',
  ),
  emergencySos(
    'STATE 5 • CRITICAL IN-RIDE SHEET',
    'Emergency SOS',
    'Send emergency alert?',
    'If you are in immediate danger, call 911. Activating dispatch alert will transmit live audio and coordinate with Lethbridge Police Service.',
  ),
  offlineQueue(
    'STATE 6 • OFFLINE QUEUE',
    'Auto-Sync Pending',
    "You're offline",
    "We'll sync your trip when you're back online. Shift ledger is protected.",
  );

  final String stateHeader;
  final String tag;
  final String title;
  final String message;

  const DriverEdgeStateType(
    this.stateHeader,
    this.tag,
    this.title,
    this.message,
  );
}

class DriverEdgeStateModel extends Equatable {
  final DriverEdgeStateType activeEdgeType;
  final bool isRetrying;

  const DriverEdgeStateModel({
    this.activeEdgeType = DriverEdgeStateType.pendingVerification,
    this.isRetrying = false,
  });

  DriverEdgeStateModel copyWith({
    DriverEdgeStateType? activeEdgeType,
    bool? isRetrying,
  }) {
    return DriverEdgeStateModel(
      activeEdgeType: activeEdgeType ?? this.activeEdgeType,
      isRetrying: isRetrying ?? this.isRetrying,
    );
  }

  @override
  List<Object?> get props => [activeEdgeType, isRetrying];
}
