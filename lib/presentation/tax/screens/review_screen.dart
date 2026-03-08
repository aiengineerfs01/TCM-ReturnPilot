/// =============================================================================
/// Review Screen
///
/// Final review of tax return before submission:
/// - Summary of all income, deductions, credits
/// - Tax calculation breakdown
/// - Refund or amount owed
/// - Submit for e-filing
/// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/presentation/tax/cubit/tax_return_cubit.dart';
import 'package:tcm_return_pilot/widgets/back_arrow.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  static const String routeName = 'ReviewScreen';
  static const String routePath = '/review';

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            Expanded(
              child: BlocBuilder<TaxReturnCubit, TaxReturnState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final summary = state.taxSummary;
                  if (summary == null) {
                    return _buildNoDataView(theme);
                  }

                  final cubit = context.read<TaxReturnCubit>();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Refund/Owed Card
                        _buildResultCard(theme, summary),
                        const SizedBox(height: 24),

                        // Income Summary
                        _buildSection(
                          theme: theme,
                          title: 'Income',
                          icon: Icons.attach_money,
                          items: [
                            _SummaryItem('Total Income', summary.totalIncome),
                            _SummaryItem(
                              'Adjustments',
                              -summary.adjustmentsToIncome,
                            ),
                            _SummaryItem(
                              'Adjusted Gross Income (AGI)',
                              summary.agi,
                              isBold: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Deductions Summary
                        _buildSection(
                          theme: theme,
                          title: 'Deductions',
                          icon: Icons.receipt_long,
                          items: [
                            _SummaryItem(
                                'Total Deductions', summary.deductions),
                            _SummaryItem(
                              'Taxable Income',
                              summary.taxableIncome,
                              isBold: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Tax Calculation
                        _buildSection(
                          theme: theme,
                          title: 'Tax Calculation',
                          icon: Icons.calculate,
                          items: [
                            _SummaryItem(
                              'Federal Income Tax',
                              summary.federalIncomeTax,
                            ),
                            if (summary.selfEmploymentTax > 0)
                              _SummaryItem(
                                'Self-Employment Tax',
                                summary.selfEmploymentTax,
                              ),
                            _SummaryItem(
                              'Total Tax',
                              summary.totalTax,
                              isBold: true,
                            ),
                            _SummaryItem(
                              'Effective Tax Rate',
                              null,
                              rate: summary.effectiveRate,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Credits & Payments
                        _buildSection(
                          theme: theme,
                          title: 'Credits & Payments',
                          icon: Icons.card_giftcard,
                          items: [
                            _SummaryItem(
                              'Nonrefundable Credits',
                              -summary.totalCredits,
                            ),
                            _SummaryItem(
                              'Refundable Credits',
                              summary.totalRefundableCredits,
                            ),
                            _SummaryItem(
                                'Withholding', summary.totalWithholding),
                            _SummaryItem(
                              'Total Payments',
                              summary.totalPayments,
                              isBold: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Validation Errors (if any)
                        _buildValidationSection(theme, cubit),
                        const SizedBox(height: 16),

                        // Submit Button
                        _buildSubmitButton(context, theme, cubit),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                  'Review & File',
                  style: poppinsSemiBold.copyWith(
                    fontSize: 24,
                    color: theme.primaryText,
                  ),
                ),
                Text(
                  'Review your return before filing',
                  style: poppinsRegular.copyWith(
                    fontSize: 14,
                    color: theme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataView(AppTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: theme.secondaryText,
          ),
          const SizedBox(height: 16),
          Text(
            'No tax return data',
            style: poppinsMedium.copyWith(
              fontSize: 18,
              color: theme.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your tax return to see the summary',
            style: poppinsRegular.copyWith(
              fontSize: 14,
              color: theme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(AppTheme theme, TaxSummary summary) {
    final isRefund = summary.refundAmount > 0;
    final amount = isRefund ? summary.refundAmount : summary.amountOwed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isRefund
              ? [const Color(0xFF2E7D32), const Color(0xFF4CAF50)]
              : [const Color(0xFFD32F2F), const Color(0xFFE57373)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isRefund ? Colors.green : Colors.red).withValues(
              alpha: 0.3,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            isRefund ? Icons.savings : Icons.account_balance_wallet,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            isRefund ? 'Your Estimated Refund' : 'Amount You Owe',
            style: poppinsMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: poppinsBold.copyWith(color: Colors.white, fontSize: 42),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isRefund
                  ? 'You\'re getting money back!'
                  : 'Payment due April 15, 2025',
              style: poppinsMedium.copyWith(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required AppTheme theme,
    required String title,
    required IconData icon,
    required List<_SummaryItem> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: poppinsSemiBold.copyWith(
                  fontSize: 16,
                  color: theme.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => _buildSummaryRow(theme, item)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(AppTheme theme, _SummaryItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.label,
            style: (item.isBold ? poppinsMedium : poppinsRegular).copyWith(
              fontSize: 14,
              color: theme.primaryText,
            ),
          ),
          if (item.rate != null)
            Text(
              '${item.rate!.toStringAsFixed(1)}%',
              style: poppinsMedium.copyWith(fontSize: 14, color: theme.primary),
            )
          else
            Text(
              item.amount! >= 0
                  ? '\$${item.amount!.toStringAsFixed(2)}'
                  : '-\$${item.amount!.abs().toStringAsFixed(2)}',
              style: (item.isBold ? poppinsSemiBold : poppinsRegular).copyWith(
                fontSize: 14,
                color: item.amount! < 0 ? Colors.green : theme.primaryText,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildValidationSection(
    AppTheme theme,
    TaxReturnCubit cubit,
  ) {
    final errors = cubit.state.validationErrors;
    if (errors.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ready to File',
                    style: poppinsMedium.copyWith(
                      fontSize: 14,
                      color: Colors.green.shade800,
                    ),
                  ),
                  Text(
                    'Your return has passed all validation checks',
                    style: poppinsRegular.copyWith(
                      fontSize: 12,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Issues Found (${errors.length})',
                style: poppinsMedium.copyWith(
                  fontSize: 14,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...errors.map(
            (error) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.orange,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error.message,
                      style: poppinsRegular.copyWith(
                        fontSize: 12,
                        color: theme.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(
      BuildContext context, AppTheme theme, TaxReturnCubit cubit) {
    final hasErrors = cubit.state.validationErrors.isNotEmpty;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: hasErrors
                ? null
                : () => _showSubmitDialog(context, theme, cubit),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasErrors ? theme.secondaryText : theme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.send),
                const SizedBox(width: 8),
                Text(
                  'Submit for E-Filing',
                  style: poppinsSemiBold.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        if (hasErrors)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please resolve all issues before filing',
              style: poppinsRegular.copyWith(
                fontSize: 12,
                color: theme.secondaryText,
              ),
            ),
          ),
      ],
    );
  }

  void _showSubmitDialog(
    BuildContext context,
    AppTheme theme,
    TaxReturnCubit cubit,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.verified_user, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              'Ready to File?',
              style: poppinsSemiBold.copyWith(fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'By submitting, you confirm that:',
              style: poppinsMedium.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildCheckItem('All information is accurate'),
            _buildCheckItem('You have reviewed your return'),
            _buildCheckItem('You authorize e-filing'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'E-file submission is a demo feature',
                      style: poppinsRegular.copyWith(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _submitReturn(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Text(text, style: poppinsRegular.copyWith(fontSize: 13)),
        ],
      ),
    );
  }

  void _submitReturn(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tax return submitted successfully! (Demo)'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

class _SummaryItem {
  final String label;
  final double? amount;
  final double? rate;
  final bool isBold;

  _SummaryItem(this.label, this.amount, {this.rate, this.isBold = false});
}
