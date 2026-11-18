import 'package:equatable/equatable.dart';
import '../data/models/driver_splash_model.dart';

class DriverSplashState extends Equatable {
  final DriverSplashStatus status;
  final DriverDispatchHubInfo hubInfo;
  final int retryCount;
  final bool isRetrying;
  final String? feedbackMessage;

  const DriverSplashState({
    this.status = DriverSplashStatus.initial,
    this.hubInfo = const DriverDispatchHubInfo(),
    this.retryCount = 0,
    this.isRetrying = false,
    this.feedbackMessage,
  });

  bool get isInitial => status == DriverSplashStatus.initial;
  bool get isConnecting => status == DriverSplashStatus.connecting;
  bool get isConnectionError => status == DriverSplashStatus.connectionError;
  bool get isUpdateRequired => status == DriverSplashStatus.updateRequired;
  bool get isReady => status == DriverSplashStatus.ready;

  DriverSplashState copyWith({
    DriverSplashStatus? status,
    DriverDispatchHubInfo? hubInfo,
    int? retryCount,
    bool? isRetrying,
    String? feedbackMessage,
  }) {
    return DriverSplashState(
      status: status ?? this.status,
      hubInfo: hubInfo ?? this.hubInfo,
      retryCount: retryCount ?? this.retryCount,
      isRetrying: isRetrying ?? this.isRetrying,
      feedbackMessage: feedbackMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        hubInfo,
        retryCount,
        isRetrying,
        feedbackMessage,
      ];
}
