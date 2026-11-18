import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/driver_support_bloc.dart';
import '../../bloc/driver_support_event.dart';
import '../../bloc/driver_support_state.dart';
import '../../data/models/driver_support_form_state.dart';
import '../../data/models/driver_support_status.dart';
import '../../data/models/driver_support_topic.dart';

class DriverSupportNewTicketView extends StatelessWidget {
  final DriverSupportState state;

  const DriverSupportNewTicketView({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUiStateInspector(context),
          const SizedBox(height: 16),
          _buildTopicSelector(context),
          const SizedBox(height: 18),
          _buildSubjectField(context),
          const SizedBox(height: 18),
          _buildLinkedTripSection(context),
          const SizedBox(height: 18),
          _buildDescribeIssueSection(context),
          const SizedBox(height: 14),
          if (state.hasAttachment) _buildAttachmentCard(context),
          const SizedBox(height: 20),
          _buildSubmitTicketButton(context),
          const SizedBox(height: 24),
          _buildUrgentSafetyCard(context),
        ],
      ),
    );
  }

  Widget _buildUiStateInspector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF4F4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8D5D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                children: [
                  Icon(Icons.tune, size: 14, color: Color(0xFF8B181B)),
                  SizedBox(width: 6),
                  Text(
                    'UI STATE INSPECTOR',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF8B181B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Text(
                'Lethbridge Driver Ops',
                style: TextStyle(fontSize: 10, color: Color(0xFF757575)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: DriverSupportFormInspectorState.values.map((s) {
              final isSelected = state.formInspectorState == s;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    onTap: () {
                      context.read<DriverSupportBloc>().add(
                            DriverSupportSetFormInspectorState(s),
                          );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: isSelected
                            ? Border.all(color: const Color(0xFF8B181B))
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        s.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? const Color(0xFF8B181B) : const Color(0xFF555555),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Row(
              children: [
                Text(
                  'What is this about? ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                Text(
                  '*',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF8B181B),
                  ),
                ),
              ],
            ),
            Text(
              'Tap to pick',
              style: TextStyle(fontSize: 11, color: Color(0xFF757575)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DriverSupportTopic.values.map((topic) {
            final isSelected = state.selectedTopic == topic;
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    const Icon(Icons.check, size: 14, color: Color(0xFF8B181B)),
                    const SizedBox(width: 4),
                  ],
                  Text(topic.label),
                ],
              ),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF8B181B) : const Color(0xFF424242),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFFFBECEC),
              backgroundColor: const Color(0xFFF1EFEF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF8B181B) : const Color(0xFFE0DBDB),
                ),
              ),
              showCheckmark: false,
              onSelected: (_) {
                context.read<DriverSupportBloc>().add(
                      DriverSupportSelectTopic(topic),
                    );
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubjectField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SUBJECT',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFF4A4A4A),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1EFEF),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: state.subject)
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: state.subject.length),
                    ),
                  onChanged: (text) {
                    context.read<DriverSupportBloc>().add(
                          DriverSupportSubjectChanged(text),
                        );
                  },
                  style: const TextStyle(fontSize: 13, color: Color(0xFF1E1E1E)),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              if (state.subject.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    context.read<DriverSupportBloc>().add(
                          const DriverSupportSubjectChanged(''),
                        );
                  },
                  child: const Icon(Icons.close, size: 16, color: Color(0xFF757575)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinkedTripSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'LINKED TRIP',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF4A4A4A),
                letterSpacing: 0.5,
              ),
            ),
            Row(
              children: [
                Icon(Icons.history, size: 13, color: Color(0xFF8B181B)),
                SizedBox(width: 4),
                Text(
                  'Recent Fares',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8B181B),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1EFEF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2DDDD)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFFBECEC),
                child: const Icon(
                  Icons.local_taxi,
                  size: 18,
                  color: Color(0xFF8B181B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Trip #${state.linkedTripId}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2A2A2A),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'COMPLETED',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.linkedTripRoute,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF6B6565)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.linkedTripDate,
                      style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${state.linkedTripFare.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF8B181B),
                    ),
                  ),
                  const Text(
                    'CAD',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B181B),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              const Icon(Icons.link, size: 16, color: Color(0xFF757575)),
              const Icon(Icons.chevron_right, size: 16, color: Color(0xFF757575)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescribeIssueSection(BuildContext context) {
    final charCount = state.description.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'DESCRIBE YOUR ISSUE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF4A4A4A),
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '$charCount / 500',
              style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1EFEF),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: TextEditingController(text: state.description)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: state.description.length),
              ),
            onChanged: (text) {
              context.read<DriverSupportBloc>().add(
                    DriverSupportDescriptionChanged(text),
                  );
            },
            maxLines: 4,
            style: const TextStyle(fontSize: 12, color: Color(0xFF1E1E1E), height: 1.35),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              hintText: 'Provide details about your fare, passenger, or equipment...',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EFEF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2DDDD)),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, size: 20, color: Color(0xFF555555)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.attachmentName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2A2A2A),
                  ),
                ),
                Text(
                  state.attachmentSize,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF757575)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: Color(0xFF757575)),
            onPressed: () {
              context.read<DriverSupportBloc>().add(
                    const DriverSupportToggleAttachment(false),
                  );
            },
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitTicketButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: state.isLoading
            ? null
            : () {
                context.read<DriverSupportBloc>().add(
                      const DriverSupportSubmitTicketPressed(),
                    );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B181B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 1,
        ),
        icon: state.isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.send_rounded, size: 18),
        label: Text(
          state.isLoading ? 'Submitting ticket...' : 'Submit Ticket',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildUrgentSafetyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EFEF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2DDDD)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: const Color(0xFFFBECEC),
            child: const Icon(
              Icons.headset_mic_outlined,
              size: 18,
              color: Color(0xFF8B181B),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Urgent Safety Emergency?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'For immediate vehicle support or safety threats, contact Cab Dispatch directly.',
                  style: TextStyle(fontSize: 10, color: Color(0xFF6B6565), height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              context.read<DriverSupportBloc>().add(
                    const DriverSupportSwitchView(DriverSupportViewStatus.emergencySos),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1E1E1E),
              elevation: 0,
              side: const BorderSide(color: Color(0xFFD6D1D1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            icon: const Icon(Icons.phone, size: 14, color: Color(0xFF1E1E1E)),
            label: const Text(
              'Call',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
