import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/past_trip_detail_bloc.dart';
import '../bloc/past_trip_detail_event.dart';
import '../bloc/past_trip_detail_state.dart';
import '../../data/repositories/past_trip_detail_repository.dart';
import '../widgets/past_trip_app_bar.dart';
import '../widgets/past_trips_coming_soon_card.dart';

class PastTripsHubPage extends StatelessWidget {
  const PastTripsHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PastTripDetailBloc(
        repository: PastTripDetailRepositoryImpl(),
      )..add(const PastTripDetailStarted()),
      child: const _PastTripsHubView(),
    );
  }
}

class _PastTripsHubView extends StatelessWidget {
  const _PastTripsHubView();

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
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: PastTripAppBar(
            title: 'Past Trips',
            onBack: () => Navigator.of(context).maybePop(),
            onProfileTapped: () => context.push('/profile'),
          ),
          body: SafeArea(
            child: PastTripsComingSoonCard(
              lastTrip: state.trip,
              onViewDetails: () => context.push('/past-trip-detail'),
              onOpenNotifications: () => context.push('/notifications'),
              onContactSupport: () => context.push('/support'),
            ),
          ),
        );
      },
    );
  }
}
