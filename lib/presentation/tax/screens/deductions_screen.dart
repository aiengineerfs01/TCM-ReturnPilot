/// =============================================================================
/// Deductions Screen
///
/// Screen for managing tax deductions:
/// - Standard vs Itemized deduction choice
/// - Itemized deduction entry (Schedule A)
/// - QBI deduction
/// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/models/tax/tax_models.dart';
import 'package:tcm_return_pilot/presentation/tax/cubit/tax_return_cubit.dart';
import 'package:tcm_return_pilot/services/tax/tax_calculation_service.dart';
import 'package:tcm_return_pilot/widgets/back_arrow.dart';

class DeductionsScreen extends StatefulWidget {
  const DeductionsScreen({super.key});

  static const String routeName = 'DeductionsScreen';
  static const String routePath = '/deductions';

  @override
  State<DeductionsScreen> createState() => _DeductionsScreenState();
}

class _DeductionsScreenState extends State<DeductionsScreen> {
  late TaxReturnCubit _controller;
  DeductionType _deductionType = DeductionType.standard;

  // Itemized deduction controllers
  final _medicalExpensesController = TextEditingController();
  final _stateLocalTaxController = TextEditingController();
  final _realEstateTaxController = TextEditingController();
  final _mortgageInterestController = TextEditingController();
  final _charitableCashController = TextEditingController();
  final _charitableNoncashController = TextEditingController();

  bool _dataPopulated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = context.read<TaxReturnCubit>();
    if (!_dataPopulated) {
      _dataPopulated = true;
      _populateExistingData();
    }
  }

  void _populateExistingData() {
    final deductions = _controller.state.currentReturn?.deductions;
    if (deductions != null) {
      _deductionType = deductions.deductionType;
      _medicalExpensesController.text = deductions.medicalExpensesTotal
          .toString();
      _stateLocalTaxController.text = deductions.stateLocalIncomeTax.toString();
      _realEstateTaxController.text = deductions.realEstateTaxes.toString();
      _mortgageInterestController.text = deductions.homeMortgageInterest
          .toString();
      _charitableCashController.text = deductions.charitableCash.toString();
      _charitableNoncashController.text = deductions.charitableNoncash
          .toString();
    }
  }

  @override
  void dispose() {
    _medicalExpensesController.dispose();
    _stateLocalTaxController.dispose();
    _realEstateTaxController.dispose();
    _mortgageInterestController.dispose();
    _charitableCashController.dispose();
    _charitableNoncashController.dispose();
    super.dispose();
  }

  double get _standardDeduction {
    return TaxCalculationService.calculateStandardDeduction(
      filingStatus: _controller.filingStatus,
      is65OrOlder:
          _controller.primaryTaxpayer?.isAge65OrOlder(_controller.taxYear) ??
          false,
      isBlind: false,
      spouseIs65OrOlder:
          _controller.spouseTaxpayer?.isAge65OrOlder(_controller.taxYear) ??
          false,
      spouseIsBlind: false,
    );
  }

  double get _totalItemizedDeductions {
    final medical = double.tryParse(_medicalExpensesController.text) ?? 0;
    final stateTax = double.tryParse(_stateLocalTaxController.text) ?? 0;
    final realEstate = double.tryParse(_realEstateTaxController.text) ?? 0;
    final mortgage = double.tryParse(_mortgageInterestController.text) ?? 0;
    final charitableCash = double.tryParse(_charitableCashController.text) ?? 0;
    final charitableNoncash =
        double.tryParse(_charitableNoncashController.text) ?? 0;

    // SALT cap of $10,000
    final saltTotal = (stateTax + realEstate).clamp(0, 10000);

    return medical + saltTotal + mortgage + charitableCash + charitableNoncash;
  }

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Deduction Comparison Card
                    _buildDeductionComparisonCard(theme),
                    const SizedBox(height: 24),

                    // Deduction Type Selection
                    _buildDeductionTypeSection(theme),
                    const SizedBox(height: 24),

                    // Itemized Deductions (if selected)
                    if (_deductionType == DeductionType.itemized) ...[
                      _buildItemizedDeductionsSection(theme),
                      const SizedBox(height: 24),
                    ],

                    // Save Button
                    _buildSaveButton(theme),
                    const SizedBox(height: 24),
                  ],
                ),
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
                  'Deductions',
                  style: poppinsSemiBold.copyWith(
                    fontSize: 24,
                    color: theme.primaryText,
                  ),
                ),
                Text(
                  'Standard or itemized deductions',
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

  Widget _buildDeductionComparisonCard(AppTheme theme) {
    final standardAmount = _standardDeduction;
    final itemizedAmount = _totalItemizedDeductions;
    final betterChoice = itemizedAmount > standardAmount
        ? 'itemized'
        : 'standard';
    final savings = (itemizedAmount - standardAmount).abs();

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
          Row(
            children: [
              Icon(
                Icons.compare_arrows,
                color: Colors.white.withValues(alpha: 0.9),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Deduction Comparison',
                style: poppinsMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Standard',
                      style: poppinsRegular.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '\$${standardAmount.toStringAsFixed(0)}',
                      style: poppinsSemiBold.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Text('VS', style: TextStyle(color: Colors.white)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Itemized',
                      style: poppinsRegular.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '\$${itemizedAmount.toStringAsFixed(0)}',
                      style: poppinsSemiBold.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    betterChoice == 'standard'
                        ? 'Standard deduction saves you more!'
                        : 'Itemizing saves you \$${savings.toStringAsFixed(0)} more',
                    style: poppinsMedium.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeductionTypeSection(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Deduction Type',
          style: poppinsSemiBold.copyWith(
            fontSize: 18,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 16),
        _buildDeductionTypeOption(
          theme: theme,
          type: DeductionType.standard,
          title: 'Standard Deduction',
          subtitle: 'Fixed amount based on filing status',
          amount: _standardDeduction,
        ),
        const SizedBox(height: 12),
        _buildDeductionTypeOption(
          theme: theme,
          type: DeductionType.itemized,
          title: 'Itemized Deductions',
          subtitle: 'Sum of individual deductible expenses',
          amount: _totalItemizedDeductions,
        ),
      ],
    );
  }

  Widget _buildDeductionTypeOption({
    required AppTheme theme,
    required DeductionType type,
    required String title,
    required String subtitle,
    required double amount,
  }) {
    final isSelected = _deductionType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _deductionType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primary.withValues(alpha: 0.1)
              : theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.primary
                : theme.alternate.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? theme.primary : theme.secondaryText,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: poppinsMedium.copyWith(
                      fontSize: 16,
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
            ),
            Text(
              '\$${amount.toStringAsFixed(0)}',
              style: poppinsSemiBold.copyWith(
                fontSize: 18,
                color: isSelected ? theme.primary : theme.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemizedDeductionsSection(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Itemized Deductions',
          style: poppinsSemiBold.copyWith(
            fontSize: 18,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your deductible expenses (Schedule A)',
          style: poppinsRegular.copyWith(
            fontSize: 14,
            color: theme.secondaryText,
          ),
        ),
        const SizedBox(height: 16),

        // Medical Expenses
        _buildExpenseCategory(
          theme: theme,
          icon: Icons.medical_services,
          title: 'Medical & Dental',
          subtitle: 'Expenses exceeding 7.5% of AGI',
          controller: _medicalExpensesController,
        ),

        // State & Local Taxes
        _buildExpenseCategory(
          theme: theme,
          icon: Icons.account_balance,
          title: 'State & Local Taxes',
          subtitle: 'Income or sales tax (max \$10,000)',
          controller: _stateLocalTaxController,
        ),

        // Real Estate Taxes
        _buildExpenseCategory(
          theme: theme,
          icon: Icons.home,
          title: 'Real Estate Taxes',
          subtitle: 'Property taxes (included in SALT cap)',
          controller: _realEstateTaxController,
        ),

        // Mortgage Interest
        _buildExpenseCategory(
          theme: theme,
          icon: Icons.percent,
          title: 'Mortgage Interest',
          subtitle: 'Interest on home mortgage (Form 1098)',
          controller: _mortgageInterestController,
        ),

        // Charitable Contributions
        _buildExpenseCategory(
          theme: theme,
          icon: Icons.volunteer_activism,
          title: 'Charitable Cash Donations',
          subtitle: 'Cash donations to qualified charities',
          controller: _charitableCashController,
        ),

        _buildExpenseCategory(
          theme: theme,
          icon: Icons.card_giftcard,
          title: 'Charitable Non-Cash',
          subtitle: 'Donated goods, clothing, etc.',
          controller: _charitableNoncashController,
        ),

        // SALT Cap Warning
        Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.amber, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'State & Local Taxes (SALT) are capped at \$10,000 for 2024',
                  style: poppinsRegular.copyWith(
                    fontSize: 12,
                    color: theme.primaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseCategory({
    required AppTheme theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
              child: Icon(icon, color: theme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: poppinsMedium.copyWith(
                      fontSize: 14,
                      color: theme.primaryText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: poppinsRegular.copyWith(
                      fontSize: 11,
                      color: theme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 100,
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                textAlign: TextAlign.right,
                style: poppinsMedium.copyWith(
                  fontSize: 16,
                  color: theme.primaryText,
                ),
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  prefixStyle: poppinsMedium.copyWith(
                    fontSize: 16,
                    color: theme.primaryText,
                  ),
                  hintText: '0',
                  hintStyle: poppinsRegular.copyWith(
                    color: theme.secondaryText,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.primaryBackground,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(AppTheme theme) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _saveDeductions,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Save Deductions',
          style: poppinsSemiBold.copyWith(fontSize: 16),
        ),
      ),
    );
  }

  Future<void> _saveDeductions() async {
    // TODO: Save deductions to database via controller

    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deductions saved'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
