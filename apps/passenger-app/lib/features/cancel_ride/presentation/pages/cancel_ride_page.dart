import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/cancel_ride_bloc.dart';
import '../bloc/cancel_ride_event.dart';
import '../bloc/cancel_ride_state.dart';
import '../../data/models/cancel_ride_config.dart';
import '../../data/models/cancel_ride_models.dart';
import '../../data/repositories/cancel_ride_repository.dart';
import '../widgets/cancel_in_progress_sheet.dart';
import '../widgets/cancel_success_banner.dart';
import '../widgets/cannot_cancel_sheet.dart';
import '../widgets/confirm_cancel_sheet.dart';

class CancelRidePage extends StatelessWidget {
  final CancellationDetails? details;
  final bool? isTripStarted;
  final CancelRideRepository? repository;

  const CancelRidePage({
    super.key,
    this.details,
    this.isTripStarted,
    this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CancelRideBloc(
        repository: repository ?? MockCancelRideRepository(),
      )..add(CancelRideStarted(
          details: details,
          isTripStarted: isTripStarted,
        )),
      child: const _CancelRideView(),
    );
  }
}

class _CancelRideView extends StatelessWidget {
  const _CancelRideView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CancelRideBloc, CancelRideState>(
      listenWhen: (previous, current) {
        return previous.navigateBack != current.navigateBack ||
            previous.navigateToHome != current.navigateToHome ||
            previous.navigateToTrip != current.navigateToTrip;
      },
      listener: (context, state) {
        if (state.navigateBack) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/tracking');
          }
        }
        if (state.navigateToTrip) {
          context.go('/tracking');
        }
        if (state.navigateToHome) {
          context.go('/home');
        }
      },
      builder: (context, state) {
        Widget contentSheet;

        if (state.status == CancelRideStatus.cannotCancel) {
          contentSheet = CannotCancelSheet(
            details: state.details,
            onBackToTrip: () {
              context
                  .read<CancelRideBloc>()
                  .add(const CancelRideBackToTripTapped());
            },
            onCallDispatch: () {
              context
                  .read<CancelRideBloc>()
                  .add(const CancelRideEmergencyCallTapped());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Calling Bridge City Dispatch at ${CancelRideConfig.dispatchPhoneNumber}'),
                ),
              );
            },
          );
        } else if (state.status == CancelRideStatus.cancelling) {
          contentSheet = CancelInProgressSheet(
            details: state.details,
          );
        } else {
          // Default confirm cancel
          contentSheet = ConfirmCancelSheet(
            details: state.details,
            onReasonSelected: (reason) {
              context
                  .read<CancelRideBloc>()
                  .add(CancelRideReasonSelected(reason));
            },
            onKeepRide: () {
              context
                  .read<CancelRideBloc>()
                  .add(const CancelRideDismissed());
            },
            onConfirmCancel: () {
              context
                  .read<CancelRideBloc>()
                  .add(const CancelRideConfirmed());
            },
          );
        }

        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.55),
          body: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Stack(
              children: [
                // Top Success Toast if cancelled
                if (state.showSuccessBanner)
                  Positioned(
                    top: 40,
                    left: 0,
                    right: 0,
                    child: CancelSuccessBanner(
                      onDismiss: () {
                        context
                            .read<CancelRideBloc>()
                            .add(const CancelRideSuccessBannerDismissed());
                      },
                    ),
                  ),

                // Pinned Bottom Sheet
                Align(
                  alignment: Alignment.bottomCenter,
                  child: contentSheet,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
