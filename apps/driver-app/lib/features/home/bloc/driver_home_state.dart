import 'package:equatable/equatable.dart';
import '../data/models/driver_home_metrics.dart';
import '../data/models/driver_home_status.dart';
import '../data/models/driver_incoming_offer.dart';
import '../data/models/driver_shift_mode.dart';
import '../data/models/driver_surge_zone.dart';
import '../data/models/driver_verification_item.dart';

class DriverHomeState extends Equatable {
  final DriverHomeStatus status;
  final DriverShiftMode shiftMode;
  final DriverHomeMetrics metrics;
  final DriverSurgeZone surgeZone;
  final DriverIncomingOffer incomingOffer;
  final List<DriverVerificationItem> verificationItems;
  final bool isDarkMode;
  final bool isActionLoading;
  final String? feedbackMessage;

  const DriverHomeState({
    this.status = DriverHomeStatus.offline,
    this.shiftMode = DriverShiftMode.active,
    this.metrics = const DriverHomeMetrics(),
    this.surgeZone = const DriverSurgeZone(),
    this.incomingOffer = const DriverIncomingOffer(),
    this.verificationItems = const [
      DriverVerificationItem(
        title: "Driver's License (Class 4)",
        subtitle: 'AB License • Expiry 2027',
        status: VerificationItemStatus.verified,
        tagText: 'VERIFIED',
      ),
      DriverVerificationItem(
        title: 'Vehicle Registration',
        subtitle: 'Toyota Camry • Plate CAB-42',
        status: VerificationItemStatus.underReview,
        tagText: 'UNDER REVIEW',
      ),
      DriverVerificationItem(
        title: 'City Mechanical Inspection',
        subtitle: 'Annual Certificate of Mechanical Fitness',
        status: VerificationItemStatus.pending,
        tagText: 'PENDING',
      ),
    ],
    this.isDarkMode = false,
    this.isActionLoading = false,
    this.feedbackMessage,
  });

  bool get isOffline => status == DriverHomeStatus.offline;
  bool get isOnlineSearching => status == DriverHomeStatus.onlineSearching;
  bool get isLocationOff => status == DriverHomeStatus.locationOff;
  bool get isShiftAway => status == DriverHomeStatus.shiftAway;
  bool get isNetworkOffline => status == DriverHomeStatus.networkOffline;
  bool get isIncomingOffer => status == DriverHomeStatus.incomingOffer;
  bool get isAccountPending => status == DriverHomeStatus.accountPending;

  DriverHomeState copyWith({
    DriverHomeStatus? status,
    DriverShiftMode? shiftMode,
    DriverHomeMetrics? metrics,
    DriverSurgeZone? surgeZone,
    DriverIncomingOffer? incomingOffer,
    List<DriverVerificationItem>? verificationItems,
    bool? isDarkMode,
    bool? isActionLoading,
    String? feedbackMessage,
  }) {
    return DriverHomeState(
      status: status ?? this.status,
      shiftMode: shiftMode ?? this.shiftMode,
      metrics: metrics ?? this.metrics,
      surgeZone: surgeZone ?? this.surgeZone,
      incomingOffer: incomingOffer ?? this.incomingOffer,
      verificationItems: verificationItems ?? this.verificationItems,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      feedbackMessage: feedbackMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        shiftMode,
        metrics,
        surgeZone,
        incomingOffer,
        verificationItems,
        isDarkMode,
        isActionLoading,
        feedbackMessage,
      ];
}
