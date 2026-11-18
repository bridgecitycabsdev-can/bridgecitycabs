import 'package:equatable/equatable.dart';
import '../../data/models/support_ticket_model.dart';

abstract class SupportEvent extends Equatable {
  const SupportEvent();

  @override
  List<Object?> get props => [];
}

class SupportLoadHubRequested extends SupportEvent {
  final bool forceRefresh;
  const SupportLoadHubRequested({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class SupportTabChanged extends SupportEvent {
  final SupportHubTab tab;
  const SupportTabChanged(this.tab);

  @override
  List<Object?> get props => [tab];
}

class SupportFilterSelected extends SupportEvent {
  final TicketCategory? category;
  const SupportFilterSelected(this.category);

  @override
  List<Object?> get props => [category];
}

class SupportCategoryChanged extends SupportEvent {
  final TicketCategory category;
  const SupportCategoryChanged(this.category);

  @override
  List<Object?> get props => [category];
}

class SupportTripSelected extends SupportEvent {
  final String tripId;
  final String tripRoute;
  final double fareCad;
  final String driverName;

  const SupportTripSelected({
    required this.tripId,
    required this.tripRoute,
    required this.fareCad,
    required this.driverName,
  });

  @override
  List<Object?> get props => [tripId, tripRoute, fareCad, driverName];
}

class SupportTitleChanged extends SupportEvent {
  final String title;
  const SupportTitleChanged(this.title);

  @override
  List<Object?> get props => [title];
}

class SupportMessageChanged extends SupportEvent {
  final String message;
  const SupportMessageChanged(this.message);

  @override
  List<Object?> get props => [message];
}

class SupportCreateTicketSubmitted extends SupportEvent {
  const SupportCreateTicketSubmitted();
}

class SupportResetCreateForm extends SupportEvent {
  const SupportResetCreateForm();
}

class SupportOpenTicketThread extends SupportEvent {
  final String ticketId;
  const SupportOpenTicketThread(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}

class SupportThreadMessageChanged extends SupportEvent {
  final String message;
  const SupportThreadMessageChanged(this.message);

  @override
  List<Object?> get props => [message];
}

class SupportSendThreadMessage extends SupportEvent {
  final String ticketId;
  const SupportSendThreadMessage(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}

class SupportCloseTicketThread extends SupportEvent {
  const SupportCloseTicketThread();
}
