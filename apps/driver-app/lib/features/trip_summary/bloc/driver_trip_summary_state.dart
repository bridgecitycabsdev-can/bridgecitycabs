import 'package:equatable/equatable.dart';
import '../data/models/driver_trip_summary_config.dart';
import '../data/models/driver_trip_summary_model.dart';
import '../data/models/driver_trip_summary_status.dart';

class DriverTripSummaryState extends Equatable {
  final DriverTripSummaryStatus status;
  final DriverTripSummaryModel summary;
  final bool isLoading;
  final String? errorMessage;
  final String? toastMessage;
  final bool isReturnedToDispatch;

  const DriverTripSummaryState({
    required this.status,
    required this.summary,
    this.isLoading = false,
    this.errorMessage,
    this.toastMessage,
    this.isReturnedToDispatch = false,
  });

  factory DriverTripSummaryState.initial({DriverTripSummaryStatus? initialStatus}) {
    final status = initialStatus ?? DriverTripSummaryStatus.cardSettled;
    DriverTripSummaryModel model;
    switch (status) {
      case DriverTripSummaryStatus.cardSettled:
        model = DriverTripSummaryConfig.cardSummaryPreset;
        break;
      case DriverTripSummaryStatus.cashDue:
        model = DriverTripSummaryConfig.cashSummaryPreset;
        break;
      case DriverTripSummaryStatus.ratePassenger:
        model = DriverTripSummaryConfig.ratePassengerPreset;
        break;
      case DriverTripSummaryStatus.edgeStatesGallery:
        model = DriverTripSummaryConfig.edgeStatesGalleryPreset;
        break;
      case DriverTripSummaryStatus.returnedToDispatch:
        model = DriverTripSummaryConfig.cardSummaryPreset;
        break;
    }

    return DriverTripSummaryState(
      status: status,
      summary: model,
    );
  }

  bool get isCardSettled => status == DriverTripSummaryStatus.cardSettled;
  bool get isCashDue => status == DriverTripSummaryStatus.cashDue;
  bool get isRatePassenger => status == DriverTripSummaryStatus.ratePassenger;
  bool get isEdgeStatesGallery => status == DriverTripSummaryStatus.edgeStatesGallery;

  DriverTripSummaryState copyWith({
    DriverTripSummaryStatus? status,
    DriverTripSummaryModel? summary,
    bool? isLoading,
    String? errorMessage,
    String? toastMessage,
    bool? isReturnedToDispatch,
    bool clearToast = false,
    bool clearError = false,
  }) {
    return DriverTripSummaryState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
      isReturnedToDispatch:
          isReturnedToDispatch ?? this.isReturnedToDispatch,
    );
  }

  @override
  List<Object?> get props => [
        status,
        summary,
        isLoading,
        errorMessage,
        toastMessage,
        isReturnedToDispatch,
      ];
}
