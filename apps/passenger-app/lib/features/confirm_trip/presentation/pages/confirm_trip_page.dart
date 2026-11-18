import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/confirm_trip_bloc.dart';
import '../bloc/confirm_trip_event.dart';
import '../bloc/confirm_trip_state.dart';
import '../../data/models/confirm_trip_config.dart';
import '../../data/models/payment_method_info.dart';
import '../../data/repositories/confirm_trip_repository.dart';
import '../widgets/card_declined_banner.dart';
import '../widgets/confirm_trip_header.dart';
import '../widgets/confirm_trip_map.dart';
import '../widgets/driver_notes_field.dart';
import '../widgets/fare_breakdown_card.dart';
import '../widgets/fare_changed_sheet.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/trip_route_summary_card.dart';
import '../widgets/trip_vehicle_card.dart';

/// Entry page for the Confirm Trip flow.
///
/// Implements all 6 UI states:
/// - Screen 1: Standard Confirm Trip with Cash (Pay driver at destination)
/// - Screen 2: Card Required / No Card Added (Link Visa/Mastercard action)
/// - Screen 3: Card Selected with Scheduled Ride & Driver Instructions
/// - Screen 4: Booking in Progress (Contacting nearby Lethbridge drivers)
/// - Screen 5: Card Declined Error (Try another card or switch to cash)
/// - Screen 6: Fare Changed Modal (Recalculated traffic & bridge corridor rate)
class ConfirmTripPage extends StatelessWidget {
  final ConfirmTripRepository? repository;
  final ConfirmTripBloc? bloc;
  final PaymentType initialPayment;
  final bool hasLinkedCard;
  final bool simulateDecline;
  final bool simulateFareChange;

  const ConfirmTripPage({
    super.key,
    this.repository,
    this.bloc,
    this.initialPayment = PaymentType.cash,
    this.hasLinkedCard = true,
    this.simulateDecline = false,
    this.simulateFareChange = false,
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider.value(
        value: bloc!,
        child: const _ConfirmTripView(),
      );
    }

    return BlocProvider(
      create: (context) => ConfirmTripBloc(
        repository: repository ?? ConfirmTripRepositoryImpl(),
      )..add(ConfirmTripStarted(
          initialPayment: initialPayment,
          hasLinkedCard: hasLinkedCard,
          simulateDecline: simulateDecline,
          simulateFareChange: simulateFareChange,
        )),
      child: const _ConfirmTripView(),
    );
  }
}

class _ConfirmTripView extends StatelessWidget {
  const _ConfirmTripView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConfirmTripBloc, ConfirmTripState>(
      listener: (context, state) {
        if (state.targetRoute != null) {
          context.go(state.targetRoute!);
        }
      },
      builder: (context, state) {
        final details = state.details;
        final fare = state.fare;
        final payment = state.payment;
        final isBooking = state.isBooking;
        final isDeclined = state.isDeclined;
        final isCardRequired = state.isCardRequired;
        final isFareChanged = state.isFareChanged;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Top App Bar
                      ConfirmTripHeader(
                        onBack: () => context
                            .read<ConfirmTripBloc>()
                            .add(const ConfirmTripBackTapped()),
                      ),

                      // Card Declined Top Alert Banner (Screen 5)
                      if (isDeclined)
                        CardDeclinedBanner(
                          onTryAnotherCard: () => context
                              .read<ConfirmTripBloc>()
                              .add(const ConfirmTripAddCardTapped()),
                          onPayWithCash: () => context
                              .read<ConfirmTripBloc>()
                              .add(const ConfirmTripDismissDeclineBanner()),
                        ),

                      // Route Map Canvas with status pill
                      ConfirmTripMap(
                        routeBadge: ConfirmTripConfig.oldmanRiverBadge,
                        statsText: details.statsText,
                      ),

                      // Main Content Area
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Pickup & Dropoff Route Card
                              TripRouteSummaryCard(
                                pickupAddress: details.pickupAddress,
                                dropoffAddress: details.dropoffAddress,
                                onEdit: () => context
                                    .read<ConfirmTripBloc>()
                                    .add(const ConfirmTripBackTapped()),
                              ),
                              const SizedBox(height: 10),

                              // Selected Vehicle Card
                              TripVehicleCard(
                                vehicleName: details.vehicleName,
                                tag: details.vehicleTag,
                                etaMinutes: details.vehicleEtaMinutes,
                                seats: details.seats,
                                onChange: () => context
                                    .read<ConfirmTripBloc>()
                                    .add(const ConfirmTripBackTapped()),
                              ),
                              const SizedBox(height: 10),

                              // Pickup Time & Driver Notes Field
                              DriverNotesField(
                                pickupTime: details.pickupTime,
                                driverNotes: details.driverNotes,
                                onTimeTap: () {},
                                onNotesChanged: (notes) => context
                                    .read<ConfirmTripBloc>()
                                    .add(ConfirmTripDriverNotesUpdated(notes)),
                              ),
                              const SizedBox(height: 10),

                              // Fare Breakdown Card
                              FareBreakdownCard(fare: fare),
                              const SizedBox(height: 14),

                              // Payment Method Selector
                              PaymentMethodSelector(
                                payment: payment,
                                onTypeChanged: (type) => context
                                    .read<ConfirmTripBloc>()
                                    .add(ConfirmTripPaymentTypeChanged(type)),
                                onAddCard: () => context
                                    .read<ConfirmTripBloc>()
                                    .add(const ConfirmTripAddCardTapped()),
                                onSelectCash: () => context
                                    .read<ConfirmTripBloc>()
                                    .add(const ConfirmTripPaymentTypeChanged(PaymentType.cash)),
                              ),
                              const SizedBox(height: 16),

                              // Notice
                              Center(
                                child: Text(
                                  ConfirmTripConfig.notChargedUntilBooked,
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Card missing pill warning
                              if (isCardRequired) ...[
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFEBEE),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      '⚠️ Add card or switch to cash',
                                      style: TextStyle(
                                        color: Color(0xFFB71C1C),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],

                              // Booking Button
                              ElevatedButton(
                                onPressed: state.canBook
                                    ? () => context
                                        .read<ConfirmTripBloc>()
                                        .add(const ConfirmTripBookTapped())
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF880E14),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: const Color(0xFFE5E7EB),
                                  disabledForegroundColor: const Color(0xFF9CA3AF),
                                  elevation: 0,
                                  minimumSize: const Size(double.infinity, 52),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (isBooking) ...[
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ] else ...[
                                      const Icon(Icons.local_taxi_rounded, size: 18),
                                      const SizedBox(width: 8),
                                    ],
                                    Text(
                                      state.ctaButtonText,
                                      style: const TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Screen 6: Fare Changed Bottom Modal Sheet Overlay
                  if (isFareChanged)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black45,
                        alignment: Alignment.bottomCenter,
                        child: FareChangedSheet(
                          fare: fare,
                          onConfirmNewTotal: () => context
                              .read<ConfirmTripBloc>()
                              .add(const ConfirmTripFareChangeAccepted()),
                          onBackToVehicles: () => context
                              .read<ConfirmTripBloc>()
                              .add(const ConfirmTripFareChangeDeclined()),
                        ),
                      ),
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
