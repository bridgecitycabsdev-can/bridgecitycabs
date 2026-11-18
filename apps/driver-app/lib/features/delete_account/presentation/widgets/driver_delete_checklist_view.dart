import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/driver_delete_account_bloc.dart';
import '../../bloc/driver_delete_account_event.dart';
import '../../bloc/driver_delete_account_state.dart';

class DriverDeleteChecklistView extends StatelessWidget {
  final DriverDeleteAccountState state;

  const DriverDeleteChecklistView({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final checklist = state.checklist;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroHeader(),
          const SizedBox(height: 20),
          _buildBeforeYouGoSection(context),
          const SizedBox(height: 18),
          _buildWhatWillBeDeletedSection(checklist?.whatWillBeDeleted ?? const []),
          const SizedBox(height: 18),
          _buildWhatMayBeKeptSection(
            checklist?.whatMayBeKept ?? const [],
            checklist?.anonymizedNotice ?? '',
          ),
          const SizedBox(height: 18),
          _buildReflectionPeriodCard(checklist?.reflectionPeriodText ?? ''),
          const SizedBox(height: 24),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFFBECEC),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFF8B181B),
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Delete your driver account?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E1E1E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'You\'ll stop receiving ride requests and your driver profile will be removed after a short waiting period.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B6565),
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBeforeYouGoSection(BuildContext context) {
    final isReady = state.canProceedWithDeletion;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E4E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.checklist, size: 16, color: Color(0xFF8B181B)),
                  SizedBox(width: 6),
                  Text(
                    'Before you go',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isReady ? const Color(0xFFE8F5E9) : const Color(0xFFFDE8E8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 6,
                      color: isReady ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isReady ? 'Ready to proceed' : 'Safeguard blocked',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isReady ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.checklist != null)
            ...state.checklist!.items.map((item) {
              final isPassed = item.hasTestHold ? !state.isTestHoldActive : item.isPassed;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isPassed ? Icons.check_circle_outline : Icons.cancel_outlined,
                      size: 16,
                      color: isPassed ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                          Text(
                            item.subtitle,
                            style: const TextStyle(fontSize: 10, color: Color(0xFF757575)),
                          ),
                        ],
                      ),
                    ),
                    if (item.hasTestHold)
                      OutlinedButton(
                        onPressed: () {
                          context.read<DriverDeleteAccountBloc>().add(
                                const DriverDeleteToggleTestHold(),
                              );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          minimumSize: const Size(50, 24),
                          side: const BorderSide(color: Color(0xFFC62828)),
                        ),
                        child: Text(
                          state.isTestHoldActive ? 'Clear Hold' : 'Test Hold',
                          style: const TextStyle(fontSize: 10, color: Color(0xFFC62828)),
                        ),
                      ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, size: 14, color: Color(0xFF555555)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Resolve any open items first so you get paid everything you\'re owed before account termination.',
                    style: TextStyle(fontSize: 10, color: Color(0xFF555555), height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatWillBeDeletedSection(List<String> items) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E4E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.delete_outline, size: 16, color: Color(0xFF8B181B)),
              SizedBox(width: 6),
              Text(
                'What will be deleted',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E1E1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFDE8E8),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.remove, size: 10, color: Color(0xFF8B181B)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF333333)),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildWhatMayBeKeptSection(List<String> items, String notice) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E4E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline, size: 16, color: Color(0xFF555555)),
              SizedBox(width: 6),
              Text(
                'What may be kept',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E1E1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF4A4A4A), height: 1.3),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          Text(
            notice,
            style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Color(0xFF757575)),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionPeriodCard(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.access_time, size: 18, color: Color(0xFF856404)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '30-day reflection period',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF856404),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF66512C), height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<DriverDeleteAccountBloc>().add(
                    const DriverDeleteCancelRequested(),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B181B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.shield_outlined, size: 18),
            label: const Text(
              'Keep my account',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () {
              context.read<DriverDeleteAccountBloc>().add(
                    const DriverDeleteProceedToConfirmation(),
                  );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF8B181B),
              side: const BorderSide(color: Color(0xFFECD6D6)),
              backgroundColor: const Color(0xFFFDF2F2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              '→ Continue to delete',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
