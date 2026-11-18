import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/driver_flag_ride_bloc.dart';
import '../bloc/driver_flag_ride_event.dart';
import '../bloc/driver_flag_ride_state.dart';
import '../data/models/driver_flag_ride_status.dart';
import '../data/repositories/driver_flag_ride_repository.dart';
import 'widgets/driver_flag_complete_view.dart';
import 'widgets/driver_flag_edge_states_view.dart';
import 'widgets/driver_flag_in_progress_view.dart';
import 'widgets/driver_flag_qa_bar.dart';
import 'widgets/driver_flag_start_view.dart';

class DriverFlagRidePage extends StatelessWidget {
  final DriverFlagRideRepository? repository;
  final DriverFlagRideStatus? initialStatus;

  const DriverFlagRidePage({
    super.key,
    this.repository,
    this.initialStatus,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverFlagRideBloc(
        repository: repository ?? FakeDriverFlagRideRepository(),
        initialStatus: initialStatus ?? DriverFlagRideStatus.startFlagRide,
      )..add(const DriverFlagRideStartedEvent()),
      child: const _DriverFlagRideView(),
    );
  }
}

class _DriverFlagRideView extends StatelessWidget {
  const _DriverFlagRideView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverFlagRideBloc, DriverFlagRideState>(
      listener: (context, state) {
        if (state.toastMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.toastMessage!),
              duration: const Duration(seconds: 3),
              backgroundColor: const Color(0xFF1E293B),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<DriverFlagRideBloc>().add(const DriverFlagClearToastEvent());
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF7F5F5),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go('/home');
                }
              },
            ),
            title: Text(
              _getTitle(state.status),
              style: const TextStyle(
                color: Color(0xFF1E1E1E),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: const Color(0xFF8B181B),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              DriverFlagQaBar(currentStatus: state.status),
              Expanded(
                child: _buildBody(state),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTitle(DriverFlagRideStatus status) {
    switch (status) {
      case DriverFlagRideStatus.startFlagRide:
        return 'Start A Flag Ride';
      case DriverFlagRideStatus.flagInProgress:
        return 'Flag Ride In Progress';
      case DriverFlagRideStatus.flagComplete:
        return 'Flag Ride Complete';
      case DriverFlagRideStatus.edgeStates:
        return 'Flag Ride Edge States';
    }
  }

  Widget _buildBody(DriverFlagRideState state) {
    switch (state.status) {
      case DriverFlagRideStatus.startFlagRide:
        return DriverFlagStartView(state: state);
      case DriverFlagRideStatus.flagInProgress:
        return DriverFlagInProgressView(state: state);
      case DriverFlagRideStatus.flagComplete:
        return DriverFlagCompleteView(state: state);
      case DriverFlagRideStatus.edgeStates:
        return DriverFlagEdgeStatesView(state: state);
    }
  }
}
