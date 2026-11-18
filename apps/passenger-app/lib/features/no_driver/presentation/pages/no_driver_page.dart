import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/no_driver_bloc.dart';
import '../bloc/no_driver_event.dart';
import '../bloc/no_driver_state.dart';
import '../../data/models/no_driver_config.dart';
import '../../data/models/no_driver_models.dart';
import '../../data/repositories/no_driver_repository.dart';
import '../widgets/no_driver_bottom_sheet.dart';
import '../widgets/no_driver_header_bar.dart';
import '../widgets/no_driver_map_canvas.dart';

class NoDriverPage extends StatelessWidget {
  final NoDriverBookingDetails? booking;
  final NoDriverRepository? repository;

  const NoDriverPage({
    super.key,
    this.booking,
    this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NoDriverBloc(
        repository: repository ?? MockNoDriverRepository(),
      )..add(NoDriverStarted(booking: booking)),
      child: const _NoDriverView(),
    );
  }
}

class _NoDriverView extends StatelessWidget {
  const _NoDriverView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NoDriverBloc, NoDriverState>(
      listenWhen: (previous, current) {
        return previous.navigateToHome != current.navigateToHome ||
            previous.navigateToOptions != current.navigateToOptions ||
            previous.navigateToTracking != current.navigateToTracking ||
            previous.isCopiedToClipboard != current.isCopiedToClipboard;
      },
      listener: (context, state) {
        if (state.navigateToHome) {
          if (context.mounted) {
            context.go('/home');
          }
        }
        if (state.navigateToOptions) {
          if (context.mounted) {
            context.go('/options');
          }
        }
        if (state.navigateToTracking) {
          if (context.mounted) {
            context.go('/tracking');
          }
        }
        if (state.isCopiedToClipboard) {
          Clipboard.setData(ClipboardData(text: state.booking.trackingId));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tracking ID ${state.booking.trackingId} copied'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              // 1. Background Interactive Map Canvas
              Positioned.fill(
                child: NoDriverMapCanvas(
                  status: state.status,
                  booking: state.booking,
                ),
              ),

              // 2. Floating Top Header Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: NoDriverHeaderBar(
                  title: state.appBarTitle,
                  showBackArrow: state.showBackArrow,
                  onBack: () {
                    context.read<NoDriverBloc>().add(const NoDriverBackTapped());
                  },
                  onRecenter: () {
                    context
                        .read<NoDriverBloc>()
                        .add(const NoDriverRecenterTapped());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Map centered on pickup location'),
                        duration: Duration(milliseconds: 1000),
                      ),
                    );
                  },
                ),
              ),

              // 3. Pinned Bottom Sheet
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: NoDriverBottomSheet(
                  status: state.status,
                  booking: state.booking,
                  onRetry: () {
                    context.read<NoDriverBloc>().add(const NoDriverRetryTapped());
                  },
                  onCancel: () {
                    context.read<NoDriverBloc>().add(const NoDriverCancelTapped());
                  },
                  onCopyTrackingId: () {
                    context
                        .read<NoDriverBloc>()
                        .add(const NoDriverCopyTrackingIdTapped());
                  },
                  onBookDifferentVehicle: () {
                    context
                        .read<NoDriverBloc>()
                        .add(const NoDriverBookDifferentVehicleTapped());
                  },
                  onCallDispatch: () {
                    context
                        .read<NoDriverBloc>()
                        .add(const NoDriverCallDispatchTapped());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Calling Bridge City Dispatch at ${NoDriverConfig.dispatchPhoneNumber}'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
