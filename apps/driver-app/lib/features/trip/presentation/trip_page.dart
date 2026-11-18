import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/driver_trip_bloc.dart';
import '../bloc/driver_trip_event.dart';
import '../bloc/driver_trip_state.dart';
import '../data/models/driver_trip_status.dart';
import '../data/repositories/driver_trip_repository.dart';
import 'widgets/driver_trip_cancel_modal.dart';
import 'widgets/driver_trip_emergency_modal.dart';
import 'widgets/driver_trip_end_modal.dart';
import 'widgets/driver_trip_heading_sheet.dart';
import 'widgets/driver_trip_map_view.dart';
import 'widgets/driver_trip_navigation_sheet.dart';
import 'widgets/driver_trip_qa_bar.dart';
import 'widgets/driver_trip_telemetry_banner.dart';
import 'widgets/driver_trip_top_bar.dart';
import 'widgets/driver_trip_waiting_sheet.dart';

class DriverTripPage extends StatelessWidget {
  final DriverTripRepository? repository;
  final DriverTripStatus? initialStatus;

  const DriverTripPage({
    super.key,
    this.repository,
    this.initialStatus,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverTripBloc(
        repository: repository ?? FakeDriverTripRepository(),
        initialStatus: initialStatus ?? DriverTripStatus.headingToPickup,
      )..add(const DriverTripStarted()),
      child: const _DriverTripView(),
    );
  }
}

class _DriverTripView extends StatefulWidget {
  const _DriverTripView();

  @override
  State<_DriverTripView> createState() => _DriverTripViewState();
}

class _DriverTripViewState extends State<_DriverTripView> {
  Timer? _waitTicker;

  @override
  void dispose() {
    _waitTicker?.cancel();
    super.dispose();
  }

  void _manageTimer(DriverTripState state) {
    if (state.status == DriverTripStatus.waitingForPassenger) {
      if (_waitTicker == null || !_waitTicker!.isActive) {
        _waitTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
          final bloc = context.read<DriverTripBloc>();
          bloc.add(
            DriverTripWaitTimerTicked(
              bloc.state.trip.waitTimeElapsedSeconds + 1,
            ),
          );
        });
      }
    } else {
      _waitTicker?.cancel();
      _waitTicker = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverTripBloc, DriverTripState>(
      listener: (context, state) {
        _manageTimer(state);

        if (state.toastMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.toastMessage!),
              duration: const Duration(seconds: 3),
              backgroundColor: state.toastMessage == 'Trip canceled'
                  ? const Color(0xFFBA0C2F)
                  : const Color(0xFF1E293B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }

        if (state.isCanceledAndReturning) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (context.mounted) {
              if (GoRouter.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            }
          });
        }

        if (state.isTripEndedAndSummarizing) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (context.mounted) {
              context.go('/trip-summary');
            }
          });
        }
      },
      builder: (context, state) {
        final bloc = context.read<DriverTripBloc>();
        final showTopHeaderBar = state.status == DriverTripStatus.onTrip ||
            state.status == DriverTripStatus.endTripModal;

        return Scaffold(
          appBar: showTopHeaderBar
              ? AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                  title: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BRIDGE CITY CABS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFBA0C2F),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Active Trip Navigation',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFBA0C2F),
                        child: const Icon(
                          Icons.person,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              : null,
          body: Stack(
            children: [
              // 1. Live Interactive Map Canvas
              Positioned.fill(
                child: DriverTripMapView(
                  status: state.status,
                  trip: state.trip,
                ),
              ),

              // 2. Top Bar (GPS, Status Pill, Safety Shield)
              if (state.status != DriverTripStatus.telemetryAlert)
                SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: DriverTripTopBar(
                      status: state.status,
                      trip: state.trip,
                      onGpsPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Centered on current driver location'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      onSafetyPressed: () {
                        bloc.add(const DriverTripEmergencySosRequested());
                      },
                    ),
                  ),
                ),

              // 3. QA Bar (Fixed floating preview switcher)
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: DriverTripQaBar(
                      currentStatus: state.status,
                      onStatusSelected: (status) {
                        bloc.add(DriverTripStateForced(status));
                      },
                    ),
                  ),
                ),
              ),

              // 4. Telemetry Alert Full-Overlay View
              if (state.status == DriverTripStatus.telemetryAlert)
                SafeArea(
                  child: DriverTripTelemetryBanner(
                    trip: state.trip,
                    onTabSelected: (tab) {
                      bloc.add(DriverTripTelemetryTabSelected(tab));
                    },
                    onTapWhenArrivedPressed: () {
                      bloc.add(
                        const DriverTripArrivedPressed(bypassProximity: true),
                      );
                    },
                  ),
                ),

              // 5. Heading to Pickup Bottom Sheet (Screen 1 from previous turn)
              if (state.status == DriverTripStatus.headingToPickup)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: DriverTripHeadingSheet(
                    trip: state.trip,
                    onNavigatePressed: () {
                      bloc.add(const DriverTripExternalNavigationPressed());
                    },
                    onArrivedPressed: () {
                      bloc.add(
                        const DriverTripArrivedPressed(bypassProximity: true),
                      );
                    },
                    onCancelPressed: () {
                      bloc.add(const DriverTripCancelRequested());
                    },
                  ),
                ),

              // 6. Waiting for Passenger Bottom Sheet (Screen 2 from previous turn)
              if (state.status == DriverTripStatus.waitingForPassenger)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: DriverTripWaitingSheet(
                    trip: state.trip,
                    onStartTripPressed: () {
                      bloc.add(const DriverTripStartTripPressed());
                    },
                    onPassengerNotHerePressed: () {
                      bloc.add(const DriverTripPassengerNotHerePressed());
                    },
                    onCancelPressed: () {
                      bloc.add(const DriverTripCancelRequested());
                    },
                  ),
                ),

              // 7. Active Trip Navigation In-Progress Sheet (Screenshot 1)
              if (state.status == DriverTripStatus.onTrip)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: DriverTripNavigationSheet(
                    trip: state.trip,
                    onNavigateDropoffPressed: () {
                      bloc.add(const DriverTripExternalNavigationPressed());
                    },
                    onEndTripPressed: () {
                      bloc.add(const DriverTripEndTripRequested());
                    },
                  ),
                ),

              // 8. End Trip Early / Confirmation Modal Overlay (Screenshot 2)
              if (state.status == DriverTripStatus.endTripModal)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: DriverTripEndModal(
                        trip: state.trip,
                        onProximityModeChanged: (mode) {
                          bloc.add(DriverTripProximityModeToggled(mode));
                        },
                        onEndTripConfirmed: () {
                          bloc.add(const DriverTripEndTripConfirmed());
                        },
                        onCancelPressed: () {
                          bloc.add(
                            const DriverTripStateForced(DriverTripStatus.onTrip),
                          );
                        },
                      ),
                    ),
                  ),
                ),

              // 9. Cancel Trip Reason Modal Overlay
              if (state.status == DriverTripStatus.cancelTripModal)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: DriverTripCancelModal(
                        trip: state.trip,
                        onReasonSelected: (reason) {
                          bloc.add(DriverTripCancelReasonSelected(reason));
                        },
                        onKeepTripPressed: () {
                          bloc.add(const DriverTripKeepTripPressed());
                        },
                        onConfirmCancelPressed: () {
                          bloc.add(const DriverTripCancelConfirmed());
                        },
                      ),
                    ),
                  ),
                ),

              // 10. Critical Emergency SOS Sheet (Screenshot 5 State 5)
              if (state.status == DriverTripStatus.emergencySosModal)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.6),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: DriverTripEmergencyModal(
                        onSendSosPressed: () {
                          bloc.add(const DriverTripEmergencySosTriggered());
                        },
                        onCancelPressed: () {
                          bloc.add(const DriverTripEmergencySosCancelled());
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
