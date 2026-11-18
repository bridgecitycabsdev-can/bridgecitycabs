import '../models/driver_delete_checklist.dart';
import '../models/driver_delete_confirmation_data.dart';
import '../models/driver_delete_safeguard_block.dart';

abstract class DriverDeleteAccountRepository {
  Future<DriverDeleteChecklist> getChecklist();
  Future<List<DriverDeleteSafeguardBlock>> getSafeguardBlocks();
  Future<DriverDeleteConfirmationData> getConfirmationData();
  Future<bool> requestAccountDeletion();
  Future<bool> cancelDeletionAndRestore();
}

class FakeDriverDeleteAccountRepository implements DriverDeleteAccountRepository {
  @override
  Future<DriverDeleteChecklist> getChecklist() async {
    await Future.delayed(const Duration(milliseconds: 40));
    return const DriverDeleteChecklist(
      items: [
        DriverDeleteChecklistItem(
          id: 'no_trip',
          title: 'No trip in progress',
          subtitle: 'Lethbridge central dispatch offline',
          isPassed: true,
        ),
        DriverDeleteChecklistItem(
          id: 'unpaid_earnings',
          title: 'Unpaid earnings: \$0.00',
          subtitle: 'All weekly direct deposits settled',
          isPassed: true,
          hasTestHold: true,
        ),
        DriverDeleteChecklistItem(
          id: 'statements_paid',
          title: 'All statements paid',
          subtitle: 'Vehicle lease & tech fees up to date',
          isPassed: true,
        ),
        DriverDeleteChecklistItem(
          id: 'no_tickets',
          title: 'No open support tickets about payments',
          subtitle: 'Zero unresolved driver disputes',
          isPassed: true,
        ),
      ],
      whatWillBeDeleted: [
        'Your driver profile and photo',
        'Uploaded documents (licence, registration, insurance)',
        'Vehicle details and cab equipment tags',
        'Notifications and support dispatch history',
      ],
      whatMayBeKept: [
        'Trip, earnings, and municipal tax records we\'re required to keep by Alberta transportation regulations',
        'Incident logs needed for safety protocols or active dispute audits',
      ],
      anonymizedNotice:
          'Kept records are anonymized and no longer linked to your personal phone number or vehicle where legally permissible.',
      reflectionPeriodText:
          'You\'ll have 30 days to change your mind. Simply log back into the driver portal before the period ends to cancel deletion.',
    );
  }

  @override
  Future<List<DriverDeleteSafeguardBlock>> getSafeguardBlocks() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return const [
      DriverDeleteSafeguardBlock(
        type: DriverDeleteSafeguardBlockType.tripActive,
        tag: 'BLOCK CRITICAL',
        cabUnit: 'Cab #429',
        title: 'Active trip underway',
        description:
            'Finish your current trip before deleting your account. Safety telemetry is transmitting to Bridge City Dispatch.',
        passengerName: 'Sarah K.',
        isMeterRunning: true,
        pickupLocation: 'Lethbridge Airport (YQL)',
        dropoffLocation: 'Downtown Scenic Drive',
        fareEstimate: 28.40,
        etaMinutes: '11 min',
        actionButtonText: 'Go to trip',
      ),
      DriverDeleteSafeguardBlock(
        type: DriverDeleteSafeguardBlockType.unpaidBalance,
        tag: 'PAYMENT HOLD',
        cabUnit: 'Cab #429',
        title: 'Unsettled shift earnings or account arrears',
        description:
            'You have an uncollected cash balance or pending terminal reconciliation that must be cleared.',
        fareEstimate: 48.20,
        actionButtonText: 'View earnings statement',
      ),
      DriverDeleteSafeguardBlock(
        type: DriverDeleteSafeguardBlockType.openDisputes,
        tag: 'LEGAL HOLD',
        cabUnit: 'Cab #429',
        title: 'Unresolved dispatch or passenger disputes',
        description:
            'Support ticket #TK-9042 is currently open regarding a fare audit.',
        actionButtonText: 'Open support ticket',
      ),
      DriverDeleteSafeguardBlock(
        type: DriverDeleteSafeguardBlockType.equipmentHold,
        tag: 'HARDWARE LOCK',
        cabUnit: 'Cab #429',
        title: 'Fleet hardware & medallion tag return',
        description:
            'In-cab tap-to-pay terminal #OTA-4.12 and taxi top-light assigned to Unit #42 must be checked into Central Depot.',
        actionButtonText: 'Depot directions',
      ),
      DriverDeleteSafeguardBlock(
        type: DriverDeleteSafeguardBlockType.bylawLock,
        tag: 'MUNICIPAL BYLAW 5834',
        cabUnit: 'Cab #429',
        title: 'Municipal compliance retention period',
        description:
            'City of Lethbridge commercial driver regulations require an active shift audit log lock.',
        actionButtonText: 'Review bylaws',
      ),
    ];
  }

  @override
  Future<DriverDeleteConfirmationData> getConfirmationData() async {
    await Future.delayed(const Duration(milliseconds: 30));
    return const DriverDeleteConfirmationData();
  }

  @override
  Future<bool> requestAccountDeletion() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }

  @override
  Future<bool> cancelDeletionAndRestore() async {
    await Future.delayed(const Duration(milliseconds: 80));
    return true;
  }
}
