import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/features/request/request.dart';

void main() {
  group('DriverRequestBloc Tests', () {
    late FakeDriverRequestRepository repository;
    late DriverRequestBloc bloc;

    setUp(() {
      repository = FakeDriverRequestRepository(
        networkLatency: const Duration(milliseconds: 10),
      );
      bloc = DriverRequestBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state has instantPreset and incomingInstant status', () {
      expect(bloc.state.status, DriverRequestStatus.incomingInstant);
      expect(bloc.state.request.pickupAddress, '440 University Dr W');
      expect(bloc.state.request.fareCad, 15.00);
      expect(bloc.state.request.remainingSeconds, 10);
    });

    test('Timer tick decrements seconds and transitions to expiringUrgent when <= 3', () {
      bloc.add(const DriverRequestTimerTicked(5));
      expect(bloc.state.request.remainingSeconds, 5);
      expect(bloc.state.status, DriverRequestStatus.incomingInstant);

      bloc.add(const DriverRequestTimerTicked(2));
      expect(bloc.state.request.remainingSeconds, 2);
      expect(bloc.state.status, DriverRequestStatus.expiringUrgent);
      expect(bloc.state.isExpiringUrgent, isTrue);
    });

    test('Timer tick transitions to expired when remaining seconds reach 0', () {
      bloc.add(const DriverRequestTimerTicked(0));
      expect(bloc.state.status, DriverRequestStatus.expired);
      expect(bloc.state.isExpired, isTrue);
      expect(bloc.state.impact.penaltyPercent, -1);
    });

    test('Accept pressed triggers securingDispatch and sets shouldNavigateToTrip', () async {
      bloc.add(const DriverRequestAcceptPressed());
      expect(bloc.state.status, DriverRequestStatus.securingDispatch);
      expect(bloc.state.isActionLoading, isTrue);

      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.isActionLoading, isFalse);
      expect(bloc.state.shouldNavigateToTrip, isTrue);
    });

    test('Decline pressed transitions to declineConfirmation bottom sheet', () {
      bloc.add(const DriverRequestDeclinePressed());
      expect(bloc.state.status, DriverRequestStatus.declineConfirmation);
      expect(bloc.state.isDeclineSheetOpen, isTrue);
      expect(bloc.state.impact.projectedRate, 48);
    });

    test('Selecting decline reason updates selectedReason', () {
      bloc.add(const DriverRequestDeclinePressed());
      bloc.add(const DriverRequestReasonSelected(DriverDeclineReason.tooFarAway));
      expect(bloc.state.selectedReason, DriverDeclineReason.tooFarAway);
    });

    test('Decline confirmed calls repository and navigates to map', () async {
      bloc.add(const DriverRequestDeclinePressed());
      bloc.add(const DriverRequestReasonSelected(DriverDeclineReason.breakTime));
      bloc.add(const DriverRequestDeclineConfirmed());

      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.shouldNavigateToMap, isTrue);
    });

    test('Keep and accept pressed reverses decline and accepts', () async {
      bloc.add(const DriverRequestDeclinePressed());
      bloc.add(const DriverRequestKeepAndAcceptPressed());
      expect(bloc.state.status, DriverRequestStatus.securingDispatch);

      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.shouldNavigateToTrip, isTrue);
    });

    test('State forcing via QA Matrix works for all 7 states', () {
      for (final status in DriverRequestStatus.values) {
        bloc.add(DriverRequestStateForced(status));
        expect(bloc.state.status, status);
      }
    });

    test('State forcing sets appropriate models for scheduled state', () {
      bloc.add(const DriverRequestStateForced(DriverRequestStatus.scheduled));
      expect(bloc.state.status, DriverRequestStatus.scheduled);
      expect(bloc.state.request.isScheduled, isTrue);
      expect(bloc.state.request.dropoffAddress, 'Lethbridge Airport (YQL)');
      expect(bloc.state.request.fareCad, 34.50);
    });

    test('State forcing sets appropriate models for taken by another driver', () {
      bloc.add(const DriverRequestStateForced(DriverRequestStatus.takenByAnother));
      expect(bloc.state.status, DriverRequestStatus.takenByAnother);
      expect(bloc.state.queueInfo.winningUnit, contains('Unit 18'));
      expect(bloc.state.queueInfo.queuePosition, 1);
    });
  });
}
