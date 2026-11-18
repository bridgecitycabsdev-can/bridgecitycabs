import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/add_card_bloc.dart';
import '../bloc/add_card_event.dart';
import '../bloc/add_card_state.dart';
import '../../data/models/add_card_config.dart';
import '../../data/models/add_card_models.dart';
import '../../data/repositories/add_card_repository.dart';
import '../widgets/add_card_app_bar.dart';
import '../widgets/add_card_declined_banner.dart';
import '../widgets/add_card_form_card.dart';
import '../widgets/add_card_header_hero.dart';
import '../widgets/add_card_networks_row.dart';
import '../widgets/add_card_success_view.dart';
import '../widgets/add_card_verification_pending_banner.dart';
import '../widgets/bank_confirmation_dialog.dart';
import '../widgets/three_d_secure_dialog.dart';

class AddCardPage extends StatelessWidget {
  final CardFormData? initialForm;
  final AddCardStatus? initialStatus;
  final ThreeDSecureData? initialThreeD;
  final AddCardRepository? repository;

  const AddCardPage({
    super.key,
    this.initialForm,
    this.initialStatus,
    this.initialThreeD,
    this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddCardBloc(
        repository: repository ?? MockAddCardRepository(),
      )..add(AddCardStarted(
          initialForm: initialForm,
          initialStatus: initialStatus,
          initialThreeD: initialThreeD,
        )),
      child: const _AddCardView(),
    );
  }
}

class _AddCardView extends StatelessWidget {
  const _AddCardView();

  void _showBankConfirmModal(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => const BankConfirmationDialog(),
    );
  }

  void _showThreeDModal(BuildContext context, ThreeDSecureData threeD) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => ThreeDSecureDialog(
        threeD: threeD,
        onCodeChanged: (code) {
          context.read<AddCardBloc>().add(AddCardOtpChanged(code));
        },
        onConfirm: () {
          Navigator.of(dialogCtx).pop();
          context.read<AddCardBloc>().add(const AddCardOtpSubmitted());
        },
        onCancel: () {
          Navigator.of(dialogCtx).pop();
          context.read<AddCardBloc>().add(const AddCard3DCancelled());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddCardBloc, AddCardState>(
      listener: (context, state) {
        if (state.navigateToPaymentMethods) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/payment-methods');
          }
        }

        if (state.showBankConfirmDialog) {
          _showBankConfirmModal(context);
        }

        if (state.showThreeDDialog) {
          _showThreeDModal(context, state.threeD);
        }
      },
      builder: (context, state) {
        final bloc = context.read<AddCardBloc>();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AddCardAppBar(
            onBack: () => bloc.add(const AddCardBackTapped()),
            showPciBadge: state.isTokenizing,
          ),
          body: state.isSuccess
              ? AddCardSuccessView(
                  last4: state.form.last4,
                  expiry: state.form.expiry.isNotEmpty
                      ? state.form.expiry
                      : '11/28',
                  onReturn: () =>
                      bloc.add(const AddCardReturnToPaymentMethodsTapped()),
                )
              : _buildFormBody(context, state, bloc),
        );
      },
    );
  }

  Widget _buildFormBody(
    BuildContext context,
    AddCardState state,
    AddCardBloc bloc,
  ) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            // Screen 6: Declined Banner
            if (state.isDeclined) ...[
              AddCardDeclinedBanner(
                onDismiss: () => bloc.add(const AddCardErrorDismissed()),
              ),
              const SizedBox(height: 14),
            ],

            // Screen 7: Verification In Progress Banner
            if (state.isVerificationPending) ...[
              AddCardVerificationPendingBanner(
                onRefresh: () => bloc.add(const AddCardRefreshPendingTapped()),
              ),
              const SizedBox(height: 14),
            ],

            // Header Hero Graphic
            const AddCardHeaderHero(),
            const SizedBox(height: 20),

            // Main Input Form Card
            AddCardFormCard(
              form: state.form,
              isValidating: state.isTokenizing,
              isDeclined: state.isDeclined,
              isVerificationPending: state.isVerificationPending,
              onCardNumberChanged: (v) => bloc.add(AddCardNumberChanged(v)),
              onExpiryChanged: (v) => bloc.add(AddCardExpiryChanged(v)),
              onCvcChanged: (v) => bloc.add(AddCardCvcChanged(v)),
              onPostalCodeChanged: (v) => bloc.add(AddCardPostalCodeChanged(v)),
              onNameChanged: (v) => bloc.add(AddCardNameChanged(v)),
            ),
            const SizedBox(height: 16),

            // Accepted Networks Row + Default Checkbox
            AddCardNetworksRow(
              isDefault: state.form.isDefault,
              onDefaultChanged: (v) => bloc.add(AddCardDefaultToggled(v)),
              subtitle: state.isTokenizing
                  ? 'Automatically applied for your Southern Alberta rides'
                  : null,
            ),
            const SizedBox(height: 20),

            // Action Buttons
            _buildActionButtons(context, state, bloc),
            const SizedBox(height: 18),

            // SSL Security Footer Notice
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 14, color: Color(0xFF64748B)),
                SizedBox(width: 6),
                Text(
                  AddCardConfig.sslNotice,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
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

  Widget _buildActionButtons(
    BuildContext context,
    AddCardState state,
    AddCardBloc bloc,
  ) {
    if (state.isDeclined) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => bloc.add(const AddCardRetryTapped()),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text(
                'Try again',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB91C1C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => bloc.add(const AddCardUseDifferentCardTapped()),
              icon: const Icon(Icons.credit_card, size: 18),
              label: const Text(
                'Use a different card',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: const Color(0xFF1E293B),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (state.isVerificationPending) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () =>
                  bloc.add(const AddCardReturnToPaymentMethodsTapped()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB91C1C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Return to Payment Methods',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => bloc.add(const AddCardUseDifferentCardTapped()),
            child: const Text(
              'Cancel & re-enter details',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      );
    }

    if (state.isTokenizing) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB91C1C),
            disabledBackgroundColor: const Color(0xFFB91C1C),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Tokenizing card...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: state.canSave
            ? () => bloc.add(const AddCardSaveTapped())
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB91C1C),
          disabledBackgroundColor: const Color(0xFFE2E8F0),
          foregroundColor: Colors.white,
          disabledForegroundColor: const Color(0xFF94A3B8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: const Text(
          'Save card',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
