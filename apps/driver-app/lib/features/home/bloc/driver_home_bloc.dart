import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/driver_home_metrics.dart';
import '../data/models/driver_home_status.dart';
import '../data/models/driver_incoming_offer.dart';
import '../data/models/driver_shift_mode.dart';
import '../data/models/driver_surge_zone.dart';
import '../data/models/driver_verification_item.dart';
import '../data/repositories/driver_home_repository.dart';
import 'driver_home_event.dart';
import 'driver_home_state.dart';

class DriverHomeBloc extends Bloc<DriverHomeEvent, DriverHomeState> {
  final DriverHomeRepository repository;

  DriverHomeBloc({DriverHomeRepository? repository})
      : repository = repository ?? MockDriverHomeRepository(),
        super(const DriverHomeState()) {
    on<DriverHomeStarted>(_onStarted);
    on<DriverHomeGoOnlineRequested>(_onGoOnlineRequested);
    on<DriverHomeGoOfflineRequested>(_onGoOfflineRequested);
    on<DriverHomeSetAwayRequested>(_onSetAwayRequested);
    on<DriverHomeResumeActiveRequested>(_onResumeActiveRequested);
    on<DriverHomeEnableLocationRequested>(_onEnableLocationRequested);
    on<DriverHomeRetryConnectionRequested>(_onRetryConnectionRequested);
    on<DriverHomeViewIncomingOfferRequested>(_onViewIncomingOfferRequested);
    on<DriverHomeViewDocumentsRequested>(_onViewDocumentsRequested);
    on<DriverHomeCheckApplicationStatusRequested>(
        _onCheckApplicationStatusRequested);
    on<DriverHomeEarningsRefreshRequested>(_onEarningsRefreshRequested);
    on<DriverHomeThemeToggled>(_onThemeToggled);
    on<DriverHomeStateSwitched>(_onStateSwitched);
  }

  void _onStarted(
    DriverHomeStarted event,
    Emitter<DriverHomeState> emit,
  ) {
    if (event.initialStatus != DriverHomeStatus.offline) {
      add(DriverHomeStateSwitched(event.initialStatus));
      return;
    }

    emit(state.copyWith(
      status: DriverHomeStatus.offline,
      shiftMode: DriverShiftMode.active,
      metrics: const DriverHomeMetrics(
        todayEarnings: 41.77,
        ridesToday: 1,
        acceptanceRate: 50,
        onlineTime: '2h 15m',
        pingMs: 18,
      ),
    ));
  }

  Future<void> _onGoOnlineRequested(
    DriverHomeGoOnlineRequested event,
    Emitter<DriverHomeState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true));
    await repository.startShift();
    emit(state.copyWith(
      isActionLoading: false,
      status: DriverHomeStatus.onlineSearching,
      shiftMode: DriverShiftMode.active,
      feedbackMessage: 'Shift started! Searching for rides across Lethbridge.',
    ));
  }

  Future<void> _onGoOfflineRequested(
    DriverHomeGoOfflineRequested event,
    Emitter<DriverHomeState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true));
    await repository.endShift();
    emit(state.copyWith(
      isActionLoading: false,
      status: DriverHomeStatus.offline,
      shiftMode: DriverShiftMode.active,
      feedbackMessage: 'You are now offline.',
    ));
  }

  Future<void> _onSetAwayRequested(
    DriverHomeSetAwayRequested event,
    Emitter<DriverHomeState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true));
    await repository.pauseShift();
    emit(state.copyWith(
      isActionLoading: false,
      status: DriverHomeStatus.shiftAway,
      shiftMode: DriverShiftMode.away,
      feedbackMessage: 'Shift paused. You are currently Away.',
    ));
  }

  Future<void> _onResumeActiveRequested(
    DriverHomeResumeActiveRequested event,
    Emitter<DriverHomeState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true));
    await repository.resumeShift();
    emit(state.copyWith(
      isActionLoading: false,
      status: DriverHomeStatus.onlineSearching,
      shiftMode: DriverShiftMode.active,
      feedbackMessage: 'Back to active! Searching for rides.',
    ));
  }

  Future<void> _onEnableLocationRequested(
    DriverHomeEnableLocationRequested event,
    Emitter<DriverHomeState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true));
    await repository.requestLocationPermission();
    emit(state.copyWith(
      isActionLoading: false,
      status: DriverHomeStatus.onlineSearching,
      shiftMode: DriverShiftMode.active,
      isDarkMode: false,
      feedbackMessage: 'GPS location enabled! Dispatch signal restored.',
    ));
  }

  Future<void> _onRetryConnectionRequested(
    DriverHomeRetryConnectionRequested event,
    Emitter<DriverHomeState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true));
    await repository.retryNetworkConnection();
    emit(state.copyWith(
      isActionLoading: false,
      status: DriverHomeStatus.onlineSearching,
      feedbackMessage: 'Reconnected to Bridge City Dispatch Server!',
    ));
  }

  void _onViewIncomingOfferRequested(
    DriverHomeViewIncomingOfferRequested event,
    Emitter<DriverHomeState> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage: 'Opening incoming ride offer details...',
    ));
  }

  void _onViewDocumentsRequested(
    DriverHomeViewDocumentsRequested event,
    Emitter<DriverHomeState> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage: 'Navigating to compliance documents review...',
    ));
  }

  void _onCheckApplicationStatusRequested(
    DriverHomeCheckApplicationStatusRequested event,
    Emitter<DriverHomeState> emit,
  ) {
    emit(state.copyWith(
      feedbackMessage:
          'Checking Lethbridge Taxi Commission approval status...',
    ));
  }

  Future<void> _onEarningsRefreshRequested(
    DriverHomeEarningsRefreshRequested event,
    Emitter<DriverHomeState> emit,
  ) async {
    final updated = await repository.refreshMetrics();
    emit(state.copyWith(
      metrics: updated,
      feedbackMessage: 'Earnings refreshed: \$41.77 CAD',
    ));
  }

  void _onThemeToggled(
    DriverHomeThemeToggled event,
    Emitter<DriverHomeState> emit,
  ) {
    emit(state.copyWith(isDarkMode: !state.isDarkMode));
  }

  void _onStateSwitched(
    DriverHomeStateSwitched event,
    Emitter<DriverHomeState> emit,
  ) {
    switch (event.status) {
      case DriverHomeStatus.offline:
        // Image 1: Offline
        emit(state.copyWith(
          status: DriverHomeStatus.offline,
          shiftMode: DriverShiftMode.active,
          isDarkMode: false,
          metrics: const DriverHomeMetrics(
            todayEarnings: 41.77,
            isEarningsLocked: false,
            ridesToday: 1,
            acceptanceRate: 50,
            onlineTime: '2h 15m',
            pingMs: 18,
            currentLocationName: 'Lethbridge Fleet Zone 01',
          ),
        ));
        break;

      case DriverHomeStatus.onlineSearching:
        // Image 2: Online & Searching
        emit(state.copyWith(
          status: DriverHomeStatus.onlineSearching,
          shiftMode: DriverShiftMode.active,
          isDarkMode: false,
          metrics: const DriverHomeMetrics(
            todayEarnings: 41.77,
            isEarningsLocked: false,
            ridesToday: 1,
            acceptanceRate: 50,
            onlineTime: '2h 15m',
            shiftStartTime: '07:45 AM',
            currentLocationName: 'Scenic Dr & Old Man River',
          ),
          surgeZone: const DriverSurgeZone(
            multiplier: 1.3,
            title: 'High demand near...',
            subtitle: '1.3x request surge in 4t...',
            areaName: 'Legacy Ridge / Old Man River',
          ),
        ));
        break;

      case DriverHomeStatus.locationOff:
        // Image 3: Location / GPS Off (Dark mode map)
        emit(state.copyWith(
          status: DriverHomeStatus.locationOff,
          shiftMode: DriverShiftMode.locked,
          isDarkMode: true,
          metrics: const DriverHomeMetrics(
            todayEarnings: 41.77,
            isEarningsLocked: false,
            ridesToday: 1,
            acceptanceRate: 50,
            onlineTime: '2h 15m',
            currentLocationName: 'Lethbridge City Zone Fleet #402',
          ),
        ));
        break;

      case DriverHomeStatus.shiftAway:
        // Image 4: Shift on pause (Away)
        emit(state.copyWith(
          status: DriverHomeStatus.shiftAway,
          shiftMode: DriverShiftMode.away,
          isDarkMode: false,
          metrics: const DriverHomeMetrics(
            todayEarnings: 41.77,
            isEarningsLocked: false,
            ridesToday: 1,
            acceptanceRate: 50,
            onlineTime: '2h 15m',
            currentLocationName: 'Downtown Lethbridge • 3 Ave S',
            fleetUnit: 'Unit 42',
          ),
        ));
        break;

      case DriverHomeStatus.networkOffline:
        // Image 5: Network Connection Lost
        emit(state.copyWith(
          status: DriverHomeStatus.networkOffline,
          shiftMode: DriverShiftMode.locked,
          isDarkMode: false,
          metrics: const DriverHomeMetrics(
            todayEarnings: 41.77,
            isEarningsLocked: false,
            ridesToday: 1,
            acceptanceRate: 50,
            onlineTime: '2h 15m',
          ),
        ));
        break;

      case DriverHomeStatus.incomingOffer:
        // Image 6: Incoming Ride Offer
        emit(state.copyWith(
          status: DriverHomeStatus.incomingOffer,
          shiftMode: DriverShiftMode.active,
          isDarkMode: false,
          metrics: const DriverHomeMetrics(
            todayEarnings: 41.77,
            isEarningsLocked: false,
            ridesToday: 1,
            acceptanceRate: 50,
            onlineTime: '2h 15m',
          ),
          incomingOffer: const DriverIncomingOffer(
            offerId: 'OFFER-7821',
            remainingSeconds: 13,
            estimatedFare: 22.50,
            pickupAddress: 'Scenic Dr & 4th Ave S',
            dropoffAddress: 'University Dr W, ULeth',
            distanceKm: 4.8,
            estimatedDurationMin: 9,
          ),
        ));
        break;

      case DriverHomeStatus.accountPending:
        // Image 7: Account Pending (Dispatch Locked)
        emit(state.copyWith(
          status: DriverHomeStatus.accountPending,
          shiftMode: DriverShiftMode.locked,
          isDarkMode: false,
          metrics: const DriverHomeMetrics(
            todayEarnings: 0.00,
            isEarningsLocked: true,
            ridesToday: 0,
            acceptanceRate: 0,
            onlineTime: '0h 00m',
            currentLocationName: 'Unit 42 • INACTIVE',
            fleetUnit: 'Unit 42',
          ),
          verificationItems: const [
            DriverVerificationItem(
              title: "Driver's License (Class 4)",
              subtitle: 'AB License • Expiry 2027',
              status: VerificationItemStatus.verified,
              tagText: 'VERIFIED',
            ),
            DriverVerificationItem(
              title: 'Vehicle Registration',
              subtitle: 'Toyota Camry • Plate CAB-42',
              status: VerificationItemStatus.underReview,
              tagText: 'UNDER REVIEW',
            ),
            DriverVerificationItem(
              title: 'City Mechanical Inspection',
              subtitle: 'Annual Certificate of Mechanical Fitness',
              status: VerificationItemStatus.pending,
              tagText: 'PENDING',
            ),
          ],
        ));
        break;
    }
  }
}
