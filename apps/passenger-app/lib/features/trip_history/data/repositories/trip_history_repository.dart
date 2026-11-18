import 'dart:async';
import '../../../../data/datasources/booking_remote_datasource.dart';
import 'package:bridgecabs_core/bridgecabs_core.dart';
import '../models/trip_history_config.dart';
import '../models/trip_history_model.dart';

abstract class TripHistoryRepository {
  Future<TripRecord?> getLastTrip();
  Future<List<TripRecord>> getPastTrips();
  Future<TripRecord> getTripDetails(String tripId, {TripPaymentScenario? scenario});
  Future<void> downloadTaxReceipt(String tripId);

  // Enhanced methods for the full Trips list and filters
  Future<List<GroupedTripDate>> getGroupedTrips({
    TripHistoryFilter filter = TripHistoryFilter.today,
    CustomDateRange? customRange,
  });
  Future<TripSummaryData> getTripSummary({
    TripHistoryFilter filter = TripHistoryFilter.today,
    CustomDateRange? customRange,
  });
}

class MockTripHistoryRepository implements TripHistoryRepository {
  final TripRecord _lastTrip;
  final Duration delay;

  MockTripHistoryRepository({
    TripRecord? initialLastTrip,
    this.delay = const Duration(milliseconds: 40),
  }) : _lastTrip = initialLastTrip ?? TripHistoryConfig.defaultLastTrip;

  @override
  Future<TripRecord?> getLastTrip() async {
    await Future.delayed(delay);
    return _lastTrip;
  }

  @override
  Future<List<TripRecord>> getPastTrips() async {
    await Future.delayed(delay);
    return TripHistoryConfig.allHistoryTrips;
  }

  @override
  Future<TripRecord> getTripDetails(
    String tripId, {
    TripPaymentScenario? scenario,
  }) async {
    await Future.delayed(delay);

    final base = TripHistoryConfig.allHistoryTrips.firstWhere(
      (t) => t.tripId == tripId,
      orElse: () => _lastTrip,
    );

    if (scenario != null) {
      switch (scenario) {
        case TripPaymentScenario.cardPaid:
          return base.copyWith(
            paymentScenario: TripPaymentScenario.cardPaid,
            paymentMethod: 'Visa •••• 4242',
            paymentStatus: 'Paid',
          );
        case TripPaymentScenario.cashPaid:
          return base.copyWith(
            paymentScenario: TripPaymentScenario.cashPaid,
            paymentMethod: 'Cash Payment',
            paymentStatus: 'Paid in Cash',
          );
        case TripPaymentScenario.cashPending:
          return base.copyWith(
            paymentScenario: TripPaymentScenario.cashPending,
            paymentMethod: 'Cash Payment',
            paymentStatus: 'Awaiting Driver Terminal Confirmation',
          );
      }
    }

    return base;
  }

  @override
  Future<void> downloadTaxReceipt(String tripId) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<List<GroupedTripDate>> getGroupedTrips({
    TripHistoryFilter filter = TripHistoryFilter.today,
    CustomDateRange? customRange,
  }) async {
    await Future.delayed(delay);
    // When filtered by custom range or specific date, can adapt
    return TripHistoryConfig.defaultGroupedTrips;
  }

  @override
  Future<TripSummaryData> getTripSummary({
    TripHistoryFilter filter = TripHistoryFilter.today,
    CustomDateRange? customRange,
  }) async {
    await Future.delayed(delay);
    return TripHistoryConfig.defaultSummary;
  }
}

class _DatedTrip {
  const _DatedTrip(this.at, this.record);

  final DateTime at;
  final TripRecord record;
}

class ApiTripHistoryRepository implements TripHistoryRepository {
  ApiTripHistoryRepository(this._remote);

  final BookingRemoteDataSource _remote;

  Future<List<_DatedTrip>> _load() async {
    final body = await _remote.history();
    final rows = body is Map && body['data'] is List
        ? body['data'] as List
        : const <dynamic>[];
    return rows.map(_dated).whereType<_DatedTrip>().toList();
  }

  @override
  Future<TripRecord?> getLastTrip() async {
    final trips = await _load();
    if (trips.isEmpty) return null;
    return trips.first.record;
  }

  @override
  Future<List<TripRecord>> getPastTrips() async {
    final trips = await _load();
    return trips.map((trip) => trip.record).toList();
  }

  @override
  Future<TripRecord> getTripDetails(
    String tripId, {
    TripPaymentScenario? scenario,
  }) async {
    final trips = await _load();
    for (final trip in trips) {
      if (trip.record.tripId == tripId) return trip.record;
    }
    throw StateError('Trip not found');
  }

  @override
  Future<void> downloadTaxReceipt(String tripId) async {
    throw StateError('A PDF receipt is not available for this trip yet');
  }

  @override
  Future<List<GroupedTripDate>> getGroupedTrips({
    TripHistoryFilter filter = TripHistoryFilter.today,
    CustomDateRange? customRange,
  }) async {
    final trips = _matching(await _load(), filter, customRange);
    final groups = <String, List<_DatedTrip>>{};
    for (final trip in trips) {
      final local = trip.at.toLocal();
      final key = '${local.year}-${local.month}-${local.day}';
      groups.putIfAbsent(key, () => []).add(trip);
    }
    return groups.entries.map((entry) {
      final items = entry.value;
      final total = items.fold<double>(0, (sum, trip) => sum + trip.record.totalCad);
      final label = _dayLabel(items.first.at);
      final rides = items.length == 1 ? '1 ride' : '${items.length} rides';
      return GroupedTripDate(
        dateHeader: '$label · $rides · \$${total.toStringAsFixed(2)} CAD',
        dateLabel: label,
        rideCount: items.length,
        totalCad: total,
        trips: items.map((trip) => trip.record).toList(),
      );
    }).toList();
  }

  @override
  Future<TripSummaryData> getTripSummary({
    TripHistoryFilter filter = TripHistoryFilter.today,
    CustomDateRange? customRange,
  }) async {
    final trips = _matching(await _load(), filter, customRange);
    final spent = trips.fold<double>(0, (sum, trip) => sum + trip.record.totalCad);
    return TripSummaryData(totalTrips: trips.length, totalSpentCad: spent);
  }

  List<_DatedTrip> _matching(
    List<_DatedTrip> trips,
    TripHistoryFilter filter,
    CustomDateRange? customRange,
  ) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    return trips.where((trip) {
      final day = DateTime(trip.at.toLocal().year, trip.at.toLocal().month, trip.at.toLocal().day);
      switch (filter) {
        case TripHistoryFilter.today:
          return day == startOfToday;
        case TripHistoryFilter.yesterday:
          return day == startOfToday.subtract(const Duration(days: 1));
        case TripHistoryFilter.thisWeek:
          return !day.isBefore(startOfToday.subtract(const Duration(days: 6)));
        case TripHistoryFilter.thisMonth:
          return day.year == now.year && day.month == now.month;
        case TripHistoryFilter.custom:
          final range = customRange;
          if (range == null) return true;
          final start = DateTime(range.startDate.year, range.startDate.month, range.startDate.day);
          final end = DateTime(range.endDate.year, range.endDate.month, range.endDate.day);
          return !day.isBefore(start) && !day.isAfter(end);
      }
    }).toList();
  }
}

_DatedTrip? _dated(Object? raw) {
  if (raw is! Map) return null;
  final booking = ActiveBooking.tryParse(raw);
  if (booking == null) return null;
  final created = raw['createdAt'];
  final at = created is String
      ? DateTime.tryParse(created) ?? DateTime.now()
      : DateTime.now();
  final cancelled = booking.status == 'CANCELLED';
  final driver = booking.driver;
  final vehicle = driver?.vehicle;
  final card = raw['paymentMethod'] == 'CARD';
  final distance = raw['distanceMeters'];
  final duration = raw['durationSeconds'];
  return _DatedTrip(
    at,
    TripRecord(
      tripId: booking.id,
      bookingTitle: booking.trackingId,
      serviceTier: booking.vehicleTypeName,
      dateTimeLabel: _dayLabel(at),
      statusLabel: cancelled ? 'CANCELED' : 'COMPLETED',
      pickupAddress: booking.pickupAddress ?? '—',
      pickupTime: '',
      dropoffAddress: booking.dropoffAddress ?? '—',
      dropoffTime: '',
      driverName: driver?.firstName ?? 'Driver',
      driverRating: driver?.rating ?? 0,
      driverVehicle: vehicle == null ? '' : '${vehicle.make} ${vehicle.model}'.trim(),
      licensePlate: vehicle?.plate ?? '',
      driverVehicleUnit: vehicle?.unitNumber == null ? '' : 'Unit ${vehicle!.unitNumber}',
      paymentScenario: card ? TripPaymentScenario.cardPaid : TripPaymentScenario.cashPaid,
      paymentMethod: card ? 'Card' : 'Cash',
      paymentStatus: cancelled ? 'Cancelled' : 'Paid',
      subtotalCad: booking.receiptSubtotalCents / 100,
      gstCad: booking.receiptTaxCents / 100,
      totalCad: booking.receiptTotalCents / 100,
      vehicleTypePill: booking.vehicleTypeName,
      distanceKm: distance is num ? distance / 1000 : 0,
      durationMinutes: duration is num ? (duration / 60).round() : 0,
    ),
  );
}

String _dayLabel(DateTime time) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final local = time.toLocal();
  return '${days[local.weekday - 1]}, ${local.day} ${months[local.month - 1]}';
}
