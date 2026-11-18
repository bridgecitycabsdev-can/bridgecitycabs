import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/trip_receipt_bloc.dart';
import '../bloc/trip_receipt_event.dart';
import '../bloc/trip_receipt_state.dart';
import '../../data/models/receipt_models.dart';
import '../../data/models/trip_receipt_config.dart';
import '../../data/repositories/trip_receipt_repository.dart';
import '../widgets/cash_notice_banner.dart';
import '../widgets/driver_confirmed_banner.dart';
import '../widgets/driver_rating_sheet.dart';
import '../widgets/receipt_driver_card.dart';
import '../widgets/receipt_fare_breakdown_card.dart';
import '../widgets/receipt_header.dart';
import '../widgets/receipt_route_card.dart';
import '../widgets/receipt_skeleton_view.dart';
import '../widgets/receipt_total_card.dart';

class TripReceiptPage extends StatelessWidget {
  final TripReceiptDetails? receipt;
  final bool simulateLoading;
  final TripReceiptStatus? initialStatus;
  final TripReceiptRepository? repository;

  const TripReceiptPage({
    super.key,
    this.receipt,
    this.simulateLoading = false,
    this.initialStatus,
    this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TripReceiptBloc(
        repository: repository ?? MockTripReceiptRepository(),
      )..add(TripReceiptStarted(
          receipt: receipt,
          simulateLoading: simulateLoading,
          initialStatus: initialStatus,
        )),
      child: const _TripReceiptView(),
    );
  }
}

class _TripReceiptView extends StatelessWidget {
  const _TripReceiptView();

  void _showRatingModal(BuildContext context, String driverName) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => DriverRatingSheet(
        driverName: driverName,
        onRatingSubmitted: (rating) {
          context
              .read<TripReceiptBloc>()
              .add(TripReceiptRatingSubmitted(rating: rating));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thank you! Rating submitted.'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _showReportProblemSheet(BuildContext context) {
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
              const Text(
                'Report a problem with this trip',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.attach_money, color: Color(0xFFC62828)),
                title: const Text('Fare or fee dispute'),
                subtitle: const Text('Question about subtotal, GST or promo discount'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Support ticket created')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.inventory_2_outlined, color: Color(0xFF1F1F1F)),
                title: const Text('Lost item in vehicle'),
                subtitle: const Text('Contact driver Michael K. or dispatch'),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(Icons.headset_mic_outlined, color: Color(0xFF1F1F1F)),
                title: const Text('Contact Lethbridge Dispatch (403-328-8888)'),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TripReceiptBloc, TripReceiptState>(
      listenWhen: (previous, current) {
        return previous.navigateToHome != current.navigateToHome ||
            previous.isCopiedToClipboard != current.isCopiedToClipboard ||
            previous.showRatingSheet != current.showRatingSheet ||
            previous.showProblemSheet != current.showProblemSheet;
      },
      listener: (context, state) {
        if (state.navigateToHome) {
          context.go('/home');
        }
        if (state.isCopiedToClipboard) {
          Clipboard.setData(ClipboardData(text: state.receipt.trackingId));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tracking ID ${state.receipt.trackingId} copied'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        if (state.showRatingSheet) {
          _showRatingModal(context, state.receipt.driverName);
        }
        if (state.showProblemSheet) {
          _showReportProblemSheet(context);
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: SafeArea(child: ReceiptSkeletonView()),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Top Pink Gradient Header
                ReceiptHeader(
                  onDone: () {
                    context.read<TripReceiptBloc>().add(const TripReceiptDoneTapped());
                  },
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    children: [
                      // Total Card
                      ReceiptTotalCard(
                        fare: state.receipt.fare,
                        isCashPending: state.isCashPending,
                      ),
                      const SizedBox(height: 14),

                      // Cash Pending Notice Banner
                      if (state.isCashPending) ...[
                        CashNoticeBanner(
                          amount: state.receipt.fare.totalAmount,
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Driver Confirmed Cash Banner
                      if (state.isCashConfirmed) ...[
                        DriverConfirmedBanner(
                          amount: state.receipt.fare.totalAmount,
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Route Details Card
                      ReceiptRouteCard(receipt: state.receipt),
                      const SizedBox(height: 14),

                      // Driver & Vehicle Card
                      ReceiptDriverCard(
                        receipt: state.receipt,
                        onCopyTrackingId: () {
                          context
                              .read<TripReceiptBloc>()
                              .add(const TripReceiptCopyTrackingIdTapped());
                        },
                      ),
                      const SizedBox(height: 14),

                      // Fare Breakdown Card
                      ReceiptFareBreakdownCard(
                        fare: state.receipt.fare,
                        isCashPending: state.isCashPending,
                      ),
                      const SizedBox(height: 14),

                      // Report Problem Row
                      InkWell(
                        onTap: () {
                          context
                              .read<TripReceiptBloc>()
                              .add(const TripReceiptReportProblemTapped());
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEEEEEE)),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.help_outline,
                                color: Color(0xFF6B7280),
                                size: 18,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  TripReceiptConfig.reportProblemText,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F1F1F),
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Color(0xFF9CA3AF),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Rating locked notice for Cash Pending
                      if (state.isCashPending) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.lock_outline,
                                size: 13, color: Color(0xFF6B7280)),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                TripReceiptConfig.ratingLockedNotice,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF6B7280),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Rate your driver CTA (if eligible)
                      if (state.canRateDriver) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context
                                  .read<TripReceiptBloc>()
                                  .add(const TripReceiptRateDriverTapped());
                            },
                            icon: const Icon(Icons.star_outline,
                                color: Colors.white, size: 18),
                            label: const Text(
                              TripReceiptConfig.rateDriverButton,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF23272B),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Primary Done Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            context
                                .read<TripReceiptBloc>()
                                .add(const TripReceiptDoneTapped());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC62828),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            TripReceiptConfig.doneButton,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
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
