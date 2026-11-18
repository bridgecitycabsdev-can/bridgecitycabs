import 'package:equatable/equatable.dart';
import '../../data/models/driver_search_models.dart';
import '../../data/models/searching_driver_config.dart';

class SearchingDriverState extends Equatable {
  final SearchingDriverStatus status;
  final SearchBookingDetails booking;
  final MatchedDriverInfo? driver;
  final int connectingSecondsRemaining;
  final bool isSubmittingCancel;
  final bool showCancelDialog;
  final bool isCopiedToClipboard;
  final bool isOnline;
  final int signalStrength;
  final String? errorMessage;
  final bool navigateToTracking;
  final bool navigateToHome;

  const SearchingDriverState({
    this.status = SearchingDriverStatus.searching,
    this.booking = const SearchBookingDetails(),
    this.driver,
    this.connectingSecondsRemaining = 2,
    this.isSubmittingCancel = false,
    this.showCancelDialog = false,
    this.isCopiedToClipboard = false,
    this.isOnline = true,
    this.signalStrength = 1,
    this.errorMessage,
    this.navigateToTracking = false,
    this.navigateToHome = false,
  });

  bool get isSearching => status == SearchingDriverStatus.searching;
  bool get isDriverFound => status == SearchingDriverStatus.driverFound;
  bool get isCancelling => status == SearchingDriverStatus.cancelling;
  bool get isCancelled => status == SearchingDriverStatus.cancelled;
  bool get isScheduled =>
      status == SearchingDriverStatus.scheduled || booking.isScheduled;
  bool get isReconnecting =>
      status == SearchingDriverStatus.reconnecting || !isOnline;

  String get title {
    if (isReconnecting) return SearchingDriverConfig.findingDriverTitle;
    switch (status) {
      case SearchingDriverStatus.driverFound:
        return SearchingDriverConfig.driverFoundTitle;
      case SearchingDriverStatus.cancelling:
        return SearchingDriverConfig.cancellingTitle;
      case SearchingDriverStatus.scheduled:
        return SearchingDriverConfig.rideScheduledTitle;
      case SearchingDriverStatus.searching:
      case SearchingDriverStatus.cancelled:
      case SearchingDriverStatus.reconnecting:
      case SearchingDriverStatus.noDriverFound:
        return SearchingDriverConfig.findingDriverTitle;
    }
  }

  String get subtitle {
    if (isReconnecting) return SearchingDriverConfig.reconnectingSubtitle;
    switch (status) {
      case SearchingDriverStatus.driverFound:
        return SearchingDriverConfig.driverFoundSubtitle;
      case SearchingDriverStatus.cancelling:
        return SearchingDriverConfig.cancellingSubtitle;
      case SearchingDriverStatus.scheduled:
        return SearchingDriverConfig.rideScheduledSubtitle;
      case SearchingDriverStatus.searching:
      case SearchingDriverStatus.cancelled:
      case SearchingDriverStatus.reconnecting:
      case SearchingDriverStatus.noDriverFound:
        return SearchingDriverConfig.findingDriverSubtitle;
    }
  }

  String get appBarTitle {
    if (isCancelling) return SearchingDriverConfig.appTitleDispatch;
    if (isDriverFound) return SearchingDriverConfig.appTitleDowntown;
    return SearchingDriverConfig.appTitleYql;
  }

  String get cancelButtonText {
    if (isCancelling) return SearchingDriverConfig.cancellingRideButton;
    if (isScheduled) return SearchingDriverConfig.cancelScheduledRideButton;
    return SearchingDriverConfig.cancelRideButton;
  }

  SearchingDriverState copyWith({
    SearchingDriverStatus? status,
    SearchBookingDetails? booking,
    MatchedDriverInfo? driver,
    int? connectingSecondsRemaining,
    bool? isSubmittingCancel,
    bool? showCancelDialog,
    bool? isCopiedToClipboard,
    bool? isOnline,
    int? signalStrength,
    String? errorMessage,
    bool? navigateToTracking,
    bool? navigateToHome,
  }) {
    return SearchingDriverState(
      status: status ?? this.status,
      booking: booking ?? this.booking,
      driver: driver ?? this.driver,
      connectingSecondsRemaining:
          connectingSecondsRemaining ?? this.connectingSecondsRemaining,
      isSubmittingCancel: isSubmittingCancel ?? this.isSubmittingCancel,
      showCancelDialog: showCancelDialog ?? this.showCancelDialog,
      isCopiedToClipboard: isCopiedToClipboard ?? this.isCopiedToClipboard,
      isOnline: isOnline ?? this.isOnline,
      signalStrength: signalStrength ?? this.signalStrength,
      errorMessage: errorMessage,
      navigateToTracking: navigateToTracking ?? this.navigateToTracking,
      navigateToHome: navigateToHome ?? this.navigateToHome,
    );
  }

  @override
  List<Object?> get props => [
        status,
        booking,
        driver,
        connectingSecondsRemaining,
        isSubmittingCancel,
        showCancelDialog,
        isCopiedToClipboard,
        isOnline,
        signalStrength,
        errorMessage,
        navigateToTracking,
        navigateToHome,
      ];
}
