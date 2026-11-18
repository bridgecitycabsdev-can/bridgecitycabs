import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/live_tracking_bloc.dart';
import '../bloc/live_tracking_event.dart';
import '../bloc/live_tracking_state.dart';
import '../../data/models/live_tracking_config.dart';
import '../../data/models/tracking_models.dart';
import '../../data/repositories/live_tracking_repository.dart';
import '../widgets/arriving_alert_banner.dart';
import '../widgets/live_tracking_header.dart';
import '../widgets/live_tracking_map_canvas.dart';
import '../widgets/live_tracking_sheet.dart';
import '../widgets/telemetry_sync_banner.dart';

class LiveTrackingPage extends StatelessWidget {
  final TrackingTripDetails? trip;
  final TrackingDriverInfo? driver;
  final LiveTrackingStatus? initialStatus;
  final LiveTrackingRepository? repository;

  const LiveTrackingPage({
    super.key,
    this.trip,
    this.driver,
    this.initialStatus,
    this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LiveTrackingBloc(
        repository: repository ?? MockLiveTrackingRepository(),
      )..add(LiveTrackingStarted(
          trip: trip,
          driver: driver,
          initialStatus: initialStatus,
        )),
      child: const _LiveTrackingView(),
    );
  }
}

class _LiveTrackingView extends StatelessWidget {
  const _LiveTrackingView();

  void _showSafetyModal(BuildContext context) {
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
                    'Safety & Emergency',
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
                title: const Text('Share live tracking'),
                subtitle: const Text('Send live ride telemetry to contacts'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tracking link copied')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.call, color: Color(0xFFC62828)),
                title: const Text('Emergency Assistance (911)'),
                subtitle: const Text('Contact Lethbridge emergency services'),
                onTap: () {
                  Navigator.pop(ctx);
                  context
                      .read<LiveTrackingBloc>()
                      .add(const LiveTrackingCall911Tapped());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Cancel ride?'),
        content: const Text(
          'Are you sure you want to cancel your ride with Michael?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context
                  .read<LiveTrackingBloc>()
                  .add(const LiveTrackingCancelDismissed());
            },
            child: const Text('Keep ride'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context
                  .read<LiveTrackingBloc>()
                  .add(const LiveTrackingCancelConfirmed());
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
    return BlocConsumer<LiveTrackingBloc, LiveTrackingState>(
      listenWhen: (previous, current) {
        return previous.navigateToHome != current.navigateToHome ||
            previous.navigateToReceipt != current.navigateToReceipt ||
            previous.isCopiedToClipboard != current.isCopiedToClipboard ||
            previous.showCancelDialog != current.showCancelDialog ||
            previous.showSafetyToolkit != current.showSafetyToolkit;
      },
      listener: (context, state) {
        if (state.navigateToHome) {
          if (context.mounted) {
            context.go('/home');
          }
        }
        if (state.navigateToReceipt) {
          if (context.mounted) {
            context.go('/receipt');
          }
        }
        if (state.isCopiedToClipboard) {
          Clipboard.setData(ClipboardData(text: state.trip.trackingId));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tracking ID ${state.trip.trackingId} copied'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        if (state.showCancelDialog) {
          _showCancelDialog(context);
        }
        if (state.showSafetyToolkit) {
          _showSafetyModal(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              // 1. Background Interactive Map Canvas
              Positioned.fill(
                child: LiveTrackingMapCanvas(
                  status: state.status,
                  trip: state.trip,
                  isTelemetrySyncing: state.isTelemetrySyncing,
                ),
              ),

              // 2. Floating Header & Top Banners
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LiveTrackingHeader(
                      pillText: state.pillText,
                      pillDotColor: state.pillDotColor,
                      isSosTriggered: state.isSosTriggered,
                      onSafety: () => _showSafetyModal(context),
                      onRecenter: () {
                        context
                            .read<LiveTrackingBloc>()
                            .add(const LiveTrackingRecenterTapped());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Map centered on vehicle'),
                            duration: Duration(milliseconds: 1000),
                          ),
                        );
                      },
                    ),
                    if (state.isTelemetrySyncing) const TelemetrySyncBanner(),
                    if (state.isSosTriggered)
                      const ArrivingAlertBanner(isSosSent: true),
                  ],
                ),
              ),

              // 3. Pinned Bottom Sheet
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: LiveTrackingSheet(
                  status: state.status,
                  trip: state.trip,
                  driver: state.driver,
                  isSosTriggered: state.isSosTriggered,
                  isTelemetrySyncing: state.isTelemetrySyncing,
                  onCancelRide: () {
                    context
                        .read<LiveTrackingBloc>()
                        .add(const LiveTrackingCancelRideTapped());
                  },
                  onTriggerSos: () {
                    context
                        .read<LiveTrackingBloc>()
                        .add(const LiveTrackingSosTriggered());
                  },
                  onCancelSos: () {
                    context
                        .read<LiveTrackingBloc>()
                        .add(const LiveTrackingSosCancelled());
                  },
                  onCall911: () {
                    context
                        .read<LiveTrackingBloc>()
                        .add(const LiveTrackingCall911Tapped());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Calling Emergency Services at ${LiveTrackingConfig.emergencyPhoneNumber}'),
                      ),
                    );
                  },
                  onCopyTrackingId: () {
                    context
                        .read<LiveTrackingBloc>()
                        .add(const LiveTrackingCopyTrackingIdTapped());
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
