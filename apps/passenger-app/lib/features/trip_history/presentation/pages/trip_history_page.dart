import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/trip_history_bloc.dart';
import '../bloc/trip_history_event.dart';
import '../bloc/trip_history_state.dart';
import '../../data/models/trip_history_model.dart';
import '../../data/repositories/trip_history_repository.dart';
import '../widgets/coming_soon_past_trips_card.dart';
import '../widgets/last_trip_summary_card.dart';
import '../widgets/trip_history_app_bar.dart';
import 'trip_fare_breakdown_page.dart';

class TripHistoryPage extends StatelessWidget {
  final TripHistoryRepository? repository;
  final TripRecord? initialTrip;

  const TripHistoryPage({
    super.key,
    this.repository,
    this.initialTrip,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final repo = repository ??
            MockTripHistoryRepository(initialLastTrip: initialTrip);
        return TripHistoryBloc(repository: repo)
          ..add(TripHistoryStarted(tripId: initialTrip?.tripId));
      },
      child: const _TripHistoryView(),
    );
  }
}

class _TripHistoryView extends StatelessWidget {
  const _TripHistoryView();

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

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: TripHistoryAppBar(
            title: 'Trip Fare Breakdown',
            onBack: () => Navigator.of(context).maybePop(),
            onProfileTapped: () => context.push('/profile'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LastTripSummaryCard(
                    trip: state.lastTrip,
                    onViewDetails: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: bloc,
                            child: TripFareBreakdownPage(
                              tripId: state.lastTrip.tripId,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  ComingSoonPastTripsCard(
                    onOpenNotifications: () => context.push('/notifications'),
                    onContactSupport: () => context.push('/support'),
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
