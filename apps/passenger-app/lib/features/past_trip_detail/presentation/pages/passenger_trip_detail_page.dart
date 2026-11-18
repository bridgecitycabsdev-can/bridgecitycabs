import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/past_trip_detail_bloc.dart';
import '../bloc/past_trip_detail_event.dart';
import '../bloc/past_trip_detail_state.dart';
import '../../data/models/past_trip_detail_model.dart';
import '../../data/repositories/past_trip_detail_repository.dart';
import '../widgets/book_return_action_bar.dart';
import '../widgets/driver_vehicle_card.dart';
import '../widgets/metered_fare_summary_card.dart';
import '../widgets/past_trip_app_bar.dart';
import '../widgets/qa_scenario_inspector_bar.dart';
import '../widgets/route_schematic_card.dart';
import '../widgets/trip_action_list_tiles.dart';
import '../widgets/trip_map_preview_card.dart';
import '../widgets/trip_payment_amount_card.dart';
import '../widgets/trip_segment_toggle_bar.dart';

class PassengerTripDetailPage extends StatelessWidget {
  final String? tripId;
  final TripDetailSegment? initialSegment;
  final PastTripQaScenario? initialScenario;

  const PassengerTripDetailPage({
    super.key,
    this.tripId,
    this.initialSegment,
    this.initialScenario,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PastTripDetailBloc(
        repository: PastTripDetailRepositoryImpl(),
      )..add(PastTripDetailStarted(
          tripId: tripId,
          initialSegment: initialSegment,
          initialScenario: initialScenario,
        )),
      child: const _PassengerTripDetailView(),
    );
  }
}

class _PassengerTripDetailView extends StatelessWidget {
  const _PassengerTripDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PastTripDetailBloc, PastTripDetailState>(
      listener: (context, state) {
        if (state.feedbackMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.feedbackMessage!),
              duration: const Duration(seconds: 2),
              backgroundColor: const Color(0xFF1F2937),
            ),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<PastTripDetailBloc>();
        final trip = state.trip;

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: PastTripAppBar(
            title: 'Passenger Trip Detail',
            onBack: () => Navigator.of(context).maybePop(),
            onProfileTapped: () => context.push('/profile'),
            onToggleMode: () => bloc.add(const PastTripDetailToggleViewMode()),
            isInspectorMode: state.isInspectorMode,
          ),
          bottomNavigationBar: state.isInspectorMode
              ? BookReturnActionBar(
                  isBookingReturn: state.isBookingReturn,
                  onGetReceipt: () => bloc.add(
                    PastTripDetailDownloadReceiptTapped(trip.tripId),
                  ),
                  onBookReturn: () => bloc.add(
                    PastTripDetailBookReturnTapped(trip),
                  ),
                )
              : null,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.isInspectorMode) ...[
                    // Screen 2: QA Scenario Inspector Mode
                    QaScenarioInspectorBar(
                      selectedScenario: state.selectedQaScenario,
                      onScenarioSelected: (sc) =>
                          bloc.add(PastTripDetailQaScenarioSelected(sc)),
                    ),
                    TripMapPreviewCard(trip: trip),
                    DriverVehicleCard(trip: trip, isCompact: true),
                    TripPaymentAmountCard(trip: trip),
                  ] else ...[
                    // Screen 1: Metered Regulatory Detail Mode
                    TripSegmentToggleBar(
                      selectedSegment: state.selectedSegment,
                      onSegmentChanged: (seg) =>
                          bloc.add(PastTripDetailSegmentChanged(seg)),
                    ),
                    RouteSchematicCard(
                      trip: trip,
                      onCopyTripId: () =>
                          bloc.add(PastTripDetailCopyTripIdTapped(trip.tripId)),
                    ),
                    DriverVehicleCard(trip: trip, isCompact: false),
                    MeteredFareSummaryCard(trip: trip),
                    TripActionListTiles(
                      isDownloadingPdf: state.isDownloadingPdf,
                      onRateDriver: () => context.push('/rate-driver'),
                      onDownloadReceipt: () => bloc.add(
                        PastTripDetailDownloadReceiptTapped(trip.tripId),
                      ),
                      onReportProblem: () => context.push('/support'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
