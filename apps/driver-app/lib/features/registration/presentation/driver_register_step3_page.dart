import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/driver_register_step3_bloc.dart';
import '../bloc/driver_register_step3_event.dart';
import '../bloc/driver_register_step3_state.dart';
import '../data/models/driver_document_type.dart';
import '../data/models/driver_register_config.dart';
import '../data/models/driver_register_step3_status.dart';
import 'widgets/driver_document_card.dart';
import 'widgets/driver_document_upload_modal.dart';
import 'widgets/driver_register_step3_progress_indicator.dart';
import 'widgets/driver_register_step3_qa_matrix_bar.dart';

class DriverRegisterStep3Page extends StatelessWidget {
  final DriverRegisterStep3Status initialStatus;

  const DriverRegisterStep3Page({
    super.key,
    this.initialStatus = DriverRegisterStep3Status.initial,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverRegisterStep3Bloc()
        ..add(DriverRegisterStep3Started(initialStatus: initialStatus)),
      child: const _DriverRegisterStep3View(),
    );
  }
}

class _DriverRegisterStep3View extends StatelessWidget {
  const _DriverRegisterStep3View();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverRegisterStep3Bloc, DriverRegisterStep3State>(
      listenWhen: (prev, curr) =>
          prev.feedbackMessage != curr.feedbackMessage ||
          prev.status != curr.status,
      listener: (context, state) {
        if (state.feedbackMessage != null && state.feedbackMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.feedbackMessage!),
              backgroundColor: state.status == DriverRegisterStep3Status.success
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFC62828),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<DriverRegisterStep3Bloc>();
        final isReady = state.status == DriverRegisterStep3Status.ready;
        final isSubmitting = state.status == DriverRegisterStep3Status.submitting;
        final isUploading = state.status == DriverRegisterStep3Status.uploading;
        final isActionRequired =
            state.status == DriverRegisterStep3Status.actionRequired;
        final isInitial = state.status == DriverRegisterStep3Status.initial;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
            title: Row(
              children: [
                const Expanded(
                  child: Text(
                    DriverRegisterConfig.step3AppBarTitle,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFC62828),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        DriverRegisterConfig.step3BadgeApplication,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFC62828),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: const Color(0xFF90141E),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // QA Matrix Bar for Screen Testing
                    DriverRegisterStep3QaMatrixBar(
                      currentStatus: state.status,
                      onStatusSelected: (status) {
                        bloc.add(DriverRegisterStep3StateSwitched(status));
                      },
                    ),
                    const SizedBox(height: 16),

                    // Step 3 of 4 Progress Bar
                    DriverRegisterStep3ProgressIndicator(status: state.status),
                    const SizedBox(height: 16),

                    // Top Banner / Status Hero Card
                    if (isActionRequired) ...[
                      // 1 ACTION REQUIRED ALERT BANNER
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFCDD2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Color(0xFFD32F2F), size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.actionRequiredMessage ??
                                        DriverRegisterConfig
                                            .step3LicenceNeedsReuploadTitle,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFB71C1C),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    state.actionRequiredDetails ??
                                        DriverRegisterConfig
                                            .step3LicenceNeedsReuploadDesc,
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

                      // Section Header: Compliance Documents (2/3 Verified)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                DriverRegisterConfig.step3ComplianceDocuments,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              Text(
                                DriverRegisterConfig.step3LethbridgeBylaw6251,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '2/3 VERIFIED',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ] else if (isReady) ...[
                      // READY FOR FLEET COMPLIANCE HERO CARD
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFDCFCE7),
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: Color(0xFF16A34A),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    DriverRegisterConfig
                                        .step3ReadyComplianceTitle,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF166534),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    DriverRegisterConfig
                                        .step3ReadyComplianceDesc,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF15803D),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ] else if (isSubmitting) ...[
                      // TRANSMITTING HEADER
                      Row(
                        children: const [
                          Icon(Icons.sync, size: 16, color: Color(0xFFC62828)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              DriverRegisterConfig.step3UploadingEncryptedServer,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4B5563),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      // INSTRUCTION CARD (Initial / Uploading)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF3F4F6)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFFFEBEE),
                              ),
                              child: const Icon(
                                Icons.document_scanner_outlined,
                                size: 18,
                                color: Color(0xFFC62828),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Upload clear photos',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  Text(
                                    'Make sure all text is readable and corners are visible.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 4 DOCUMENT CARDS
                    for (final docType in DriverDocumentType.values)
                      DriverDocumentCard(
                        item: state.data.getDocument(docType),
                        onUploadPressed: () {
                          bloc.add(DriverRegisterUploadModalOpened(docType));
                        },
                        onRetakePressed: () {
                          bloc.add(
                              DriverRegisterDocumentRetakeRequested(docType));
                        },
                        onDeletePressed: state.data
                                .getDocument(docType)
                                .status
                                .isUploaded
                            ? () => bloc.add(DriverRegisterDocumentDeleted(docType))
                            : null,
                      ),

                    // SUBMITTING PROTOCOL CARDS (Screen 4)
                    if (isSubmitting) ...[
                      const SizedBox(height: 8),
                      // System Protocol Active Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F2),
                          borderRadius: BorderRadius.circular(12),
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
                              child: const Icon(
                                Icons.sync,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    DriverRegisterConfig
                                        .step3SystemProtocolActive,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF111827),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    DriverRegisterConfig
                                        .step3SystemProtocolDesc,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF4B5563),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // SSL/TLS Channel Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F2937),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.security,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    DriverRegisterConfig.step3SslChannelTitle,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  Text(
                                    'Direct dispatch node: ${state.data.dispatchNode}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF16A34A),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${state.data.transmissionPercentage}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF16A34A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // SECURITY & REGULATORY CARD
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isReady ? Icons.lock_outline : Icons.security,
                            size: 16,
                            color: const Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isReady) ...[
                                  const Text(
                                    DriverRegisterConfig
                                        .step3EncryptedCompliantTitle,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                ],
                                Text(
                                  isReady
                                      ? DriverRegisterConfig
                                          .step3EncryptedCompliantDesc
                                      : DriverRegisterConfig
                                          .step3VaultSecurityNotice,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    height: 1.35,
                                    color: Color(0xFF4B5563),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // SUPPORT STRIP (When action required)
                    if (isActionRequired) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                DriverRegisterConfig.step3SupportDesk,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {},
                            child: Row(
                              children: const [
                                Text(
                                  'Call Desk',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFC62828),
                                  ),
                                ),
                                SizedBox(width: 2),
                                Icon(Icons.arrow_forward,
                                    size: 12, color: Color(0xFFC62828)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // FOOTER LEGAL COMPLIANCE TEXT
                    Center(
                      child: Text(
                        isActionRequired
                            ? DriverRegisterConfig.step3DirectDepositFooter
                            : '⚖ Lethbridge Taxi Commission Bylaw 5834 Compliant',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // BOTTOM FIXED SUBMISSION BAR
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isUploading) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFC62828),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            DriverRegisterConfig.step3PleaseWaitForUploads,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFC62828),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (isActionRequired) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.info_outline,
                              size: 13, color: Color(0xFFD32F2F)),
                          SizedBox(width: 4),
                          Text(
                            DriverRegisterConfig.step3Fix1IssueWarning,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFD32F2F),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: ElevatedButton(
                        key: const ValueKey('driver_register_step3_submit_button'),
                        onPressed: isReady && !isSubmitting
                            ? () => bloc.add(const DriverRegisterStep3Submitted())
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC62828),
                          disabledBackgroundColor: const Color(0xFFE5E7EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: isReady ? 2 : 0,
                        ),
                        child: isSubmitting
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Submitting for review...',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                isReady
                                    ? 'Submit for review ➔'
                                    : 'Submit for review',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isReady
                                      ? Colors.white
                                      : const Color(0xFF9CA3AF),
                                ),
                              ),
                      ),
                    ),
                    if (isSubmitting) ...[
                      const SizedBox(height: 6),
                      const Text(
                        DriverRegisterConfig.step3DoNotCloseWarning,
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // UPLOAD MODAL OVERLAY (Screen 6)
              if (state.isUploadModalOpen)
                GestureDetector(
                  onTap: () =>
                      bloc.add(const DriverRegisterUploadModalDismissed()),
                  child: Container(
                    color: Colors.black54,
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {},
                      child: DriverDocumentUploadModal(
                        documentType: state.selectedDocumentForModal ??
                            DriverDocumentType.driversLicence,
                        onSourceSelected: (source) {
                          bloc.add(DriverRegisterDocumentUploadRequested(
                            documentType: state.selectedDocumentForModal ??
                                DriverDocumentType.driversLicence,
                            source: source,
                          ));
                        },
                        onDismiss: () {
                          bloc.add(const DriverRegisterUploadModalDismissed());
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
