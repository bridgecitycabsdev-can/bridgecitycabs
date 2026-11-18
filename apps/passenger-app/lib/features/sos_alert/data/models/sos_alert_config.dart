import 'sos_alert_model.dart';

class SosAlertConfig {
  static const String screenTitle = 'Emergency Sos';
  static const String activeTitle = 'Dispatch Alert Active';
  static const String emergencyPhone = '911';
  static const String safetyLinePhone = '403-328-8888';

  static const String clearanceDisclaimer =
      'Alert can only be cleared by Lethbridge Safety Ops once verified with vehicle dispatch.';

  static const String locationWarningTitle =
      "Can't get your location. Turn on location services.";
  static const String locationWarningSubtitle =
      'Bridge City Dispatch requires coordinates for pinpoint roadside response.';

  static const String connectionFailedTitle =
      "Couldn't send your alert. Check your connection and try again.";
  static const String connectionFailedSubtitle =
      'Cellular handshake failed near Whoop-Up Dr corridor. Packet queued locally.';

  static const SosRideTelemetry defaultTelemetry = SosRideTelemetry(
    tripId: 'BC-123456',
    driverName: 'Michael S.',
    vehicleModel: 'Toyota Camry',
    vehicleColor: 'Silver',
    vehiclePlate: 'ALTA 4829',
    cabNumber: '#42',
    currentAddress: 'Scenic Dr & 4 Ave S, Lethbridge',
    lastKnownPosition: 'Park Place Mall (2 mins ago)',
    accuracyLabel: 'Accurate GPS fix • Updated 3s ago',
    routeStatus: 'En route to Destination • Trip BC-123456 • In Pro...',
  );

  static const SosRideTelemetry transitTelemetry = SosRideTelemetry(
    tripId: 'BC-123456',
    driverName: 'Marcus V.',
    vehicleModel: 'Hybrid Camry',
    vehicleColor: 'Silver',
    vehiclePlate: 'ALTA 4829',
    cabNumber: '#42',
    currentAddress: 'Scenic Dr & 4 Ave S, Lethbridge',
    lastKnownPosition: 'Park Place Mall (2 mins ago)',
    accuracyLabel: 'Accurate GPS fix • Updated 3s ago',
    routeStatus: 'Lethbridge Transit Connector • In Progress',
  );
}
