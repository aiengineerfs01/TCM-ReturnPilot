/// =============================================================================
/// Form 1099 Screen
///
/// Generic screen for adding/editing various 1099 forms:
/// - 1099-INT (Interest Income)
/// - 1099-DIV (Dividend Income)
/// - 1099-NEC (Self-Employment Income)
/// - 1099-R (Retirement Distributions)
/// - 1099-G (Government Payments)
/// - SSA-1099 (Social Security Benefits)
/// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/presentation/tax/cubit/tax_return_cubit.dart';
import 'package:tcm_return_pilot/widgets/back_arrow.dart';

class Form1099Screen extends StatefulWidget {
  const Form1099Screen({super.key});

  static const String routeName = 'Form1099Screen';
  static const String routePath = '/form-1099';

  @override
  State<Form1099Screen> createState() => _Form1099ScreenState();
}

class _Form1099ScreenState extends State<Form1099Screen> {
  final _formKey = GlobalKey<FormState>();

  String _formType = '1099-INT';
  dynamic _existingForm;
  bool _isEditing = false;

  // Common controllers
  final _payerNameController = TextEditingController();
  final _payerTinController = TextEditingController();

  // 1099-INT fields
  final _interestIncomeController = TextEditingController();
  final _earlyWithdrawalPenaltyController = TextEditingController();
  final _federalWithheldController = TextEditingController();

  // 1099-DIV fields
  final _ordinaryDividendsController = TextEditingController();
  final _qualifiedDividendsController = TextEditingController();
  final _capitalGainController = TextEditingController();

  // 1099-NEC fields
  final _necCompensationController = TextEditingController();
  final _necFederalWithheldController = TextEditingController();

  // 1099-R fields
  final _grossDistributionController = TextEditingController();
  final _taxableAmountController = TextEditingController();
  final _rFederalWithheldController = TextEditingController();

  // 1099-G fields
  final _unemploymentController = TextEditingController();
  final _stateTaxRefundController = TextEditingController();

  // SSA-1099 fields
  final _netBenefitsController = TextEditingController();
  final _benefitsRepaidController = TextEditingController();
  final _ssaFederalWithheldController = TextEditingController();

  TaxReturnCubit get _cubit => context.read<TaxReturnCubit>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _formType = args['type'] ?? '1099-INT';
      if (args['form'] != null) {
        _existingForm = args['form'];
        _isEditing = true;
        _populateForm();
      }
    }
  }

  void _populateForm() {
    // Populate based on form type
    switch (_formType) {
      case '1099-INT':
        final form = _existingForm;
        _payerNameController.text = form.payerName;
        _payerTinController.text = form.payerTin;
        _interestIncomeController.text = form.box1InterestIncome.toString();
        _earlyWithdrawalPenaltyController.text = form.box2EarlyWithdrawalPenalty
            .toString();
        _federalWithheldController.text = form.box4FederalWithheld.toString();
        break;
      case '1099-DIV':
        final form = _existingForm;
        _payerNameController.text = form.payerName;
        _payerTinController.text = form.payerTin;
        _ordinaryDividendsController.text = form.box1aOrdinaryDividends
            .toString();
        _qualifiedDividendsController.text = form.box1bQualifiedDividends
            .toString();
        _capitalGainController.text = form.box2aCapitalGain.toString();
        break;
      case '1099-NEC':
        final form = _existingForm;
        _payerNameController.text = form.payerName;
        _payerTinController.text = form.payerTin;
        _necCompensationController.text = form.box1NonemployeeCompensation
            .toString();
        _necFederalWithheldController.text = form.box4FederalWithheld
            .toString();
        break;
      case '1099-R':
        final form = _existingForm;
        _payerNameController.text = form.payerName;
        _payerTinController.text = form.payerTin;
        _grossDistributionController.text = form.box1GrossDistribution
            .toString();
        _taxableAmountController.text = form.box2aTaxableAmount.toString();
        _rFederalWithheldController.text = form.box4FederalWithheld.toString();
        break;
      case '1099-G':
        final form = _existingForm;
        _payerNameController.text = form.payerName;
        _payerTinController.text = form.payerTin;
        _unemploymentController.text = form.box1Unemployment.toString();
        _stateTaxRefundController.text = form.box2StateTaxRefund.toString();
        break;
      case 'SSA-1099':
        final form = _existingForm;
        _netBenefitsController.text = form.box5NetBenefits.toString();
        _benefitsRepaidController.text = form.box4BenefitsRepaid.toString();
        _ssaFederalWithheldController.text = form.box6FederalWithheld
            .toString();
        break;
    }
  }

  @override
  void dispose() {
    _payerNameController.dispose();
    _payerTinController.dispose();
    _interestIncomeController.dispose();
    _earlyWithdrawalPenaltyController.dispose();
    _federalWithheldController.dispose();
    _ordinaryDividendsController.dispose();
    _qualifiedDividendsController.dispose();
    _capitalGainController.dispose();
    _necCompensationController.dispose();
    _necFederalWithheldController.dispose();
    _grossDistributionController.dispose();
    _taxableAmountController.dispose();
    _rFederalWithheldController.dispose();
    _unemploymentController.dispose();
    _stateTaxRefundController.dispose();
    _netBenefitsController.dispose();
    _benefitsRepaidController.dispose();
    _ssaFederalWithheldController.dispose();
    super.dispose();
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
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form type indicator
                      _buildFormTypeIndicator(theme),
                      const SizedBox(height: 24),

                      // Form-specific fields
                      ..._buildFormFields(theme),

                      const SizedBox(height: 32),

                      // Save Button
                      _buildSaveButton(theme),

                      const SizedBox(height: 24),
                    ],
                  ),
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
                  _isEditing ? 'Edit $_formType' : 'Add $_formType',
                  style: poppinsSemiBold.copyWith(
                    fontSize: 24,
                    color: theme.primaryText,
                  ),
                ),
                Text(
                  _getFormDescription(),
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

  String _getFormDescription() {
    switch (_formType) {
      case '1099-INT':
        return 'Interest Income';
      case '1099-DIV':
        return 'Dividends and Distributions';
      case '1099-NEC':
        return 'Nonemployee Compensation';
      case '1099-R':
        return 'Retirement Distributions';
      case '1099-G':
        return 'Government Payments';
      case 'SSA-1099':
        return 'Social Security Benefit Statement';
      default:
        return '';
    }
  }

  Widget _buildFormTypeIndicator(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long, color: Colors.orange, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Form $_formType',
                  style: poppinsSemiBold.copyWith(
                    fontSize: 18,
                    color: theme.primaryText,
                  ),
                ),
                Text(
                  _getFormDescription(),
                  style: poppinsRegular.copyWith(
                    fontSize: 12,
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

  List<Widget> _buildFormFields(AppTheme theme) {
    switch (_formType) {
      case '1099-INT':
        return _build1099IntFields(theme);
      case '1099-DIV':
        return _build1099DivFields(theme);
      case '1099-NEC':
        return _build1099NecFields(theme);
      case '1099-R':
        return _build1099RFields(theme);
      case '1099-G':
        return _build1099GFields(theme);
      case 'SSA-1099':
        return _buildSsa1099Fields(theme);
      default:
        return [];
    }
  }

  List<Widget> _build1099IntFields(AppTheme theme) {
    return [
      _buildSectionTitle(theme, 'Payer Information'),
      const SizedBox(height: 12),
      _buildTextField(
        theme: theme,
        controller: _payerNameController,
        label: 'Payer Name (Bank/Institution)',
        hint: 'Enter payer name',
        required: true,
      ),
      _buildTextField(
        theme: theme,
        controller: _payerTinController,
        label: 'Payer TIN',
        hint: 'XX-XXXXXXX',
      ),
      const SizedBox(height: 24),
      _buildSectionTitle(theme, 'Interest Income'),
      const SizedBox(height: 12),
      _buildCurrencyField(
        theme: theme,
        controller: _interestIncomeController,
        label: 'Box 1 - Interest Income',
        required: true,
      ),
      _buildCurrencyField(
        theme: theme,
        controller: _earlyWithdrawalPenaltyController,
        label: 'Box 2 - Early Withdrawal Penalty',
      ),
      _buildCurrencyField(
        theme: theme,
        controller: _federalWithheldController,
        label: 'Box 4 - Federal Tax Withheld',
      ),
    ];
  }

  List<Widget> _build1099DivFields(AppTheme theme) {
    return [
      _buildSectionTitle(theme, 'Payer Information'),
      const SizedBox(height: 12),
      _buildTextField(
        theme: theme,
        controller: _payerNameController,
        label: 'Payer Name',
        hint: 'Enter payer name',
        required: true,
      ),
      _buildTextField(
        theme: theme,
        controller: _payerTinController,
        label: 'Payer TIN',
        hint: 'XX-XXXXXXX',
      ),
      const SizedBox(height: 24),
      _buildSectionTitle(theme, 'Dividend Income'),
      const SizedBox(height: 12),
      _buildCurrencyField(
        theme: theme,
        controller: _ordinaryDividendsController,
        label: 'Box 1a - Ordinary Dividends',
        required: true,
      ),
      _buildCurrencyField(
        theme: theme,
        controller: _qualifiedDividendsController,
        label: 'Box 1b - Qualified Dividends',
      ),
      _buildCurrencyField(
        theme: theme,
        controller: _capitalGainController,
        label: 'Box 2a - Capital Gain Distributions',
      ),
    ];
  }

  List<Widget> _build1099NecFields(AppTheme theme) {
    return [
      _buildSectionTitle(theme, 'Payer Information'),
      const SizedBox(height: 12),
      _buildTextField(
        theme: theme,
        controller: _payerNameController,
        label: 'Payer Name (Client/Company)',
        hint: 'Enter payer name',
        required: true,
      ),
      _buildTextField(
        theme: theme,
        controller: _payerTinController,
        label: 'Payer TIN',
        hint: 'XX-XXXXXXX',
      ),
      const SizedBox(height: 24),
      _buildSectionTitle(theme, 'Self-Employment Income'),
      const SizedBox(height: 12),
      _buildCurrencyField(
        theme: theme,
        controller: _necCompensationController,
        label: 'Box 1 - Nonemployee Compensation',
        required: true,
      ),
      _buildCurrencyField(
        theme: theme,
        controller: _necFederalWithheldController,
        label: 'Box 4 - Federal Tax Withheld',
      ),
      const SizedBox(height: 16),
      Container(
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
                'Self-employment income is subject to self-employment tax (15.3%)',
                style: poppinsRegular.copyWith(
                  fontSize: 12,
                  color: theme.primaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _build1099RFields(AppTheme theme) {
    return [
      _buildSectionTitle(theme, 'Payer Information'),
      const SizedBox(height: 12),
      _buildTextField(
        theme: theme,
        controller: _payerNameController,
        label: 'Payer Name (Plan Administrator)',
        hint: 'Enter payer name',
        required: true,
      ),
      _buildTextField(
        theme: theme,
        controller: _payerTinController,
        label: 'Payer TIN',
        hint: 'XX-XXXXXXX',
      ),
      const SizedBox(height: 24),
      _buildSectionTitle(theme, 'Distribution Information'),
      const SizedBox(height: 12),
      _buildCurrencyField(
        theme: theme,
        controller: _grossDistributionController,
        label: 'Box 1 - Gross Distribution',
        required: true,
      ),
      _buildCurrencyField(
        theme: theme,
        controller: _taxableAmountController,
        label: 'Box 2a - Taxable Amount',
        required: true,
      ),
      _buildCurrencyField(
        theme: theme,
        controller: _rFederalWithheldController,
        label: 'Box 4 - Federal Tax Withheld',
      ),
    ];
  }

  List<Widget> _build1099GFields(AppTheme theme) {
    return [
      _buildSectionTitle(theme, 'Payer Information'),
      const SizedBox(height: 12),
      _buildTextField(
        theme: theme,
        controller: _payerNameController,
        label: 'Payer Name (Government Agency)',
        hint: 'Enter payer name',
        required: true,
      ),
      _buildTextField(
        theme: theme,
        controller: _payerTinController,
        label: 'Payer TIN',
        hint: 'XX-XXXXXXX',
      ),
      const SizedBox(height: 24),
      _buildSectionTitle(theme, 'Government Payments'),
      const SizedBox(height: 12),
      _buildCurrencyField(
        theme: theme,
        controller: _unemploymentController,
        label: 'Box 1 - Unemployment Compensation',
      ),
      _buildCurrencyField(
        theme: theme,
        controller: _stateTaxRefundController,
        label: 'Box 2 - State/Local Tax Refund',
      ),
    ];
  }

  List<Widget> _buildSsa1099Fields(AppTheme theme) {
    return [
      _buildSectionTitle(theme, 'Social Security Benefits'),
      const SizedBox(height: 12),
      _buildCurrencyField(
        theme: theme,
        controller: _netBenefitsController,
        label: 'Box 5 - Net Benefits',
        required: true,
      ),
      _buildCurrencyField(
        theme: theme,
        controller: _benefitsRepaidController,
        label: 'Box 4 - Benefits Repaid',
      ),
      _buildCurrencyField(
        theme: theme,
        controller: _ssaFederalWithheldController,
        label: 'Box 6 - Federal Tax Withheld',
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Up to 85% of Social Security benefits may be taxable depending on your total income',
                style: poppinsRegular.copyWith(
                  fontSize: 12,
                  color: theme.primaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildSectionTitle(AppTheme theme, String title) {
    return Text(
      title,
      style: poppinsSemiBold.copyWith(fontSize: 16, color: theme.primaryText),
    );
  }

  Widget _buildTextField({
    required AppTheme theme,
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: poppinsMedium.copyWith(
                  fontSize: 14,
                  color: theme.primaryText,
                ),
              ),
              if (required)
                Text(
                  ' *',
                  style: poppinsMedium.copyWith(
                    fontSize: 14,
                    color: theme.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            style: poppinsRegular.copyWith(color: theme.primaryText),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: poppinsRegular.copyWith(color: theme.secondaryText),
              filled: true,
              fillColor: theme.secondaryBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.alternate.withValues(alpha: 0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.alternate.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: required
                ? (value) =>
                      value?.isEmpty == true ? 'This field is required' : null
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyField({
    required AppTheme theme,
    required TextEditingController controller,
    required String label,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: poppinsMedium.copyWith(
                  fontSize: 14,
                  color: theme.primaryText,
                ),
              ),
              if (required)
                Text(
                  ' *',
                  style: poppinsMedium.copyWith(
                    fontSize: 14,
                    color: theme.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: poppinsRegular.copyWith(color: theme.primaryText),
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: poppinsRegular.copyWith(color: theme.primaryText),
              hintText: '0.00',
              hintStyle: poppinsRegular.copyWith(color: theme.secondaryText),
              filled: true,
              fillColor: theme.secondaryBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.alternate.withValues(alpha: 0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.alternate.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: required
                ? (value) => value?.isEmpty == true ? 'Required' : null
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(AppTheme theme) {
    return BlocBuilder<TaxReturnCubit, TaxReturnState>(
      builder: (context, state) => SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: state.isLoading ? null : _saveForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: state.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  _isEditing ? 'Update $_formType' : 'Add $_formType',
                  style: poppinsSemiBold.copyWith(fontSize: 16),
                ),
        ),
      ),
    );
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    // For now, show a success message
    // TODO: Implement proper save methods in controller for each 1099 type

    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? '$_formType updated successfully'
                : '$_formType added successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
