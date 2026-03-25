/// =============================================================================
/// Income Forms Screen
///
/// Displays all income forms (W-2s, 1099s) for the current tax return.
/// Allows adding, viewing, and editing income forms.
/// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/models/tax/tax_models.dart';
import 'package:tcm_return_pilot/presentation/tax/cubit/tax_return_cubit.dart';
import 'package:tcm_return_pilot/widgets/back_arrow.dart';

class IncomeFormsScreen extends StatelessWidget {
  const IncomeFormsScreen({super.key});

  static const String routeName = 'IncomeFormsScreen';
  static const String routePath = '/income-forms';

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final cubit = context.read<TaxReturnCubit>();

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, theme),

            // Content
            Expanded(
              child: BlocBuilder<TaxReturnCubit, TaxReturnState>(
                builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Income Summary Card
                      _buildIncomeSummaryCard(theme, cubit),
                      const SizedBox(height: 24),

                      // W-2 Forms Section
                      _buildSectionHeader(
                        theme: theme,
                        title: 'W-2 Forms',
                        subtitle: 'Wages from employers',
                        onAdd: () => _navigateToAddW2(context),
                      ),
                      const SizedBox(height: 12),
                      _buildW2FormsList(context, theme, cubit),
                      const SizedBox(height: 24),

                      // 1099 Forms Section
                      _buildSectionHeader(
                        theme: theme,
                        title: '1099 Forms',
                        subtitle: 'Other income sources',
                        onAdd: () => _showAdd1099Options(context, theme),
                      ),
                      const SizedBox(height: 12),
                      _build1099FormsList(context, theme, cubit),
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

  Widget _buildHeader(BuildContext context, AppTheme theme) {
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
                  'Income',
                  style: poppinsSemiBold.copyWith(
                    fontSize: 24,
                    color: theme.primaryText,
                  ),
                ),
                Text(
                  'W-2s, 1099s and other income',
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

  Widget _buildIncomeSummaryCard(
    AppTheme theme,
    TaxReturnCubit cubit,
  ) {
    final totalW2 = cubit.state.currentReturn?.totalW2Wages ?? 0;
    final total1099 = _calculateTotal1099Income(cubit);
    final totalIncome = totalW2 + total1099;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primary, theme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Income',
            style: poppinsMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${totalIncome.toStringAsFixed(2)}',
            style: poppinsBold.copyWith(color: Colors.white, fontSize: 32),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildIncomeItem('W-2 Wages', totalW2, theme),
              const SizedBox(width: 24),
              _buildIncomeItem('1099 Income', total1099, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeItem(String label, double amount, AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: poppinsRegular.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: poppinsSemiBold.copyWith(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required AppTheme theme,
    required String title,
    required String subtitle,
    required VoidCallback onAdd,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: poppinsSemiBold.copyWith(
                fontSize: 18,
                color: theme.primaryText,
              ),
            ),
            Text(
              subtitle,
              style: poppinsRegular.copyWith(
                fontSize: 12,
                color: theme.secondaryText,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.add, size: 18, color: theme.primary),
                const SizedBox(width: 4),
                Text(
                  'Add',
                  style: poppinsMedium.copyWith(
                    color: theme.primary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildW2FormsList(
    BuildContext context,
    AppTheme theme,
    TaxReturnCubit cubit,
  ) {
    final w2Forms = cubit.w2Forms;

    if (w2Forms.isEmpty) {
      return _buildEmptyState(
        theme: theme,
        icon: Icons.description_outlined,
        message: 'No W-2 forms added yet',
        actionLabel: 'Add W-2',
        onAction: () => _navigateToAddW2(context),
      );
    }

    return Column(
      children: w2Forms
          .map((w2) => _buildW2Card(context, theme, w2, cubit))
          .toList(),
    );
  }

  Widget _buildW2Card(
    BuildContext context,
    AppTheme theme,
    W2Form w2,
    TaxReturnCubit cubit,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          context.push('/w2-form', extra: {'w2': w2});
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.alternate.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.work, color: theme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      w2.employerName,
                      style: poppinsMedium.copyWith(
                        fontSize: 16,
                        color: theme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Wages: \$${w2.box1Wages.toStringAsFixed(2)}',
                      style: poppinsRegular.copyWith(
                        fontSize: 14,
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              // Delete button
              IconButton(
                onPressed: () => _confirmDeleteW2(context, cubit, w2),
                icon: Icon(Icons.delete_outline, color: theme.error),
              ),
              Icon(Icons.chevron_right, color: theme.secondaryText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build1099FormsList(
    BuildContext context,
    AppTheme theme,
    TaxReturnCubit cubit,
  ) {
    final complete = cubit.state.currentReturn;
    if (complete == null) {
      return _buildEmptyState(
        theme: theme,
        icon: Icons.receipt_outlined,
        message: 'No 1099 forms added yet',
        actionLabel: 'Add 1099',
        onAction: () => _showAdd1099Options(context, theme),
      );
    }

    final List<Widget> forms = [];

    // 1099-INT forms
    for (final form in complete.form1099Int) {
      forms.add(
        _build1099Card(
          context,
          theme,
          type: '1099-INT',
          payerName: form.payerName,
          amount: form.box1InterestIncome,
          onTap: () => context.push('/form-1099', extra: {'type': '1099-INT', 'form': form}),
        ),
      );
    }

    // 1099-DIV forms
    for (final form in complete.form1099Div) {
      forms.add(
        _build1099Card(
          context,
          theme,
          type: '1099-DIV',
          payerName: form.payerName,
          amount: form.box1aOrdinaryDividends,
          onTap: () => context.push('/form-1099', extra: {'type': '1099-DIV', 'form': form}),
        ),
      );
    }

    // 1099-NEC forms
    for (final form in complete.form1099Nec) {
      forms.add(
        _build1099Card(
          context,
          theme,
          type: '1099-NEC',
          payerName: form.payerName,
          amount: form.box1NonemployeeCompensation,
          onTap: () => context.push('/form-1099', extra: {'type': '1099-NEC', 'form': form}),
        ),
      );
    }

    // 1099-R forms
    for (final form in complete.form1099R) {
      forms.add(
        _build1099Card(
          context,
          theme,
          type: '1099-R',
          payerName: form.payerName,
          amount: form.box1GrossDistribution,
          onTap: () => context.push('/form-1099', extra: {'type': '1099-R', 'form': form}),
        ),
      );
    }

    // 1099-G forms
    for (final form in complete.form1099G) {
      forms.add(
        _build1099Card(
          context,
          theme,
          type: '1099-G',
          payerName: form.payerName,
          amount: form.box1Unemployment,
          onTap: () => context.push('/form-1099', extra: {'type': '1099-G', 'form': form}),
        ),
      );
    }

    // SSA-1099 forms
    for (final form in complete.formSsa1099) {
      forms.add(
        _build1099Card(
          context,
          theme,
          type: 'SSA-1099',
          payerName: 'Social Security Administration',
          amount: form.box5NetBenefits,
          onTap: () => context.push('/form-1099', extra: {'type': 'SSA-1099', 'form': form}),
        ),
      );
    }

    if (forms.isEmpty) {
      return _buildEmptyState(
        theme: theme,
        icon: Icons.receipt_outlined,
        message: 'No 1099 forms added yet',
        actionLabel: 'Add 1099',
        onAction: () => _showAdd1099Options(context, theme),
      );
    }

    return Column(children: forms);
  }

  Widget _build1099Card(
    BuildContext context,
    AppTheme theme, {
    required String type,
    required String payerName,
    required double amount,
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
            border: Border.all(color: theme.alternate.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Colors.orange,
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            type,
                            style: poppinsMedium.copyWith(
                              fontSize: 10,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            payerName,
                            style: poppinsMedium.copyWith(
                              fontSize: 14,
                              color: theme.primaryText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Amount: \$${amount.toStringAsFixed(2)}',
                      style: poppinsRegular.copyWith(
                        fontSize: 14,
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.secondaryText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required AppTheme theme,
    required IconData icon,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.alternate.withValues(alpha: 0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: theme.secondaryText),
          const SizedBox(height: 12),
          Text(
            message,
            style: poppinsRegular.copyWith(
              fontSize: 14,
              color: theme.secondaryText,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                actionLabel,
                style: poppinsMedium.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotal1099Income(TaxReturnCubit cubit) {
    final complete = cubit.state.currentReturn;
    if (complete == null) return 0;

    double total = 0;
    for (final f in complete.form1099Int) {
      total += f.box1InterestIncome;
    }
    for (final f in complete.form1099Div) {
      total += f.box1aOrdinaryDividends;
    }
    for (final f in complete.form1099Nec) {
      total += f.box1NonemployeeCompensation;
    }
    for (final f in complete.form1099R) {
      total += f.box2aTaxableAmount;
    }
    for (final f in complete.form1099G) {
      total += f.box1Unemployment;
    }
    for (final f in complete.formSsa1099) {
      total += f.box5NetBenefits;
    }
    return total;
  }

  void _navigateToAddW2(BuildContext context) {
    context.push('/w2-form');
  }

  void _showAdd1099Options(BuildContext context, AppTheme theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add 1099 Form',
              style: poppinsSemiBold.copyWith(
                fontSize: 20,
                color: theme.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select the type of 1099 you received',
              style: poppinsRegular.copyWith(
                fontSize: 14,
                color: theme.secondaryText,
              ),
            ),
            const SizedBox(height: 20),
            _build1099Option(
              context,
              theme,
              '1099-INT',
              'Interest Income',
              Icons.account_balance,
            ),
            _build1099Option(
              context,
              theme,
              '1099-DIV',
              'Dividend Income',
              Icons.trending_up,
            ),
            _build1099Option(
              context,
              theme,
              '1099-NEC',
              'Self-Employment Income',
              Icons.work_outline,
            ),
            _build1099Option(
              context,
              theme,
              '1099-R',
              'Retirement Distributions',
              Icons.elderly,
            ),
            _build1099Option(
              context,
              theme,
              '1099-G',
              'Government Payments',
              Icons.account_balance_wallet,
            ),
            _build1099Option(
              context,
              theme,
              'SSA-1099',
              'Social Security Benefits',
              Icons.security,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _build1099Option(
    BuildContext context,
    AppTheme theme,
    String type,
    String description,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () {
          if (Navigator.canPop(context)) Navigator.pop(context);
          context.push('/form-1099', extra: {'type': type});
        },
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: theme.primary),
        ),
        title: Text(
          type,
          style: poppinsMedium.copyWith(color: theme.primaryText),
        ),
        subtitle: Text(
          description,
          style: poppinsRegular.copyWith(
            fontSize: 12,
            color: theme.secondaryText,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: theme.secondaryText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: theme.primaryBackground,
      ),
    );
  }

  void _confirmDeleteW2(
    BuildContext context,
    TaxReturnCubit cubit,
    W2Form w2,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete W-2'),
        content: Text(
          'Are you sure you want to delete the W-2 from ${w2.employerName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (w2.id != null) {
                cubit.removeW2Form(w2.id!);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
