import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/sos_alert_bloc.dart';
import '../bloc/sos_alert_event.dart';
import '../bloc/sos_alert_state.dart';
import '../../data/models/sos_alert_model.dart';
import '../../data/repositories/sos_alert_repository.dart';
import '../widgets/sos_active_alert_card.dart';
import '../widgets/sos_app_bar.dart';
import '../widgets/sos_confirmation_card.dart';
import '../widgets/sos_safety_line_card.dart';
import '../widgets/sos_warning_banners.dart';

class SosAlertPage extends StatelessWidget {
  final SosAlertRepository? repository;
  final SosRideTelemetry? initialTelemetry;
  final SosAlertStatus? initialStatus;
  final bool? locationEnabled;
  final bool? simulateNetworkFailure;

  const SosAlertPage({
    super.key,
    this.repository,
    this.initialTelemetry,
    this.initialStatus,
    this.locationEnabled,
    this.simulateNetworkFailure,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final repo = repository ??
            MockSosAlertRepository(
              telemetry: initialTelemetry,
              locationEnabled: locationEnabled ?? true,
              simulateNetworkFailure: simulateNetworkFailure ?? false,
            );
        return SosAlertBloc(repository: repo)
          ..add(SosAlertStarted(
            telemetry: initialTelemetry,
            locationEnabled: locationEnabled,
            simulateNetworkFailure: simulateNetworkFailure,
            initialStatus: initialStatus,
          ));
      },
      child: const _SosAlertView(),
    );
  }
}

class _SosAlertView extends StatelessWidget {
  const _SosAlertView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SosAlertBloc, SosAlertState>(
      listener: (context, state) {
        if (state.userFeedbackMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.userFeedbackMessage!),
              duration: const Duration(seconds: 2),
              backgroundColor: state.isActive
                  ? const Color(0xFF059669)
                  : const Color(0xFF1F2937),
            ),
          );
        }

        if (state.isCancelled) {
          Navigator.of(context).maybePop();
        }
      },
      builder: (context, state) {
        final bloc = context.read<SosAlertBloc>();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: SosAppBar(
            isActive: state.isActive,
            onBack: () => Navigator.of(context).maybePop(),
            onCallSafetyLine: () => bloc.add(const SosAlertCallSafetyLineTapped()),
          ),
          body: SafeArea(
            child: Column(
              children: [
                SosStatusRibbon(
                  isActive: state.isActive,
                  routeStatus: state.telemetry.routeStatus,
                ),

                // Warning Banners
                if (state.shouldShowLocationWarning)
                  SosLocationWarningBanner(
                    onOpenSettings: () =>
                        bloc.add(const SosAlertLocationSettingsOpened()),
                    onSendAnyway: () =>
                        bloc.add(const SosAlertSendAnywayTapped()),
                  ),

                if (state.shouldShowConnectionWarning)
                  SosConnectionFailureBanner(
                    onRetry: () => bloc.add(const SosAlertRetryTapped()),
                    customMessage: state.networkErrorMessage,
                  ),

                // Main Content
                Expanded(
                  child: state.isActive
                      ? SosActiveAlertCard(
                          telemetry: state.telemetry,
                          formattedSentTime: state.formattedSentTime,
                          beaconPingCount: state.beaconPingCount,
                          isUpdatingLocation: state.isUpdatingLocation,
                          onSendLocationAgain: () =>
                              bloc.add(const SosAlertUpdateLocationTapped()),
                          onBackToTrip: () {
                            bloc.add(const SosAlertBackToTripTapped());
                            Navigator.of(context).maybePop();
                          },
                          onCall911: () =>
                              bloc.add(const SosAlertCall911Tapped()),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              SosConfirmationCard(
                                telemetry: state.telemetry,
                                isSending: state.isSending,
                                onSend: () =>
                                    bloc.add(const SosAlertSendTapped()),
                                onCancel: () =>
                                    bloc.add(const SosAlertCancelTapped()),
                                onCall911: () =>
                                    bloc.add(const SosAlertCall911Tapped()),
                              ),
                              SosSafetyLineCard(
                                onCall: () =>
                                    bloc.add(const SosAlertCallSafetyLineTapped()),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
