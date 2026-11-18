import 'package:equatable/equatable.dart';
import '../data/models/driver_register_step4_data.dart';
import '../data/models/driver_register_step4_status.dart';

class DriverRegisterStep4State extends Equatable {
  final DriverRegisterStep4Status status;
  final DriverRegisterStep4Data data;
  final bool isRefreshing;
  final bool isReconnecting;
  final String? feedbackMessage;

  const DriverRegisterStep4State({
    this.status = DriverRegisterStep4Status.reviewing,
    this.data = const DriverRegisterStep4Data(),
    this.isRefreshing = false,
    this.isReconnecting = false,
    this.feedbackMessage,
  });

  bool get isApproved => status == DriverRegisterStep4Status.approved;
  bool get isReviewing => status == DriverRegisterStep4Status.reviewing;
  bool get isActionRequired => status == DriverRegisterStep4Status.actionRequired;
  bool get isRejected => status == DriverRegisterStep4Status.rejected;
  bool get isOffline => status == DriverRegisterStep4Status.offline;

  DriverRegisterStep4State copyWith({
    DriverRegisterStep4Status? status,
    DriverRegisterStep4Data? data,
    bool? isRefreshing,
    bool? isReconnecting,
    String? feedbackMessage,
  }) {
    return DriverRegisterStep4State(
      status: status ?? this.status,
      data: data ?? this.data,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isReconnecting: isReconnecting ?? this.isReconnecting,
      feedbackMessage: feedbackMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        data,
        isRefreshing,
        isReconnecting,
        feedbackMessage,
      ];
}
