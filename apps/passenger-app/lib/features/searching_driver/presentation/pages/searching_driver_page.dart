import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/searching_driver_bloc.dart';
import '../bloc/searching_driver_event.dart';
import '../bloc/searching_driver_state.dart';
import '../../data/models/driver_search_models.dart';
import '../../data/models/searching_driver_config.dart';
import '../../data/repositories/searching_driver_repository.dart';
import '../widgets/reconnecting_banner.dart';
import '../widgets/searching_bottom_sheet.dart';
import '../widgets/searching_header_bar.dart';
import '../widgets/searching_map_canvas.dart';

class SearchingDriverPage extends StatelessWidget {
  final SearchBookingDetails? booking;
  final SearchingDriverRepository? repository;

  const SearchingDriverPage({
    super.key,
    this.booking,
    this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchingDriverBloc(
        repository: repository ?? MockSearchingDriverRepository(),
      )..add(SearchingDriverStarted(booking: booking)),
      child: const _SearchingDriverView(),
    );
  }
}

class _SearchingDriverView extends StatelessWidget {
  const _SearchingDriverView();

  void _showSafetyToolkit(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.shield, color: Color(0xFFC62828)),
                  SizedBox(width: 8),
                  Text(
                    'Safety Toolkit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.share, color: Color(0xFF1F1F1F)),
                title: const Text('Share trip status'),
                subtitle: const Text('Send live radar tracking to family or friends'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Trip share link ready')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.call, color: Color(0xFFC62828)),
                title: const Text('Emergency Assistance (911)'),
                subtitle: const Text('Call Lethbridge Police & Emergency Services'),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Cancel ride?'),
        content: const Text(
          'Are you sure you want to stop searching for nearby Bridge City drivers? There is no charge for cancelling.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context
                  .read<SearchingDriverBloc>()
                  .add(const SearchingDriverCancelDismissed());
            },
            child: const Text('Keep searching'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context
                  .read<SearchingDriverBloc>()
                  .add(const SearchingDriverCancelConfirmed());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
            ),
            child: const Text('Cancel ride', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SearchingDriverBloc, SearchingDriverState>(
      listenWhen: (previous, current) {
        return previous.navigateToTracking != current.navigateToTracking ||
            previous.navigateToHome != current.navigateToHome ||
            previous.isCopiedToClipboard != current.isCopiedToClipboard ||
            previous.showCancelDialog != current.showCancelDialog;
      },
      listener: (context, state) {
        if (state.navigateToTracking) {
          if (context.mounted) {
            context.go('/tracking');
          }
        }
        if (state.navigateToHome) {
          if (context.mounted) {
            context.go('/home');
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
        if (state.showCancelDialog) {
          _showCancelConfirmation(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              // 1. Background Interactive Map Canvas
              Positioned.fill(
                child: SearchingMapCanvas(
                  status: state.status,
                  isReconnecting: state.isReconnecting,
                  booking: state.booking,
                ),
              ),

              // 2. Top Header & Reconnecting Alert
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SearchingHeaderBar(
                      title: state.appBarTitle,
                      showSafety: !state.booking.isScheduled,
                      onRecenter: () {
                        context
                            .read<SearchingDriverBloc>()
                            .add(const SearchingDriverRecenterTapped());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Map centered on pickup location'),
                            duration: Duration(milliseconds: 1000),
                          ),
                        );
                      },
                      onSafety: () => _showSafetyToolkit(context),
                    ),
                    if (state.isReconnecting)
                      ReconnectingBanner(
                        signalStrength: state.signalStrength,
                      ),
                  ],
                ),
              ),

              // 3. Pinned Bottom Sheet
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SearchingBottomSheet(
                  status: state.status,
                  booking: state.booking,
                  isReconnecting: state.isReconnecting,
                  connectingSecondsRemaining: state.connectingSecondsRemaining,
                  isSubmittingCancel: state.isSubmittingCancel,
                  onCancel: () {
                    context
                        .read<SearchingDriverBloc>()
                        .add(const SearchingDriverCancelRequested());
                  },
                  onCopyTrackingId: () {
                    context
                        .read<SearchingDriverBloc>()
                        .add(const SearchingDriverCopyTrackingIdTapped());
                  },
                  onCallDispatch: () {
                    context
                        .read<SearchingDriverBloc>()
                        .add(const SearchingDriverCallDispatchTapped());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Calling Bridge City Dispatch at ${SearchingDriverConfig.dispatchPhoneNumber}'),
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
