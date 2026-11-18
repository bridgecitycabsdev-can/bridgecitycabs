import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/driver_earnings_status.dart';
import '../../data/repositories/driver_earnings_repository.dart';
import '../bloc/driver_earnings_bloc.dart';
import '../bloc/driver_earnings_event.dart';
import '../bloc/driver_earnings_state.dart';
import 'widgets/driver_earnings_bank_card.dart';
import 'widgets/driver_earnings_banking_view.dart';
import 'widgets/driver_earnings_chart_card.dart';
import 'widgets/driver_earnings_filter_sheet.dart';
import 'widgets/driver_earnings_hero_card.dart';
import 'widgets/driver_earnings_qa_bar.dart';
import 'widgets/driver_earnings_split_card.dart';
import 'widgets/driver_earnings_statement_view.dart';
import 'widgets/driver_earnings_statements_card.dart';
import 'widgets/driver_earnings_tab_toggle.dart';

class DriverEarningsPage extends StatelessWidget {
  final DriverEarningsStatus initialStatus;
  final DriverEarningsRepository? repository;

  const DriverEarningsPage({
    super.key,
    this.initialStatus = DriverEarningsStatus.overview,
    this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DriverEarningsBloc>(
      create: (_) => DriverEarningsBloc(
        repository: repository ?? FakeDriverEarningsRepository(),
      )..add(DriverEarningsStarted(initialStatus: initialStatus)),
      child: const _DriverEarningsPageContent(),
    );
  }
}

class _DriverEarningsPageContent extends StatelessWidget {
  const _DriverEarningsPageContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverEarningsBloc, DriverEarningsState>(
      listenWhen: (prev, curr) =>
          prev.feedbackMessage != curr.feedbackMessage &&
          curr.feedbackMessage != null,
      listener: (context, state) {
        if (state.feedbackMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.feedbackMessage!),
              duration: const Duration(seconds: 2),
              backgroundColor: const Color(0xFF222831),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<DriverEarningsBloc>();

        Widget bodyContent;
        if (state.isBankingForm) {
          bodyContent = DriverEarningsBankingView(
            bankDetails: state.bankForm,
            isLoading: state.isActionLoading,
            onBack: () => bloc.add(const DriverEarningsBackToOverviewPressed()),
            onSave: (details) {
              bloc.add(DriverEarningsBankDetailsUpdated(details));
              bloc.add(const DriverEarningsBankDetailsSaved());
            },
          );
        } else if (state.isStatementDetail && state.activeStatement != null) {
          bodyContent = DriverEarningsStatementView(
            statement: state.activeStatement!,
            onBack: () => bloc.add(const DriverEarningsBackToOverviewPressed()),
            onDownloadPdf: () => bloc.add(
              DriverEarningsDownloadPdfRequested(state.activeStatement!.id),
            ),
          );
        } else {
          // Default Overview View (and Period Filter bottom sheet overlay)
          bodyContent = Scaffold(
            backgroundColor: const Color(0xFFFBF8F8),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              title: const Text(
                'Active Dispatch Run',
                style: TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.help_outline_rounded,
                    color: Color(0xFF424242),
                  ),
                  onPressed: () {},
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B0000),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            body: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    bloc.add(const DriverEarningsPeriodFilterApplied());
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Hero Earnings Card
                        DriverEarningsHeroCard(
                          summary: state.summary,
                          onPeriodDropdownTap: () => bloc.add(
                            const DriverEarningsPeriodFilterRequested(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tab Toggle (Overview / Cash vs Card)
                        DriverEarningsTabToggle(
                          activeTabIndex: state.activeTabIndex,
                          onTabChanged: (index) =>
                              bloc.add(DriverEarningsTabSwitched(index)),
                        ),
                        const SizedBox(height: 16),

                        // Payment Split Card
                        DriverEarningsSplitCard(
                          split: state.summary.split,
                        ),
                        const SizedBox(height: 16),

                        // Daily Earnings Bar Chart
                        DriverEarningsChartCard(
                          dateRangeText: state.summary.periodDateRange,
                          zoneLabel: state.summary.zoneLabel,
                          dailyPoints: state.summary.dailyPoints,
                        ),
                        const SizedBox(height: 16),

                        // Bank Account Card
                        DriverEarningsBankCard(
                          bankDetails: state.summary.bankDetails,
                          onTap: () => bloc.add(
                            const DriverEarningsBankingCardTapped(),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Statements List Card
                        DriverEarningsStatementsCard(
                          statements: state.summary.recentStatements,
                          onStatementTap: (id) => bloc.add(
                            DriverEarningsStatementSelected(id),
                          ),
                          onSeeAllTap: () => bloc.add(
                            const DriverEarningsStatementSelected('stmt_1'),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Period Filter Modal Bottom Sheet Overlay
                if (state.isPeriodFilterVisible) ...[
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => bloc.add(
                        const DriverEarningsPeriodFilterDismissed(),
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: DriverEarningsFilterSheet(
                      selectedPeriod: state.selectedPeriod,
                      customStartDate: state.customStartDate,
                      customEndDate: state.customEndDate,
                      isCustomExpanded: state.isCustomRangeExpanded,
                      onPeriodSelected: (period) =>
                          bloc.add(DriverEarningsPeriodSelected(period)),
                      onStartDateChanged: (start) => bloc.add(
                        DriverEarningsCustomRangeConfigured(
                          startDate: start,
                          endDate: state.customEndDate,
                        ),
                      ),
                      onEndDateChanged: (end) => bloc.add(
                        DriverEarningsCustomRangeConfigured(
                          startDate: state.customStartDate,
                          endDate: end,
                        ),
                      ),
                      onApply: () =>
                          bloc.add(const DriverEarningsPeriodFilterApplied()),
                      onClose: () =>
                          bloc.add(const DriverEarningsPeriodFilterDismissed()),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return Column(
          children: [
            // Floating QA Bar for immediate screen switching & visual verification
            DriverEarningsQABar(
              currentStatus: state.status,
              onStatusSelected: (status) =>
                  bloc.add(DriverEarningsStateForced(status)),
            ),
            Expanded(child: bodyContent),
          ],
        );
      },
    );
  }
}
