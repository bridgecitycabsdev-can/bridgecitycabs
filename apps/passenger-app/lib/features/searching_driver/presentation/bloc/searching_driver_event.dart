import 'package:equatable/equatable.dart';
import '../../data/models/driver_search_models.dart';

abstract class SearchingDriverEvent extends Equatable {
  const SearchingDriverEvent();

  @override
  List<Object?> get props => [];
}

class SearchingDriverStarted extends SearchingDriverEvent {
  final SearchBookingDetails? booking;

  const SearchingDriverStarted({this.booking});

  @override
  List<Object?> get props => [booking];
}

class SearchingDriverDriverFoundSimulated extends SearchingDriverEvent {
  final MatchedDriverInfo? driver;

  const SearchingDriverDriverFoundSimulated({this.driver});

  @override
  List<Object?> get props => [driver];
}

class SearchingDriverCountdownTicked extends SearchingDriverEvent {
  final int secondsRemaining;

  const SearchingDriverCountdownTicked(this.secondsRemaining);

  @override
  List<Object?> get props => [secondsRemaining];
}

class SearchingDriverCancelRequested extends SearchingDriverEvent {
  const SearchingDriverCancelRequested();
}

class SearchingDriverCancelConfirmed extends SearchingDriverEvent {
  const SearchingDriverCancelConfirmed();
}

class SearchingDriverCancelDismissed extends SearchingDriverEvent {
  const SearchingDriverCancelDismissed();
}

class SearchingDriverConnectionChanged extends SearchingDriverEvent {
  final bool isOnline;
  final int signalStrength;

  const SearchingDriverConnectionChanged({
    required this.isOnline,
    this.signalStrength = 1,
  });

  @override
  List<Object?> get props => [isOnline, signalStrength];
}

class SearchingDriverCopyTrackingIdTapped extends SearchingDriverEvent {
  const SearchingDriverCopyTrackingIdTapped();
}

class SearchingDriverRecenterTapped extends SearchingDriverEvent {
  const SearchingDriverRecenterTapped();
}

class SearchingDriverSafetyTapped extends SearchingDriverEvent {
  const SearchingDriverSafetyTapped();
}

class SearchingDriverCallDispatchTapped extends SearchingDriverEvent {
  const SearchingDriverCallDispatchTapped();
}

class SearchingDriverScheduleStatusSet extends SearchingDriverEvent {
  final bool isScheduled;
  final String? scheduledDateTime;

  const SearchingDriverScheduleStatusSet({
    required this.isScheduled,
    this.scheduledDateTime,
  });

  @override
  List<Object?> get props => [isScheduled, scheduledDateTime];
}
