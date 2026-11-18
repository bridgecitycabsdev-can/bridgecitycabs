import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/payment_methods_bloc.dart';
import '../bloc/payment_methods_event.dart';
import '../bloc/payment_methods_state.dart';
import '../../data/models/payment_card_model.dart';
import '../../data/models/payment_methods_config.dart';
import '../../data/repositories/payment_methods_repository.dart';
import '../widgets/add_card_sheet.dart';
import '../widgets/empty_cards_view.dart';
import '../widgets/instant_receipts_card.dart';
import '../widgets/payment_app_bar.dart';
import '../widgets/payment_card_tile.dart';
import '../widgets/payment_cash_tile.dart';
import '../widgets/payment_error_banner.dart';
import '../widgets/payment_skeleton_view.dart';
import '../widgets/payment_transit_header_card.dart';
import '../widgets/remove_card_dialog.dart';
import '../widgets/southern_alberta_guarantee_card.dart';

class PaymentMethodsPage extends StatelessWidget {
  final List<PaymentCard>? initialCards;
  final PaymentMethodsStatus? initialStatus;
  final bool simulateLoading;
  final SelectedPaymentType? initialPaymentType;
  final PaymentMethodsRepository? repository;

  const PaymentMethodsPage({
    super.key,
    this.initialCards,
    this.initialStatus,
    this.simulateLoading = false,
    this.initialPaymentType,
    this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentMethodsBloc(
        repository: repository ?? MockPaymentMethodsRepository(),
      )..add(PaymentMethodsStarted(
          initialCards: initialCards,
          initialStatus: initialStatus,
          simulateLoading: simulateLoading,
          initialPaymentType: initialPaymentType,
        )),
      child: const _PaymentMethodsView(),
    );
  }
}

class _PaymentMethodsView extends StatelessWidget {
  const _PaymentMethodsView();

  void _showAddCardModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => AddCardSheet(
        onCardAdded: (brand, last4, expiry) {
          context.read<PaymentMethodsBloc>().add(PaymentMethodsCardAdded(
                brand: brand,
                last4: last4,
                expiry: expiry,
              ));
        },
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, PaymentCard card) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => RemoveCardDialog(
        card: card,
        onConfirmRemove: () {
          Navigator.of(dialogCtx).pop();
          context
              .read<PaymentMethodsBloc>()
              .add(PaymentMethodsRemoveCardConfirmed(card.id));
        },
        onCancel: () {
          Navigator.of(dialogCtx).pop();
          context
              .read<PaymentMethodsBloc>()
              .add(const PaymentMethodsRemoveCardCancelled());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentMethodsBloc, PaymentMethodsState>(
      listener: (context, state) {
        if (state.navigateBack) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        }

        if (state.cardPendingRemoval != null) {
          _showRemoveDialog(context, state.cardPendingRemoval!);
        }

        if (state.showAddCardSheet) {
          _showAddCardModal(context);
        }
      },
      builder: (context, state) {
        final bloc = context.read<PaymentMethodsBloc>();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PaymentAppBar(
            onBack: () => bloc.add(const PaymentMethodsBackTapped()),
          ),
          body: state.isLoading
              ? const PaymentSkeletonView()
              : _buildLoadedBody(context, state, bloc),
        );
      },
    );
  }

  Widget _buildLoadedBody(
    BuildContext context,
    PaymentMethodsState state,
    PaymentMethodsBloc bloc,
  ) {
    final hasCards = state.hasCards;
    final isCashDefault = state.isCashDefault;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen 5: Error Banner
            if (state.errorMessage != null) ...[
              PaymentErrorBanner(
                errorMessage: state.errorMessage!,
                onRetry: () => bloc.add(const PaymentMethodsRetryTapped()),
                onDismiss: () => bloc.add(const PaymentMethodsErrorDismissed()),
              ),
              const SizedBox(height: 14),
            ],

            // Screen 2: Transit Header Card
            if (hasCards) ...[
              const PaymentTransitHeaderCard(),
              const SizedBox(height: 16),
            ] else ...[
              const Row(
                children: [
                  Icon(Icons.payments_outlined, size: 16, color: Color(0xFF64748B)),
                  SizedBox(width: 8),
                  Text(
                    PaymentMethodsConfig.transitHeaderSubtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],

            // Cash Tile
            PaymentCashTile(
              isDefault: isCashDefault,
              showChevron: state.errorMessage != null,
              onTap: () => bloc.add(const PaymentMethodsCashSelected()),
            ),
            const SizedBox(height: 24),

            // Saved Cards Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SAVED CARDS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.6,
                  ),
                ),
                if (state.isUpdatingDefault)
                  const Row(
                    children: [
                      Icon(Icons.circle, size: 6, color: Color(0xFFB91C1C)),
                      SizedBox(width: 6),
                      Text(
                        'Syncing...',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    state.cardsCountSubtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Cards or Empty State
            if (!hasCards) ...[
              EmptyCardsView(
                onAddCard: () => bloc.add(const PaymentMethodsAddCardTapped()),
              ),
              const SizedBox(height: 20),
              const SouthernAlbertaGuaranteeCard(),
            ] else ...[
              ...state.cards.map((card) {
                final isUpdating = state.updatingCardId == card.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PaymentCardTile(
                    card: card,
                    isUpdating: isUpdating,
                    showCheckmarkInsteadOfMenu: state.errorMessage != null,
                    onSelectCard: () =>
                        bloc.add(PaymentMethodsCardSelected(card.id)),
                    onRemoveCard: () =>
                        bloc.add(PaymentMethodsRemoveCardInitiated(card)),
                  ),
                );
              }),
              const SizedBox(height: 6),

              // Add New Card Button
              InkWell(
                onTap: state.isUpdatingDefault
                    ? null
                    : () => bloc.add(const PaymentMethodsAddCardTapped()),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: state.isUpdatingDefault
                        ? const Color(0xFFF8FAFC)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: state.isUpdatingDefault
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFFFEE2E2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: state.isUpdatingDefault
                              ? const Color(0xFFE2E8F0)
                              : const Color(0xFF991B1B),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          size: 16,
                          color: state.isUpdatingDefault
                              ? const Color(0xFF94A3B8)
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add new card',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: state.isUpdatingDefault
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF991B1B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Instant Receipts Card
              const InstantReceiptsCard(),
            ],

            const SizedBox(height: 20),

            // Stripe Security Footer Notice
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasCards
                        ? PaymentMethodsConfig.stripeSecurityNoticeFull
                        : PaymentMethodsConfig.stripeSecurityNotice,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
