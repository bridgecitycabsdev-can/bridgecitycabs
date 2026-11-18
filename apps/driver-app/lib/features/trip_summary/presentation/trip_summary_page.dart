import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/driver_trip_summary_bloc.dart';
import '../bloc/driver_trip_summary_event.dart';
import '../bloc/driver_trip_summary_state.dart';
import '../data/models/driver_trip_summary_status.dart';
import '../data/repositories/driver_trip_summary_repository.dart';
import 'widgets/driver_edge_states_gallery.dart';
import 'widgets/driver_rate_passenger_modal.dart';
import 'widgets/driver_trip_summary_card_view.dart';
import 'widgets/driver_trip_summary_cash_view.dart';
import 'widgets/driver_trip_summary_qa_bar.dart';

class DriverTripSummaryPage extends StatelessWidget {
  final DriverTripSummaryRepository? repository;
  final DriverTripSummaryStatus? initialStatus;

  const DriverTripSummaryPage({
    super.key,
    this.repository,
    this.initialStatus,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverTripSummaryBloc(
        repository: repository ?? FakeDriverTripSummaryRepository(),
        initialStatus: initialStatus ?? DriverTripSummaryStatus.cardSettled,
      )..add(const DriverTripSummaryStarted()),
      child: const _DriverTripSummaryView(),
    );
  }
}

class _DriverTripSummaryView extends StatelessWidget {
  const _DriverTripSummaryView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverTripSummaryBloc, DriverTripSummaryState>(
      listener: (context, state) {
        if (state.toastMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.toastMessage!),
              duration: const Duration(seconds: 3),
              backgroundColor: const Color(0xFF1E293B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }

        if (state.isReturnedToDispatch) {
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
      },
      builder: (context, state) {
        final bloc = context.read<DriverTripSummaryBloc>();

        return Scaffold(
          backgroundColor: const Color(0xFFFBF9F8),
          appBar: AppBar(
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
                  'Trip Summary & Fare Breakdown',
                  style: TextStyle(
                    fontSize: 14,
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
          ),
          body: Stack(
            children: [
              // 1. Content View
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(top: 52),
                  child: Builder(
                    builder: (context) {
                      switch (state.status) {
                        case DriverTripSummaryStatus.cardSettled:
                          return DriverTripSummaryCardView(
                            summary: state.summary,
                            onDonePressed: () {
                              bloc.add(
                                const DriverTripSummaryDoneReturnPressed(),
                              );
                            },
                            onViewReceiptPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Opening PDF tax receipt...'),
                                ),
                              );
                            },
                            onTripIssuePressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Dispatch ticket logged for Trip #BC-123456',
                                  ),
                                ),
                              );
                            },
                          );

                        case DriverTripSummaryStatus.cashDue:
                          return DriverTripSummaryCashView(
                            summary: state.summary,
                            onCashCollectedPressed: () {
                              bloc.add(
                                const DriverTripSummaryCashCollectedPressed(),
                              );
                            },
                            onProblemPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Contacting Lethbridge Dispatch supervisor...',
                                  ),
                                ),
                              );
                            },
                          );

                        case DriverTripSummaryStatus.ratePassenger:
                          return SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: DriverRatePassengerModal(
                              ratingModel: state.summary.ratingModel,
                              onRatingChanged: (rating) {
                                bloc.add(
                                  DriverTripSummaryRatingChanged(rating),
                                );
                              },
                              onTagToggled: (tag) {
                                bloc.add(DriverTripSummaryTagToggled(tag));
                              },
                              onNotesChanged: (notes) {
                                bloc.add(
                                  DriverTripSummaryFeedbackNotesChanged(notes),
                                );
                              },
                              onSubmitRatingPressed: () {
                                bloc.add(
                                  const DriverTripSummaryRatingSubmitted(),
                                );
                              },
                              onSkipPressed: () {
                                bloc.add(
                                  const DriverTripSummaryRatingSkipped(),
                                );
                              },
                            ),
                          );

                        case DriverTripSummaryStatus.edgeStatesGallery:
                          return DriverEdgeStatesGallery(
                            onRetryPressed: () {
                              bloc.add(
                                const DriverTripSummaryRetryPaymentPressed(),
                              );
                            },
                          );

                        case DriverTripSummaryStatus.returnedToDispatch:
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                      }
                    },
                  ),
                ),
              ),

              // 2. QA Bar (Fixed top preview switcher)
              Positioned(
                top: 8,
                left: 16,
                right: 16,
                child: Center(
                  child: DriverTripSummaryQaBar(
                    currentStatus: state.status,
                    onStatusSelected: (status) {
                      bloc.add(DriverTripSummaryStateForced(status));
                    },
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
