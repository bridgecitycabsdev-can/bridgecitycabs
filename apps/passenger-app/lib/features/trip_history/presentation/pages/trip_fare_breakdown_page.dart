import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/trip_history_bloc.dart';
import '../bloc/trip_history_event.dart';
import '../bloc/trip_history_state.dart';
import '../../data/models/trip_history_model.dart';
import '../../data/repositories/trip_history_repository.dart';
import '../widgets/qa_scenario_selector_bar.dart';
import '../widgets/trip_driver_info_card.dart';
import '../widgets/trip_fare_metered_breakdown.dart';
import '../widgets/trip_history_app_bar.dart';
import '../widgets/trip_route_telemetry_card.dart';

class TripFareBreakdownPage extends StatelessWidget {
  final String? tripId;
  final TripHistoryRepository? repository;
  final TripPaymentScenario? initialScenario;

  const TripFareBreakdownPage({
    super.key,
    this.tripId,
    this.repository,
    this.initialScenario,
  });

  @override
  Widget build(BuildContext context) {
    try {
      context.read<TripHistoryBloc>();
      return _TripFareBreakdownView(tripId: tripId);
    } catch (_) {
      return BlocProvider(
        create: (context) {
          final repo = repository ?? MockTripHistoryRepository();
          return TripHistoryBloc(repository: repo)
            ..add(TripHistoryStarted(
              tripId: tripId,
              initialScenario: initialScenario,
            ));
        },
        child: _TripFareBreakdownView(tripId: tripId),
      );
    }
  }
}

class _TripFareBreakdownView extends StatelessWidget {
  final String? tripId;

  const _TripFareBreakdownView({this.tripId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TripHistoryBloc, TripHistoryState>(
      listener: (context, state) {
        if (state.feedbackMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.feedbackMessage!),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<TripHistoryBloc>();
        final trip = state.currentTrip;

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: TripHistoryAppBar(
            title: 'Trip Fare Breakdown',
            onBack: () => Navigator.of(context).maybePop(),
            onProfileTapped: () => context.push('/profile'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  QaScenarioSelectorBar(
                    selectedScenario: state.selectedScenario,
                    onScenarioSelected: (sc) =>
                        bloc.add(TripHistoryScenarioChanged(sc)),
                  ),
                  TripRouteTelemetryCard(trip: trip),
                  TripDriverInfoCard(trip: trip),
                  TripFareMeteredBreakdown(
                    trip: trip,
                    isDownloading: state.isDownloadingReceipt,
                    onRateDriver: () => context.push('/rate-driver'),
                    onDownloadReceipt: () => bloc.add(
                      TripHistoryDownloadReceiptTapped(trip.tripId),
                    ),
                    onReportProblem: () => context.push('/support'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
