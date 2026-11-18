import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/driver_profile_bloc.dart';
import '../bloc/driver_profile_event.dart';
import '../bloc/driver_profile_state.dart';
import '../data/models/driver_profile_status.dart';
import '../data/models/driver_profile_tab.dart';
import '../data/repositories/driver_profile_repository.dart';
import 'widgets/driver_profile_documents_tab.dart';
import 'widgets/driver_profile_expired_banner.dart';
import 'widgets/driver_profile_header_card.dart';
import 'widgets/driver_profile_info_tab.dart';
import 'widgets/driver_profile_inspection_sheet.dart';
import 'widgets/driver_profile_offline_banner.dart';
import 'widgets/driver_profile_qa_bar.dart';
import 'widgets/driver_profile_tab_bar.dart';
import 'widgets/driver_profile_warning_banner.dart';

class DriverProfilePage extends StatelessWidget {
  final DriverProfileRepository? repository;
  final DriverProfileStatus initialStatus;

  const DriverProfilePage({
    super.key,
    this.repository,
    this.initialStatus = DriverProfileStatus.activeOnline,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverProfileBloc(
        repository: repository ?? FakeDriverProfileRepository(),
      )..add(DriverProfileStarted(initialStatus: initialStatus)),
      child: const _DriverProfilePageContent(),
    );
  }
}

class _DriverProfilePageContent extends StatelessWidget {
  const _DriverProfilePageContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverProfileBloc, DriverProfileState>(
      listenWhen: (previous, current) =>
          previous.feedbackMessage != current.feedbackMessage,
      listener: (context, state) {
        if (state.feedbackMessage != null && state.feedbackMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.feedbackMessage!),
              duration: const Duration(seconds: 2),
              backgroundColor: state.isCredentialExpiredLocked
                  ? const Color(0xFFC62828)
                  : const Color(0xFF2E7D32),
            ),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<DriverProfileBloc>();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go('/home');
                }
              },
            ),
            title: Row(
              children: [
                const Text(
                  'Driver Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: state.isActiveOnline || state.isExpiringSoonInspection
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 6,
                        color: state.isActiveOnline || state.isExpiringSoonInspection
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC62828),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        state.isActiveOnline || state.isExpiringSoonInspection
                            ? 'ACTIVE'
                            : 'INACTIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: state.isActiveOnline || state.isExpiringSoonInspection
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFC62828),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.black54),
                onPressed: () {},
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFFC62828),
                  child: const Icon(Icons.person, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              // Scrollable Profile Content
              Column(
                children: [
                  // Dynamic Alert Banners
                  if (state.isCredentialExpiredLocked)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      child: DriverProfileExpiredBanner(),
                    )
                  else if (state.isExpiringSoonInspection)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      child: DriverProfileWarningBanner(),
                    )
                  else if (state.isOfflineSyncAlert)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      child: DriverProfileOfflineBanner(
                        isLoading: state.isActionLoading,
                        onRetry: () {
                          bloc.add(const DriverProfileSyncRetryPressed());
                        },
                      ),
                    ),

                  // Header Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    child: DriverProfileHeaderCard(
                      profileData: state.profileData,
                      status: state.status,
                    ),
                  ),

                  // Tab Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: DriverProfileTabBar(
                      activeTab: state.activeTab,
                      availableTabs: state.availableTabs,
                      hasDocumentAlert: state.isCredentialExpiredLocked,
                      onTabChanged: (tab) {
                        bloc.add(DriverProfileTabChanged(tab));
                      },
                    ),
                  ),

                  // Active Tab Body
                  Expanded(
                    child: _buildTabBody(context, state, bloc),
                  ),
                ],
              ),

              // Active Inspection Bottom Sheet Modal (State 3)
              if (state.isInspectionModalVisible)
                Container(
                  color: Colors.black45,
                  alignment: Alignment.bottomCenter,
                  child: DriverProfileInspectionSheet(
                    credential: state.inspectedCredential!,
                    onReplaceDocument: () {
                      bloc.add(
                        DriverProfileUploadRequested(
                          state.inspectedCredential!.id,
                        ),
                      );
                      bloc.add(const DriverProfileInspectionDismissed());
                    },
                    onClose: () {
                      bloc.add(const DriverProfileInspectionDismissed());
                    },
                  ),
                ),

              // QA Matrix Floating Switcher
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: DriverProfileQaBar(activeStatus: state.status),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBody(
    BuildContext context,
    DriverProfileState state,
    DriverProfileBloc bloc,
  ) {
    switch (state.activeTab) {
      case DriverProfileTab.info:
        return DriverProfileInfoTab(
          profileData: state.profileData,
          onContactSupport: () {
            bloc.add(const DriverProfileContactSupportPressed());
          },
        );
      case DriverProfileTab.documents:
        return DriverProfileDocumentsTab(
          credentials: state.profileData.credentials,
          status: state.status,
          onCredentialTap: (cred) {
            bloc.add(DriverProfileCredentialTapped(cred));
          },
          onUploadRequested: (credId) {
            bloc.add(DriverProfileUploadRequested(credId));
          },
          onCallDesk: () {
            bloc.add(const DriverProfileContactSupportPressed());
          },
          onUpdateDocuments: () {
            bloc.add(const DriverProfileContactSupportPressed());
          },
        );
      case DriverProfileTab.activity:
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9FB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.timeline, size: 36, color: Colors.black38),
                  SizedBox(height: 10),
                  Text(
                    'No shift activity recorded',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Start your first shift to view trip logs and dispatch history.',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }
}
