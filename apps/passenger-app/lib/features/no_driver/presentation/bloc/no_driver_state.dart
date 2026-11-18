import 'package:equatable/equatable.dart';
import '../../data/models/no_driver_config.dart';
import '../../data/models/no_driver_models.dart';

class NoDriverState extends Equatable {
  final NoDriverStatus status;
  final NoDriverBookingDetails booking;
  final int retryCount;
  final bool isAutoReconnecting;
  final bool isCopiedToClipboard;
  final bool showCancelDialog;
  final bool navigateToHome;
  final bool navigateToOptions;
  final bool navigateToTracking;

  const NoDriverState({
    this.status = NoDriverStatus.idle,
    this.booking = const NoDriverBookingDetails(),
    this.retryCount = 0,
    this.isAutoReconnecting = false,
    this.isCopiedToClipboard = false,
    this.showCancelDialog = false,
    this.navigateToHome = false,
    this.navigateToOptions = false,
    this.navigateToTracking = false,
  });

  bool get isIdle => status == NoDriverStatus.idle;
  bool get isRetrySearching => status == NoDriverStatus.retrySearching;
  bool get isStillNoDriver => status == NoDriverStatus.stillNoDriver;
  bool get isCancelling => status == NoDriverStatus.cancelling;
  bool get isCancelled => status == NoDriverStatus.cancelled;

  String get title {
    if (isCancelling) return NoDriverConfig.cancellingTitle;
    return NoDriverConfig.noDriverTitle;
  }

  String get subtitle {
    if (isCancelling) return NoDriverConfig.cancellingSubtitle;
    return NoDriverConfig.noDriverSubtitle;
  }

  String get appBarTitle {
    if (isAutoReconnecting) return NoDriverConfig.appTitleReconnecting;
    return NoDriverConfig.appTitleDispatch;
  }

  String get actionButtonText {
    if (isCancelling) return NoDriverConfig.cancellingRideButton;
    if (isRetrySearching) return NoDriverConfig.searchingButton;
    return NoDriverConfig.tryAgainButton;
  }

  bool get showBackArrow => isStillNoDriver;

  NoDriverState copyWith({
    NoDriverStatus? status,
    NoDriverBookingDetails? booking,
    int? retryCount,
    bool? isAutoReconnecting,
    bool? isCopiedToClipboard,
    bool? showCancelDialog,
    bool? navigateToHome,
    bool? navigateToOptions,
    bool? navigateToTracking,
  }) {
    return NoDriverState(
      status: status ?? this.status,
      booking: booking ?? this.booking,
      retryCount: retryCount ?? this.retryCount,
      isAutoReconnecting: isAutoReconnecting ?? this.isAutoReconnecting,
      isCopiedToClipboard: isCopiedToClipboard ?? this.isCopiedToClipboard,
      showCancelDialog: showCancelDialog ?? this.showCancelDialog,
      navigateToHome: navigateToHome ?? this.navigateToHome,
      navigateToOptions: navigateToOptions ?? this.navigateToOptions,
      navigateToTracking: navigateToTracking ?? this.navigateToTracking,
    );
  }

  @override
  List<Object?> get props => [
        status,
        booking,
        retryCount,
        isAutoReconnecting,
        isCopiedToClipboard,
        showCancelDialog,
        navigateToHome,
        navigateToOptions,
        navigateToTracking,
      ];
}
