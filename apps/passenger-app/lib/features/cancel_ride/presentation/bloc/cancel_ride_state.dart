import 'package:equatable/equatable.dart';
import '../../data/models/cancel_ride_config.dart';
import '../../data/models/cancel_ride_models.dart';

class CancelRideState extends Equatable {
  final CancelRideStatus status;
  final CancellationDetails details;
  final bool isSubmitting;
  final bool showSuccessBanner;
  final bool navigateBack;
  final bool navigateToHome;
  final bool navigateToTrip;

  const CancelRideState({
    this.status = CancelRideStatus.confirm,
    this.details = const CancellationDetails(),
    this.isSubmitting = false,
    this.showSuccessBanner = false,
    this.navigateBack = false,
    this.navigateToHome = false,
    this.navigateToTrip = false,
  });

  bool get isConfirm => status == CancelRideStatus.confirm;
  bool get isCancelling => status == CancelRideStatus.cancelling;
  bool get isCancelledSuccess => status == CancelRideStatus.cancelledSuccess;
  bool get isCannotCancel => status == CancelRideStatus.cannotCancel;

  String get title {
    switch (status) {
      case CancelRideStatus.cannotCancel:
        return CancelRideConfig.cannotCancelTitle;
      case CancelRideStatus.cancelledSuccess:
        return CancelRideConfig.cancelledSuccessTitle;
      case CancelRideStatus.confirm:
      case CancelRideStatus.cancelling:
        return CancelRideConfig.cancelTitle;
    }
  }

  String get subtitle {
    switch (status) {
      case CancelRideStatus.cannotCancel:
        return CancelRideConfig.cannotCancelSubtitle;
      case CancelRideStatus.cancelledSuccess:
        return CancelRideConfig.zeroPenaltySubtitle;
      case CancelRideStatus.confirm:
      case CancelRideStatus.cancelling:
        return CancelRideConfig.cancelSubtitle;
    }
  }

  CancelRideState copyWith({
    CancelRideStatus? status,
    CancellationDetails? details,
    bool? isSubmitting,
    bool? showSuccessBanner,
    bool? navigateBack,
    bool? navigateToHome,
    bool? navigateToTrip,
  }) {
    return CancelRideState(
      status: status ?? this.status,
      details: details ?? this.details,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      showSuccessBanner: showSuccessBanner ?? this.showSuccessBanner,
      navigateBack: navigateBack ?? this.navigateBack,
      navigateToHome: navigateToHome ?? this.navigateToHome,
      navigateToTrip: navigateToTrip ?? this.navigateToTrip,
    );
  }

  @override
  List<Object?> get props => [
        status,
        details,
        isSubmitting,
        showSuccessBanner,
        navigateBack,
        navigateToHome,
        navigateToTrip,
      ];
}
