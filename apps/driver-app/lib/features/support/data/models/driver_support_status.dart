enum DriverSupportViewStatus {
  center,
  newTicket,
  myTickets,
  ticketDetail,
  emergencySos;

  String get label {
    switch (this) {
      case DriverSupportViewStatus.center:
        return '1. Center';
      case DriverSupportViewStatus.newTicket:
        return '2. New Ticket';
      case DriverSupportViewStatus.myTickets:
        return '3. My Tickets';
      case DriverSupportViewStatus.ticketDetail:
        return '4. Chat Detail';
      case DriverSupportViewStatus.emergencySos:
        return '5. SOS Modal';
    }
  }

  bool get isCenter => this == DriverSupportViewStatus.center;
  bool get isNewTicket => this == DriverSupportViewStatus.newTicket;
  bool get isMyTickets => this == DriverSupportViewStatus.myTickets;
  bool get isTicketDetail => this == DriverSupportViewStatus.ticketDetail;
  bool get isEmergencySos => this == DriverSupportViewStatus.emergencySos;
}
