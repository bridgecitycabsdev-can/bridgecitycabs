import 'package:equatable/equatable.dart';
import '../../data/models/past_trip_detail_config.dart';
import '../../data/models/past_trip_detail_model.dart';

enum PastTripDetailStatus { initial, loading, loaded, error }

class PastTripDetailState extends Equatable {
  final PastTripDetailStatus status;
  final TripDetailSegment selectedSegment;
  final PastTripQaScenario selectedQaScenario;
  final PastTripDetailModel trip;
  final bool isInspectorMode;
  final bool isDownloadingPdf;
  final bool isBookingReturn;
  final String? feedbackMessage;
  final bool isCopied;

  const PastTripDetailState({
    this.status = PastTripDetailStatus.initial,
    this.selectedSegment = TripDetailSegment.completedCard,
    this.selectedQaScenario = PastTripQaScenario.completedCard,
    this.trip = PastTripDetailConfig.defaultTripMarcus,
    this.isInspectorMode = false,
    this.isDownloadingPdf = false,
    this.isBookingReturn = false,
    this.feedbackMessage,
    this.isCopied = false,
  });

  bool get isInitial => status == PastTripDetailStatus.initial;
  bool get isLoading => status == PastTripDetailStatus.loading;
  bool get isLoaded => status == PastTripDetailStatus.loaded;
  bool get isError => status == PastTripDetailStatus.error;

  String get formattedTotal => trip.formattedTotal;
  String get formattedTripId => trip.formattedId;

  PastTripDetailState copyWith({
    PastTripDetailStatus? status,
    TripDetailSegment? selectedSegment,
    PastTripQaScenario? selectedQaScenario,
    PastTripDetailModel? trip,
    bool? isInspectorMode,
    bool? isDownloadingPdf,
    bool? isBookingReturn,
    String? Function()? feedbackMessage,
    bool? isCopied,
  }) {
    return PastTripDetailState(
      status: status ?? this.status,
      selectedSegment: selectedSegment ?? this.selectedSegment,
      selectedQaScenario: selectedQaScenario ?? this.selectedQaScenario,
      trip: trip ?? this.trip,
      isInspectorMode: isInspectorMode ?? this.isInspectorMode,
      isDownloadingPdf: isDownloadingPdf ?? this.isDownloadingPdf,
      isBookingReturn: isBookingReturn ?? this.isBookingReturn,
      feedbackMessage: feedbackMessage != null
          ? feedbackMessage()
          : this.feedbackMessage,
      isCopied: isCopied ?? this.isCopied,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedSegment,
        selectedQaScenario,
        trip,
        isInspectorMode,
        isDownloadingPdf,
        isBookingReturn,
        feedbackMessage,
        isCopied,
      ];
}
