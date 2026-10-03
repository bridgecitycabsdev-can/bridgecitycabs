import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session.dart';
import '../socket/driver_state_gate.dart';
import 'models.dart';
import 'server_clock.dart';

final serverClockProvider = Provider<ServerClock>((ref) => ServerClock());

final driverStateProvider =
    AsyncNotifierProvider<DriverStateController, DriverSnapshot>(
      DriverStateController.new,
    );

class DriverStateController extends AsyncNotifier<DriverSnapshot> {
  final DriverStateGate _gate = DriverStateGate();
  DriverSnapshot? _latest;

  @override
  Future<DriverSnapshot> build() => _load();

  DriverSnapshot? get latest => _latest;

  void applySocket(DriverSnapshot snapshot) {
    if (!_gate.acceptSocket(snapshot.version)) return;
    _apply(snapshot);
  }

  /// Offer alerts may arrive a tick before `driver:state`. Keep the card if we
  /// already have a matching snapshot, otherwise wait for the next state push.
  void noteOfferNew(Offer offer) {
    ref.read(serverClockProvider).sync(offer.serverNow);
    final current = _latest;
    if (current == null) return;
    if (current.status != DriverStatus.offered && current.offer != null) return;
    _latest = current.copyWith(
      status: DriverStatus.offered,
      offer: offer,
    );
    state = AsyncData(_latest!);
  }

  void clearOffer(String offerId) {
    final current = _latest;
    if (current == null || current.offer?.id != offerId) return;
    _latest = current.copyWith(
      clearOffer: true,
      status: current.status == DriverStatus.offered
          ? DriverStatus.available
          : current.status,
    );
    state = AsyncData(_latest!);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> startShift() async {
    await ref
        .read(apiClientProvider)
        .dio
        .post<dynamic>('/driver/shift/start', data: <String, dynamic>{});
    await reload();
  }

  Future<void> endShift() async {
    await ref.read(apiClientProvider).dio.post<dynamic>('/driver/shift/end');
    await reload();
  }

  Future<void> acceptOffer(String offerId) async {
    final response = await ref
        .read(apiClientProvider)
        .dio
        .post<dynamic>('/driver/offers/$offerId/accept');
    final snapshot = DriverSnapshot.tryParse(response.data);
    if (snapshot != null) {
      if (_gate.acceptRest(snapshot.version) || _latest == null) {
        _apply(snapshot);
      }
      return;
    }
    await reload();
  }

  Future<void> declineOffer(String offerId, {String? reason}) async {
    await ref.read(apiClientProvider).dio.post<dynamic>(
      '/driver/offers/$offerId/decline',
      data: <String, dynamic>{
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
    await reload();
  }

  Future<void> markArriving(String bookingId) async {
    await ref
        .read(apiClientProvider)
        .dio
        .post<dynamic>('/driver/bookings/$bookingId/arriving');
    await reload();
  }

  Future<void> markArrived(String bookingId) async {
    await ref
        .read(apiClientProvider)
        .dio
        .post<dynamic>('/driver/bookings/$bookingId/arrived');
    await reload();
  }

  Future<void> startTrip(String bookingId) async {
    await ref
        .read(apiClientProvider)
        .dio
        .post<dynamic>('/driver/bookings/$bookingId/start');
    await reload();
  }

  Future<void> completeTrip(String bookingId) async {
    await ref
        .read(apiClientProvider)
        .dio
        .post<dynamic>('/driver/bookings/$bookingId/complete');
    await reload();
  }

  /// Confirms cash with retry/backoff on network errors. Caller waits until
  /// [pendingPayment] clears on the next snapshot before navigating away.
  Future<void> collectCash(String bookingId) async {
    var delayMs = 500;
    Object? lastError;
    for (var attempt = 0; attempt < 5; attempt += 1) {
      try {
        await ref
            .read(apiClientProvider)
            .dio
            .post<dynamic>('/driver/bookings/$bookingId/cash-collected');
        await reload();
        return;
      } on DioException catch (error) {
        lastError = error;
        if (!_isRetryableNetwork(error) || attempt == 4) rethrow;
        await Future<void>.delayed(Duration(milliseconds: delayMs));
        delayMs *= 2;
      }
    }
    if (lastError != null) throw lastError;
  }

  Future<void> releaseBooking(String bookingId, String reason) async {
    await ref.read(apiClientProvider).dio.post<dynamic>(
      '/driver/bookings/$bookingId/release',
      data: <String, dynamic>{'reason': reason},
    );
    await reload();
  }

  bool isGone(Object error) {
    return error is DioException && error.response?.statusCode == 410;
  }

  bool _isRetryableNetwork(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError;
  }

  void _apply(DriverSnapshot snapshot) {
    if (snapshot.offer != null) {
      ref.read(serverClockProvider).sync(snapshot.offer!.serverNow);
    }
    _latest = snapshot;
    state = AsyncData(snapshot);
  }

  Future<DriverSnapshot> _load() async {
    final response = await ref
        .read(apiClientProvider)
        .dio
        .get<dynamic>('/driver/me/state');
    final snapshot = DriverSnapshot.tryParse(response.data);
    if (snapshot == null) {
      throw StateError('Driver state was incomplete');
    }
    if (!_gate.acceptRest(snapshot.version) && _latest != null) {
      return _latest!;
    }
    if (snapshot.offer != null) {
      ref.read(serverClockProvider).sync(snapshot.offer!.serverNow);
    }
    _latest = snapshot;
    return snapshot;
  }
}
