import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/call_driver_bloc.dart';
import 'bloc/call_driver_event.dart';
import 'bloc/call_driver_state.dart';
import '../data/models/call_driver_model.dart';
import 'widgets/call_driver_app_bar.dart';
import 'widgets/call_driver_map_background.dart';
import 'widgets/call_outcome_fallback_sheet.dart';

class CallDriverOutcomePage extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onTryAgain;
  final VoidCallback? onClose;

  const CallDriverOutcomePage({
    super.key,
    this.onBack,
    this.onTryAgain,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CallDriverBloc, CallDriverState>(
      listener: (context, state) {
        if (state.feedbackMessage != null) {
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
        return Scaffold(
          backgroundColor: const Color(0xFFE5E7EB),
          appBar: CallDriverAppBar(
            title: 'Call Driver Options',
            onBack: () {
              if (onBack != null) {
                onBack!();
              } else {
                Navigator.of(context).maybePop();
              }
            },
            onProfileTapped: () {},
          ),
          body: Stack(
            children: [
              // Map background with Vehicle #104 En Route
              const CallDriverMapBackground(
                statusPillText: 'Vehicle #104 En Route • 3 min ETA',
                vehicleMarkerText: 'Michael • Silver Camry',
              ),

              // Top QA SCENARIO INSPECTOR bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildQaScenarioInspectorBar(context, state),
              ),

              // Bottom Sheet: Call outcome fallback
              Align(
                alignment: Alignment.bottomCenter,
                child: CallOutcomeFallbackSheet(
                  driver: state.driverDetails,
                  scenario: state.outcomeScenario,
                  onScenarioChanged: (scen) {
                    context.read<CallDriverBloc>().add(CallDriverOutcomeScenarioChanged(scen));
                  },
                  onTryAgain: () {
                    context.read<CallDriverBloc>().add(const CallDriverRetryTapped());
                    onTryAgain?.call();
                  },
                  onClose: () {
                    context.read<CallDriverBloc>().add(const CallDriverDismissTapped());
                    if (onClose != null) {
                      onClose!();
                    } else {
                      Navigator.of(context).maybePop();
                    }
                  },
                  onCallDispatch: () {
                    context.read<CallDriverBloc>().add(const CallDriverCallDispatchTapped());
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQaScenarioInspectorBar(BuildContext context, CallDriverState state) {
    return Container(
      color: Colors.white.withOpacity(0.96),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.science_outlined, color: Color(0xFF991B1B), size: 14),
                  SizedBox(width: 6),
                  Text(
                    'QA SCENARIO INSPECTOR',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Text(
                'Switch Call Outcome',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildScenarioChip(
                context,
                label: "1. Didn't Answer",
                scenario: CallOutcomeScenario.didntAnswer,
                selected: state.outcomeScenario == CallOutcomeScenario.didntAnswer,
              ),
              const SizedBox(width: 8),
              _buildScenarioChip(
                context,
                label: '2. Driver Busy',
                scenario: CallOutcomeScenario.driverBusy,
                selected: state.outcomeScenario == CallOutcomeScenario.driverBusy,
              ),
              const SizedBox(width: 8),
              _buildScenarioChip(
                context,
                label: '3. Connection Error',
                scenario: CallOutcomeScenario.connectionError,
                selected: state.outcomeScenario == CallOutcomeScenario.connectionError,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioChip(
    BuildContext context, {
    required String label,
    required CallOutcomeScenario scenario,
    required bool selected,
  }) {
    return GestureDetector(
      onTap: () {
        context.read<CallDriverBloc>().add(CallDriverOutcomeScenarioChanged(scenario));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF991B1B) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}
