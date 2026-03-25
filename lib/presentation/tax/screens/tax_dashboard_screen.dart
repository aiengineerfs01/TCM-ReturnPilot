/// =============================================================================
/// Tax Dashboard Screen
///
/// Main dashboard for tax return management showing:
/// - Current return status and progress
/// - Quick actions (start return, continue, view summary)
/// - Refund/amount owed estimate
/// - Section completion status
/// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/models/tax/tax_models.dart';
import 'package:tcm_return_pilot/presentation/tax/cubit/tax_return_cubit.dart';
import 'package:tcm_return_pilot/widgets/back_arrow.dart';

class TaxDashboardScreen extends StatefulWidget {
  const TaxDashboardScreen({super.key});

  static const String routeName = 'TaxDashboardScreen';
  static const String routePath = '/tax-dashboard';

  @override
  State<TaxDashboardScreen> createState() => _TaxDashboardScreenState();
}

class _TaxDashboardScreenState extends State<TaxDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: BlocBuilder<TaxReturnCubit, TaxReturnState>(
          builder: (context, state) {
            // Show loading state
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                // App Bar
                SliverToBoxAdapter(child: _buildHeader(theme)),

                // Tax Year Selector
                SliverToBoxAdapter(child: _buildTaxYearSelector(theme)),

                // Refund/Owed Summary Card
                SliverToBoxAdapter(child: _buildRefundSummaryCard(theme)),

                // Progress Section
                SliverToBoxAdapter(child: _buildProgressSection(theme)),

                // Quick Actions
                SliverToBoxAdapter(child: _buildQuickActions(theme)),

                // Section Cards
                SliverToBoxAdapter(child: _buildSectionCards(theme)),

                // Bottom Padding
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build the header with back button and title
  Widget _buildHeader(AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const BackArrow(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tax Dashboard',
                  style: poppinsSemiBold.copyWith(
                    fontSize: 24,
                    color: theme.primaryText,
                  ),
                ),
                Text(
                  'Tax Year ${context.read<TaxReturnCubit>().taxYear}',
                  style: poppinsRegular.copyWith(
                    fontSize: 14,
                    color: theme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          // Settings/Help button
          IconButton(
            onPressed: () {
              // TODO: Show tax help/settings
            },
            icon: Icon(Icons.help_outline, color: theme.primary),
          ),
        ],
      ),
    );
  }

  /// Tax year selector dropdown
  Widget _buildTaxYearSelector(AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.alternate.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, size: 18, color: theme.primary),
            const SizedBox(width: 8),
            Text(
              'Tax Year: ${context.read<TaxReturnCubit>().taxYear}',
              style: poppinsMedium.copyWith(color: theme.primaryText),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_drop_down, color: theme.secondaryText),
          ],
        ),
      ),
    );
  }

  /// Refund or amount owed summary card
  Widget _buildRefundSummaryCard(AppTheme theme) {
    final summary = context.read<TaxReturnCubit>().state.taxSummary;
    final isRefund = (summary?.refundAmount ?? 0) > 0;
    final amount = isRefund
        ? summary?.refundAmount ?? 0
        : summary?.amountOwed ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isRefund
                ? [const Color(0xFF2E7D32), const Color(0xFF4CAF50)]
                : [theme.primary, theme.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (isRefund ? Colors.green : theme.primary).withValues(
                alpha: 0.3,
              ),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isRefund ? Icons.savings : Icons.account_balance_wallet,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  isRefund ? 'Estimated Refund' : 'Estimated Amount Owed',
                  style: poppinsMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: poppinsBold.copyWith(color: Colors.white, fontSize: 36),
            ),
            const SizedBox(height: 8),
            Text(
              context.read<TaxReturnCubit>().taxReturn == null
                  ? 'Start your return to see estimate'
                  : 'Based on information provided',
              style: poppinsRegular.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Progress indicator section
  Widget _buildProgressSection(AppTheme theme) {
    final cubit = context.read<TaxReturnCubit>();
    final progress = cubit.completionPercentage / 100;
    final status = cubit.taxReturn?.status ?? ReturnStatus.draft;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Return Progress',
                  style: poppinsSemiBold.copyWith(
                    fontSize: 16,
                    color: theme.primaryText,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.displayName,
                    style: poppinsMedium.copyWith(
                      fontSize: 12,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: theme.alternate.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${cubit.completionPercentage.toInt()}% Complete',
              style: poppinsRegular.copyWith(
                fontSize: 12,
                color: theme.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Quick action buttons
  Widget _buildQuickActions(AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              theme: theme,
              icon: Icons.chat,
              label: 'Tax Interview',
              onTap: () {
                context.push('/interview');
              },
              isPrimary: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              theme: theme,
              icon: Icons.visibility,
              label: 'Review Return',
              onTap: () {
                context.push('/review');
              },
              isPrimary: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required AppTheme theme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? theme.primary : theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary
              ? null
              : Border.all(color: theme.alternate.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : theme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: poppinsMedium.copyWith(
                color: isPrimary ? Colors.white : theme.primaryText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section cards for different parts of the return
  Widget _buildSectionCards(AppTheme theme) {
    final cubit = context.read<TaxReturnCubit>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tax Return Sections',
            style: poppinsSemiBold.copyWith(
              fontSize: 18,
              color: theme.primaryText,
            ),
          ),
          const SizedBox(height: 12),

          // Personal Information
          _buildSectionCard(
            theme: theme,
            icon: Icons.person,
            title: 'Personal Information',
            subtitle: 'Filing status, dependents',
            isComplete: cubit.primaryTaxpayer != null,
            onTap: () {
              context.push('/personal-info');
            },
          ),

          // Income
          _buildSectionCard(
            theme: theme,
            icon: Icons.attach_money,
            title: 'Income',
            subtitle: 'W-2s, 1099s, other income',
            isComplete: cubit.hasIncome,
            badgeCount: cubit.w2Forms.length,
            onTap: () {
              context.push('/income-forms');
            },
          ),

          // Deductions
          _buildSectionCard(
            theme: theme,
            icon: Icons.receipt_long,
            title: 'Deductions',
            subtitle: 'Standard or itemized',
            isComplete: cubit.state.currentReturn?.deductions != null,
            onTap: () {
              context.push('/deductions');
            },
          ),

          // Credits
          _buildSectionCard(
            theme: theme,
            icon: Icons.card_giftcard,
            title: 'Credits',
            subtitle: 'Child tax credit, education, etc.',
            isComplete: cubit.state.currentReturn?.credits != null,
            onTap: () {
              // TODO: Navigate to credits screen
              _showComingSoon();
            },
          ),

          // Review & File
          _buildSectionCard(
            theme: theme,
            icon: Icons.check_circle,
            title: 'Review & File',
            subtitle: 'Review and submit your return',
            isComplete: cubit.taxReturn?.status == ReturnStatus.accepted,
            onTap: () {
              context.push('/review');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required AppTheme theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isComplete,
    int? badgeCount,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isComplete
                  ? Colors.green.withValues(alpha: 0.5)
                  : theme.alternate.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isComplete ? Colors.green : theme.primary).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isComplete ? Colors.green : theme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: poppinsMedium.copyWith(
                            fontSize: 16,
                            color: theme.primaryText,
                          ),
                        ),
                        if (badgeCount != null && badgeCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$badgeCount',
                              style: poppinsMedium.copyWith(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: poppinsRegular.copyWith(
                        fontSize: 12,
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isComplete ? Icons.check_circle : Icons.chevron_right,
                color: isComplete ? Colors.green : theme.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ReturnStatus status) {
    switch (status) {
      case ReturnStatus.draft:
      case ReturnStatus.notStarted:
        return Colors.grey;
      case ReturnStatus.inProgress:
        return Colors.blue;
      case ReturnStatus.readyForReview:
        return Colors.orange;
      case ReturnStatus.readyToFile:
        return Colors.orange;
      case ReturnStatus.submitted:
        return Colors.purple;
      case ReturnStatus.accepted:
        return Colors.green;
      case ReturnStatus.rejected:
        return Colors.red;
      case ReturnStatus.amended:
        return Colors.amber;
    }
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This feature is coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
