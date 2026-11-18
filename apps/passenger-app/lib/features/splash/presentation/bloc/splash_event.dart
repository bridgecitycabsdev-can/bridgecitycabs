import 'package:equatable/equatable.dart';

/// Base class for all Splash events.
abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched immediately when the splash screen is mounted.
/// Triggers bootstrap check, fleet dispatch connection, and session validation.
class SplashStarted extends SplashEvent {
  const SplashStarted();
}

/// Dispatched when network latency exceeds the threshold or weak signal is reported.
/// Transitions UI to the "Still connecting..." state with amber badge and reconnect notice.
class SplashSlowConnectionDetected extends SplashEvent {
  final String notice;

  const SplashSlowConnectionDetected({
    this.notice = 'Reconnecting to fleet dispatch',
  });

  @override
  List<Object?> get props => [notice];
}

/// Dispatched when the connection attempt fails or device is completely offline.
/// Displays the white "Connection Interrupted" modal card with "Try again" and hotline call options.
class SplashConnectionFailed extends SplashEvent {
  final String errorMessage;
  final bool isOffline;

  const SplashConnectionFailed({
    this.errorMessage = "Couldn't connect. Check your internet and try again.",
    this.isOffline = true,
  });

  @override
  List<Object?> get props => [errorMessage, isOffline];
}

/// Dispatched when the passenger taps the "Try again" button on the error modal.
class SplashRetryRequested extends SplashEvent {
  const SplashRetryRequested();
}

/// Dispatched when the passenger taps "Call 403-555-CABS →" to call dispatch directly.
class SplashHotlineCallRequested extends SplashEvent {
  const SplashHotlineCallRequested();
}

/// Dispatched when initialization succeeds and the app is ready to navigate.
class SplashBootstrapCompleted extends SplashEvent {
  final bool isAuthenticated;
  final String destinationRoute;

  const SplashBootstrapCompleted({
    required this.isAuthenticated,
    required this.destinationRoute,
  });

  @override
  List<Object?> get props => [isAuthenticated, destinationRoute];
}
