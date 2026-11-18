import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/driver_support_bloc.dart';
import '../bloc/driver_support_event.dart';
import '../bloc/driver_support_state.dart';
import '../data/models/driver_support_status.dart';
import '../data/repositories/driver_support_repository.dart';
import 'widgets/driver_support_center_view.dart';
import 'widgets/driver_support_emergency_modal.dart';
import 'widgets/driver_support_my_tickets_view.dart';
import 'widgets/driver_support_new_ticket_view.dart';
import 'widgets/driver_support_qa_bar.dart';
import 'widgets/driver_support_ticket_detail_view.dart';

class DriverSupportPage extends StatelessWidget {
  final DriverSupportRepository? repository;
  final DriverSupportViewStatus? initialStatus;

  const DriverSupportPage({
    super.key,
    this.repository,
    this.initialStatus,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverSupportBloc(
        repository: repository ?? FakeDriverSupportRepository(),
        initialStatus: initialStatus ?? DriverSupportViewStatus.center,
      )..add(const DriverSupportStarted()),
      child: const _DriverSupportPageView(),
    );
  }
}

class _DriverSupportPageView extends StatelessWidget {
  const _DriverSupportPageView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverSupportBloc, DriverSupportState>(
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
          context.read<DriverSupportBloc>().add(const DriverSupportClearToast());
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
                if (state.viewStatus != DriverSupportViewStatus.center) {
                  context.read<DriverSupportBloc>().add(
                        const DriverSupportSwitchView(DriverSupportViewStatus.center),
                      );
                } else if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go('/home');
                }
              },
            ),
            title: Text(
              _getTitle(state.viewStatus),
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
              DriverSupportQaBar(currentStatus: state.viewStatus),
              Expanded(
                child: _buildBody(state),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTitle(DriverSupportViewStatus status) {
    switch (status) {
      case DriverSupportViewStatus.center:
        return 'Support Center';
      case DriverSupportViewStatus.newTicket:
        return 'New Ticket';
      case DriverSupportViewStatus.myTickets:
        return 'My Tickets';
      case DriverSupportViewStatus.ticketDetail:
        return 'Ticket Detail';
      case DriverSupportViewStatus.emergencySos:
        return 'Emergency SOS';
    }
  }

  Widget _buildBody(DriverSupportState state) {
    switch (state.viewStatus) {
      case DriverSupportViewStatus.center:
        return DriverSupportCenterView(state: state);
      case DriverSupportViewStatus.newTicket:
        return DriverSupportNewTicketView(state: state);
      case DriverSupportViewStatus.myTickets:
        return DriverSupportMyTicketsView(state: state);
      case DriverSupportViewStatus.ticketDetail:
        return DriverSupportTicketDetailView(state: state);
      case DriverSupportViewStatus.emergencySos:
        return Stack(
          children: [
            Container(color: Colors.black45),
            Align(
              alignment: Alignment.bottomCenter,
              child: DriverSupportEmergencyModal(state: state),
            ),
          ],
        );
    }
  }
}
