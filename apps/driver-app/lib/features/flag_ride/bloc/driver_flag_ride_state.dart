import 'package:equatable/equatable.dart';
import '../data/models/driver_flag_ride_config.dart';
import '../data/models/driver_flag_ride_model.dart';
import '../data/models/driver_flag_ride_status.dart';

class DriverFlagRideState extends Equatable {
  final DriverFlagRideStatus status;
  final DriverFlagRideModel ride;
  final bool isLoading;
  final String? errorMessage;
  final String? toastMessage;
  final bool isReturnedToHome;

  const DriverFlagRideState({
    required this.status,
    required this.ride,
    this.isLoading = false,
    this.errorMessage,
    this.toastMessage,
    this.isReturnedToHome = false,
  });

  factory DriverFlagRideState.initial({DriverFlagRideStatus? initialStatus}) {
    final status = initialStatus ?? DriverFlagRideStatus.startFlagRide;
    DriverFlagRideModel model;
    switch (status) {
      case DriverFlagRideStatus.startFlagRide:
        model = DriverFlagRideConfig.startFlagRidePreset;
        break;
      case DriverFlagRideStatus.flagInProgress:
        model = DriverFlagRideConfig.flagInProgressPreset;
        break;
      case DriverFlagRideStatus.flagComplete:
        model = DriverFlagRideConfig.flagCompletePreset;
        break;
      case DriverFlagRideStatus.edgeStates:
        model = DriverFlagRideConfig.edgeStatesPreset;
        break;
      case DriverFlagRideStatus.returnedToHome:
        model = DriverFlagRideConfig.startFlagRidePreset;
        break;
    }

    return DriverFlagRideState(
      status: status,
      ride: model,
    );
  }

  bool get isStart => status == DriverFlagRideStatus.startFlagRide;
  bool get isInProgress => status == DriverFlagRideStatus.flagInProgress;
  bool get isComplete => status == DriverFlagRideStatus.flagComplete;
  bool get isEdgeStates => status == DriverFlagRideStatus.edgeStates;

  DriverFlagRideState copyWith({
    DriverFlagRideStatus? status,
    DriverFlagRideModel? ride,
    bool? isLoading,
    String? errorMessage,
    String? toastMessage,
    bool? isReturnedToHome,
    bool clearToast = false,
    bool clearError = false,
  }) {
    return DriverFlagRideState(
      status: status ?? this.status,
      ride: ride ?? this.ride,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
      isReturnedToHome: isReturnedToHome ?? this.isReturnedToHome,
    );
  }

  @override
  List<Object?> get props => [
        status,
        ride,
        isLoading,
        errorMessage,
        toastMessage,
        isReturnedToHome,
      ];
}
