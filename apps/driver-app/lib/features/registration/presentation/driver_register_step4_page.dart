import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/driver_register_step4_bloc.dart';
import '../bloc/driver_register_step4_event.dart';
import '../bloc/driver_register_step4_state.dart';
import '../data/models/driver_register_config.dart';
import '../data/models/driver_register_step4_status.dart';
import 'widgets/driver_application_milestone_stepper.dart';
import 'widgets/driver_credential_profile_card.dart';
import 'widgets/driver_register_step4_progress_indicator.dart';
import 'widgets/driver_register_step4_qa_matrix_bar.dart';

class DriverRegisterStep4Page extends StatelessWidget {
  final DriverRegisterStep4Status initialStatus;

  const DriverRegisterStep4Page({
    super.key,
    this.initialStatus = DriverRegisterStep4Status.reviewing,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverRegisterStep4Bloc()
        ..add(DriverRegisterStep4Started(initialStatus: initialStatus)),
      child: const _DriverRegisterStep4View(),
    );
  }
}

class _DriverRegisterStep4View extends StatelessWidget {
  const _DriverRegisterStep4View();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverRegisterStep4Bloc, DriverRegisterStep4State>(
      listenWhen: (prev, curr) =>
          prev.feedbackMessage != curr.feedbackMessage ||
          prev.status != curr.status,
      listener: (context, state) {
        if (state.feedbackMessage != null && state.feedbackMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.feedbackMessage!),
              backgroundColor: state.isApproved
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFC62828),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<DriverRegisterStep4Bloc>();
        final isApproved = state.isApproved;
        final isReviewing = state.isReviewing;
        final isActionRequired = state.isActionRequired;
        final isRejected = state.isRejected;
        final isOffline = state.isOffline;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leadingWidth: 44,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFC62828),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_taxi,
                    color: Colors.white, size: 18),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  DriverRegisterConfig.step4TopFleetTitle,
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                Text(
                  DriverRegisterConfig.step4TopPendingApproval,
                  style: TextStyle(
                    color: isApproved
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout,
                    size: 14, color: Color(0xFF111827)),
                label: const Text(
                  DriverRegisterConfig.step4LogOutAction,
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF90141E),
                  child: const Icon(Icons.person,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // QA Matrix Bar for state testing
                DriverRegisterStep4QaMatrixBar(
                  currentStatus: state.status,
                  onStatusSelected: (status) {
                    bloc.add(DriverRegisterStep4StateSwitched(status));
                  },
                ),
                const SizedBox(height: 12),

                // Offline Amber Banner (Image 5)
                if (isOffline) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFF59E0B),
                          ),
                          child: const Icon(Icons.sync,
                              size: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                DriverRegisterConfig.step4OfflineTitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                DriverRegisterConfig.step4OfflineSubtitle,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Step 4 of 4 Progress Bar
                DriverRegisterStep4ProgressIndicator(status: state.status),
                const SizedBox(height: 20),

                // HERO SECTION
                if (isApproved) ...[
                  // Concentric Green Radar Rings
                  Center(
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFDCFCE7).withOpacity(0.5),
                      ),
                      child: Center(
                        child: Container(
                          width: 105,
                          height: 105,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFBBF7D0).withOpacity(0.8),
                          ),
                          child: Center(
                            child: Stack(
                              children: [
                                Container(
                                  width: 75,
                                  height: 75,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF16A34A),
                                  ),
                                  child: const Icon(Icons.check,
                                      size: 42, color: Colors.white),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFC62828),
                                    ),
                                    child: const Icon(Icons.local_taxi,
                                        size: 14, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    DriverRegisterConfig.step4ApprovedTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    DriverRegisterConfig.step4ApprovedSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else if (isActionRequired) ...[
                  // Action needed alert banner (Image 3)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFCDD2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: Color(0xFFC62828), size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.data.alertTitle ??
                                        DriverRegisterConfig
                                            .step4ActionRequiredTitle,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFB71C1C),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    state.data.alertMessage ??
                                        DriverRegisterConfig
                                            .step4ActionRequiredSubtitle,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF4B5563),
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Embedded flagged card
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFFCDD2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFFFEBEE),
                                ),
                                child: const Icon(Icons.badge_outlined,
                                    color: Color(0xFFC62828), size: 16),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.data.flaggedDocumentName ??
                                          "Driver's Licence",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                    Text(
                                      '🕒 ${state.data.flaggedDocumentReason ?? "Blurry photo · 4 corners cut off"}',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => bloc.add(
                                    const DriverRegisterStep4FixDocumentsRequested()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC62828),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  minimumSize: const Size(0, 30),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'RE-UPLOAD',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hold header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFFEBEE),
                        ),
                        child: const Icon(Icons.pending_actions,
                            size: 18, color: Color(0xFFC62828)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              DriverRegisterConfig.step4AppOnHoldTitle,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              DriverRegisterConfig.step4AppOnHoldSubtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4B5563),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ] else if (isRejected) ...[
                  // Rejection Alert Banner (Image 4)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFCDD2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFC62828),
                          ),
                          child: const Icon(Icons.shield_outlined,
                              size: 18, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.data.alertTitle ??
                                    DriverRegisterConfig.step4RejectedTitle,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFB71C1C),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                state.data.alertMessage ??
                                    DriverRegisterConfig.step4RejectedSubtitle,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF4B5563),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Next steps list
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.alt_route,
                                size: 16, color: Color(0xFFC62828)),
                            SizedBox(width: 6),
                            Text(
                              'Next steps for your application',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildNextStepItem(
                          number: '1',
                          title: 'Register an alternate compliant vehicle:',
                          desc:
                              'Update your registration with an approved sedan, SUV, or accessible van manufactured in 2014 or later.',
                        ),
                        const SizedBox(height: 10),
                        _buildNextStepItem(
                          number: '2',
                          title: 'Appeal decision with Bridge City dispatch:',
                          desc:
                              'If vehicle paperwork contains clerical discrepancies or seasonal grandfathered permits, connect directly with audit teams.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ] else ...[
                  // Reviewing / Offline Hero Illustration (Images 2 & 5)
                  Center(
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFEBEE),
                      ),
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black12, blurRadius: 4),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                      width: 40,
                                      height: 3,
                                      color: const Color(0xFF16A34A)),
                                  Container(
                                      width: 40,
                                      height: 3,
                                      color: const Color(0xFFC62828)),
                                  Container(
                                      width: 30,
                                      height: 3,
                                      color: const Color(0xFFD1D5DB)),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: const Icon(Icons.search,
                                  size: 28, color: Color(0xFFC62828)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    DriverRegisterConfig.step4ReviewingTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    DriverRegisterConfig.step4ReviewingSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4B5563),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // SECTION: MILESTONES STEPPER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isApproved
                          ? 'Application Journey'
                          : (isActionRequired
                              ? 'VERIFICATION MILESTONES'
                              : (isRejected
                                  ? 'Review Lifecycle'
                                  : (isOffline
                                      ? 'APPLICATION TELEMETRY'
                                      : 'APPLICATION MILESTONES'))),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    if (isApproved)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '3 of 3 Passed',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF166534),
                          ),
                        ),
                      )
                    else if (isReviewing)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Priority Queue',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFC62828),
                          ),
                        ),
                      )
                    else if (isOffline)
                      Text(
                        '🕒 Last synced ${state.data.lastSyncedTime}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Milestones Stepper
                DriverApplicationMilestoneStepper(
                  milestones: state.data.milestones,
                ),
                const SizedBox(height: 20),

                // SECTION: DRIVER CREDENTIAL / CAB PROFILE CARD
                DriverCredentialProfileCard(
                  status: state.status,
                  data: state.data,
                  onEditPressed: () =>
                      bloc.add(const DriverRegisterStep4UpdateVehicleRequested()),
                ),
                const SizedBox(height: 20),

                // SUPPORT CARD
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFFEBEE),
                        ),
                        child: const Icon(Icons.headset_mic_outlined,
                            size: 18, color: Color(0xFFC62828)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isRejected
                                  ? 'Speak directly with Lethbridge fleet management'
                                  : (isApproved
                                      ? 'Onboarding help?'
                                      : 'Questions about review?'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              isRejected
                                  ? 'Desk hours: 07:00 – 19:00 MT'
                                  : 'Contact 24/7 Lethbridge fleet support',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => bloc.add(
                            const DriverRegisterStep4ContactSupportRequested()),
                        child: Text(
                          isApproved ? 'Support' : 'Contact support ➔',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFC62828),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ACTION BUTTONS SECTION
                if (isApproved) ...[
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      key: const ValueKey('driver_go_to_home_button'),
                      onPressed: () =>
                          bloc.add(const DriverRegisterStep4GoHomeRequested()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Go to home ➔',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ] else if (isActionRequired) ...[
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      key: const ValueKey('driver_fix_documents_button'),
                      onPressed: () => bloc.add(
                          const DriverRegisterStep4FixDocumentsRequested()),
                      icon: const Icon(Icons.file_copy_outlined,
                          size: 16, color: Colors.white),
                      label: const Text(
                        'Fix documents ➔',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => bloc.add(
                        const DriverRegisterStep4RefreshRequested()),
                    icon: const Icon(Icons.refresh,
                        size: 14, color: Color(0xFF4B5563)),
                    label: const Text(
                      'Refresh status',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ] else if (isRejected) ...[
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      key: const ValueKey('driver_update_vehicle_button'),
                      onPressed: () => bloc.add(
                          const DriverRegisterStep4UpdateVehicleRequested()),
                      icon: const Icon(Icons.cloud_upload_outlined,
                          size: 16, color: Colors.white),
                      label: const Text(
                        'Re-upload documents / Update vehicle',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => bloc.add(
                          const DriverRegisterStep4ContactSupportRequested()),
                      icon: const Icon(Icons.phone_outlined,
                          size: 16, color: Color(0xFF374151)),
                      label: const Text(
                        'Contact support',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F6),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ] else if (isOffline) ...[
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      key: const ValueKey('driver_offline_reconnecting_button'),
                      onPressed: state.isReconnecting
                          ? null
                          : () => bloc.add(
                              const DriverRegisterStep4ReconnectRequested()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (state.isReconnecting)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFC62828)),
                              ),
                            )
                          else
                            const Icon(Icons.sync,
                                size: 16, color: Color(0xFF6B7280)),
                          const SizedBox(width: 8),
                          Text(
                            state.isReconnecting
                                ? 'Reconnecting to server...'
                                : 'Tap to reconnect',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      '📞 Offline dispatch phone: ${state.data.offlinePhone}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ] else ...[
                  // Reviewing (Image 2)
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      key: const ValueKey('driver_refresh_status_button'),
                      onPressed: state.isRefreshing
                          ? null
                          : () => bloc.add(
                              const DriverRegisterStep4RefreshRequested()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (state.isRefreshing)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFC62828)),
                              ),
                            )
                          else
                            const Icon(Icons.sync,
                                size: 16, color: Color(0xFF4B5563)),
                          const SizedBox(width: 8),
                          const Text(
                            'Refresh status',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      DriverRegisterConfig.step4AutoCheckNotice,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNextStepItem({
    required String number,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE5E7EB),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563)),
              children: [
                TextSpan(
                  text: '$title ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
