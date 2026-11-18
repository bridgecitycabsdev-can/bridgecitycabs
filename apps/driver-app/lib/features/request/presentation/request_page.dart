import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/driver_request_bloc.dart';
import '../bloc/driver_request_event.dart';
import '../bloc/driver_request_state.dart';
import '../data/models/driver_request_status.dart';
import '../data/repositories/driver_request_repository.dart';
import 'widgets/driver_request_decline_sheet.dart';
import 'widgets/driver_request_expired_dialog.dart';
import 'widgets/driver_request_instant_view.dart';
import 'widgets/driver_request_qa_bar.dart';
import 'widgets/driver_request_scheduled_view.dart';
import 'widgets/driver_request_securing_view.dart';
import 'widgets/driver_request_taken_dialog.dart';

class DriverRequestPage extends StatelessWidget {
  final DriverRequestRepository? repository;
  final DriverRequestStatus initialStatus;

  const DriverRequestPage({
    super.key,
    this.repository,
    this.initialStatus = DriverRequestStatus.incomingInstant,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverRequestBloc(
        repository: repository ?? FakeDriverRequestRepository(),
      )..add(DriverRequestStarted(initialStatus: initialStatus)),
      child: const _DriverRequestPageContent(),
    );
  }
}

class _DriverRequestPageContent extends StatelessWidget {
  const _DriverRequestPageContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverRequestBloc, DriverRequestState>(
      listenWhen: (previous, current) =>
          previous.shouldNavigateToTrip != current.shouldNavigateToTrip ||
          previous.shouldNavigateToMap != current.shouldNavigateToMap,
      listener: (context, state) {
        if (state.shouldNavigateToTrip) {
          if (context.mounted) {
            context.go('/trip');
          }
        } else if (state.shouldNavigateToMap) {
          if (context.mounted) {
            context.go('/home');
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              // Primary View Layer
              _buildActiveBody(context, state),

              // Modal Layer for Expired / Taken / Decline Confirmation
              if (state.status == DriverRequestStatus.expired)
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: DriverRequestExpiredDialog(impact: state.impact),
                  ),
                ),

              if (state.status == DriverRequestStatus.takenByAnother)
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: DriverRequestTakenDialog(queueInfo: state.queueInfo),
                  ),
                ),

              if (state.status == DriverRequestStatus.declineConfirmation)
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  alignment: Alignment.bottomCenter,
                  child: DriverRequestDeclineSheet(
                    impact: state.impact,
                    selectedReason: state.selectedReason,
                    remainingSeconds: state.request.remainingSeconds,
                  ),
                ),

              // QA Matrix Floating Switcher at top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: DriverRequestQABar(activeStatus: state.status),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveBody(BuildContext context, DriverRequestState state) {
    switch (state.status) {
      case DriverRequestStatus.incomingInstant:
        return DriverRequestInstantView(
          request: state.request,
          isUrgent: false,
        );
      case DriverRequestStatus.securingDispatch:
        return DriverRequestSecuringView(request: state.request);
      case DriverRequestStatus.expiringUrgent:
        return DriverRequestInstantView(
          request: state.request,
          isUrgent: true,
        );
      case DriverRequestStatus.scheduled:
        return DriverRequestScheduledView(request: state.request);
      case DriverRequestStatus.expired:
      case DriverRequestStatus.takenByAnother:
      case DriverRequestStatus.declineConfirmation:
        // Render the background request view behind the dialog or bottom sheet
        return DriverRequestInstantView(
          request: state.request,
          isUrgent: false,
        );
    }
  }
}
