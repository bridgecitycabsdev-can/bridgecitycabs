import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/call_driver_bloc.dart';
import 'bloc/call_driver_event.dart';
import 'bloc/call_driver_state.dart';
import 'widgets/call_driver_map_background.dart';
import 'widgets/masked_number_protection_sheet.dart';
import 'widgets/driver_arriving_call_card.dart';

class CallDriverPromptPage extends StatefulWidget {
  final VoidCallback? onCallInitiated;
  final VoidCallback? onCancel;

  const CallDriverPromptPage({
    super.key,
    this.onCallInitiated,
    this.onCancel,
  });

  @override
  State<CallDriverPromptPage> createState() => _CallDriverPromptPageState();
}

class _CallDriverPromptPageState extends State<CallDriverPromptPage> {
  bool _showDriverArrivingView = false; // Toggle to view Screen 2 vs Screen 1

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
          body: Stack(
            children: [
              // Map background
              CallDriverMapBackground(
                statusPillText: _showDriverArrivingView
                    ? 'Whoop-Up Dr • Bridge City Transit'
                    : 'Lethbridge Transit Zone',
                vehicleMarkerText: 'Michael • Silver Camry',
              ),

              // View toggle button in top right (to switch between Screen 1 & Screen 2)
              Positioned(
                top: 60,
                right: 16,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _showDriverArrivingView = !_showDriverArrivingView;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      _showDriverArrivingView ? 'Show Masked Prompt' : 'Show Arriving Card',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Sheet: Either Screen 1 (Masked Number Sheet) or Screen 2 (Driver Arriving Card)
              Align(
                alignment: Alignment.bottomCenter,
                child: _showDriverArrivingView
                    ? DriverArrivingCallCard(
                        driver: state.driverDetails,
                        onCallPhoneTapped: () {
                          context.read<CallDriverBloc>().add(const CallDriverInitiateTapped());
                          widget.onCallInitiated?.call();
                        },
                        onCancelRideTapped: () {
                          widget.onCancel?.call();
                        },
                        onEditNoteTapped: () {},
                      )
                    : MaskedNumberProtectionSheet(
                        driver: state.driverDetails,
                        onCallTapped: () {
                          context.read<CallDriverBloc>().add(const CallDriverInitiateTapped());
                          widget.onCallInitiated?.call();
                        },
                        onCancelTapped: () {
                          if (widget.onCancel != null) {
                            widget.onCancel!();
                          } else {
                            Navigator.of(context).maybePop();
                          }
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
