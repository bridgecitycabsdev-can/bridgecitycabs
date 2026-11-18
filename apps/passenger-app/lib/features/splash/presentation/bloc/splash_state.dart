import 'package:equatable/equatable.dart';
import '../../data/models/splash_config.dart';

/// Enum representing the primary splash UI states shown in the designs.
enum SplashStatus {
  /// Initial uninitialized state.
  initial,

  /// Screen 1: Default connecting state with trust badge and normal spinner.
  loading,

  /// Screen 2: Slow connection / low signal detected, "Still connecting..." amber badge.
  slowConnection,

  /// Screen 3: Connection interrupted / offline error with white modal card.
  connectionInterrupted,

  /// App bootstrap completed, ready to navigate to next screen.
  success,
}

/// Base abstract class for SplashState.
abstract class SplashState extends Equatable {
  final SplashStatus status;
  final int retryCount;

  const SplashState({
    required this.status,
    this.retryCount = 0,
  });

  bool get isInitial => status == SplashStatus.initial;
  bool get isLoading => status == SplashStatus.loading;
  bool get isSlowConnection => status == SplashStatus.slowConnection;
  bool get isConnectionInterrupted =>
      status == SplashStatus.connectionInterrupted;
  bool get isSuccess => status == SplashStatus.success;

  @override
  List<Object?> get props => [status, retryCount];
}

/// Screen 0: Initial state before bootstrap begins.
class SplashInitial extends SplashState {
  const SplashInitial() : super(status: SplashStatus.initial);
}

/// Screen 1 (First uploaded screenshot):
/// - Full crimson gradient background
/// - Bridge City Cabs steering wheel logo and tagline
/// - "Southern Alberta's Trusted Choice" verified pill badge
/// - Moving cab on curved road illustration
/// - Sleek white circular progress indicator
/// - "• LETHBRIDGE, ALBERTA" with bottom bridge trestle silhouette
class SplashLoading extends SplashState {
  final String region;
  final String trustBadge;

  const SplashLoading({
    super.retryCount,
    this.region = SplashConfig.cityRegion,
    this.trustBadge = SplashConfig.trustedBadgeText,
  }) : super(status: SplashStatus.loading);

  @override
  List<Object?> get props => [status, retryCount, region, trustBadge];
}

/// Screen 2 (Second uploaded screenshot):
/// - Top bar: "● Low Signal" amber capsule
/// - Bridge City Cabs steering wheel logo and tagline
/// - Moving cab on curved road illustration
/// - Sleek white circular progress indicator
/// - Amber pill: "● Still connecting..."
/// - "LETHBRIDGE, ALBERTA"
/// - Notice below city: "Reconnecting to fleet dispatch"
/// - Bottom bridge trestle silhouette
class SplashSlowConnection extends SplashState {
  final String signalNotice;
  final String dispatchNotice;
  final String region;

  const SplashSlowConnection({
    super.retryCount,
    this.signalNotice = SplashConfig.lowSignalPill,
    this.dispatchNotice = SplashConfig.reconnectingDispatchNotice,
    this.region = SplashConfig.cityRegion,
  }) : super(status: SplashStatus.slowConnection);

  @override
  List<Object?> get props => [
        status,
        retryCount,
        signalNotice,
        dispatchNotice,
        region,
      ];
}

/// Screen 3 (Third uploaded screenshot):
/// - Top bar: "● Offline" red capsule on left, "SEARCHING SIGNAL" on right
/// - Bridge City Cabs steering wheel logo in background
/// - Prominent white rounded modal card:
///   * Red circular icon with crossed-out signal/wifi
///   * "Connection Interrupted" title
///   * "Couldn't connect. Check your internet and try again." description
///   * "Try again" primary black pill button
///   * "Need a cab urgently? Call 403-555-CABS →" card
/// - "📍 LETHBRIDGE, ALBERTA" with bridge silhouette behind card
class SplashConnectionInterrupted extends SplashState {
  final String title;
  final String message;
  final String hotlineNumber;
  final bool isOffline;

  const SplashConnectionInterrupted({
    super.retryCount,
    this.title = SplashConfig.errorTitle,
    this.message = SplashConfig.errorSubtitle,
    this.hotlineNumber = SplashConfig.urgentCabPhoneDisplay,
    this.isOffline = true,
  }) : super(status: SplashStatus.connectionInterrupted);

  @override
  List<Object?> get props => [
        status,
        retryCount,
        title,
        message,
        hotlineNumber,
        isOffline,
      ];
}

/// Terminal state: Initialization succeeded, triggers navigation.
class SplashSuccess extends SplashState {
  final bool isAuthenticated;
  final String destinationRoute;

  const SplashSuccess({
    required this.isAuthenticated,
    required this.destinationRoute,
    super.retryCount,
  }) : super(status: SplashStatus.success);

  @override
  List<Object?> get props => [
        status,
        retryCount,
        isAuthenticated,
        destinationRoute,
      ];
}
