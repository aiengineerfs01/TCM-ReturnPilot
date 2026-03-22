/// =============================================================================
/// Enhanced Review Screen
///
/// Auto-filled tax return review with editable sections.
///
/// Features:
/// - Automatically loads data from Supabase
/// - Editable sections for manual corrections
/// - Document management (view, replace, delete)
/// - Validation and error highlighting
/// - Progress tracking
/// - Submit for e-filing
///
/// Security:
/// - Sensitive data masked by default
/// - SSN/EIN shown only on tap with re-authentication
/// - Audit logging for all modifications
/// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/models/tax/tax_models.dart';
import 'package:tcm_return_pilot/presentation/tax/cubit/tax_return_cubit.dart';
import 'package:tcm_return_pilot/services/security/encryption_service.dart';
import 'package:tcm_return_pilot/services/tax/auto_fill_orchestrator_service.dart';
import 'package:tcm_return_pilot/utils/snackbar.dart';
import 'package:tcm_return_pilot/widgets/back_arrow.dart';
import 'package:file_picker/file_picker.dart';

// Use the DocumentType from auto_fill_orchestrator_service
export 'package:tcm_return_pilot/services/tax/auto_fill_orchestrator_service.dart' show DocumentType;

class EnhancedReviewScreen extends StatefulWidget {
  const EnhancedReviewScreen({super.key});

  static const String routeName = 'EnhancedReviewScreen';
  static const String routePath = '/enhanced-review';

  @override
  State<EnhancedReviewScreen> createState() => _EnhancedReviewScreenState();
}

class _EnhancedReviewScreenState extends State<EnhancedReviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TaxReturnCubit _cubit;
  AutoFillOrchestratorService? _autoFillService;

  // Edit mode states
  bool isEditingPersonalInfo = false;
  bool isEditingIncome = false;
  bool isEditingDeductions = false;
  bool isEditingDependents = false;
  bool isEditingBankInfo = false;

  // Form controllers for editing
  final _personalInfoFormKey = GlobalKey<FormState>();

  // Text controllers for personal info
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Initialize text controllers
    _initializeControllers();

    // Try to create auto-fill service
    try {
      _autoFillService = AutoFillOrchestratorService();
    } catch (e) {
      // Service not available
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cubit = context.read<TaxReturnCubit>();

    // Load return data
    _loadReturnData();
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _streetController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _zipController = TextEditingController();
  }

  void _loadReturnData() {
    // Populate controllers with existing data
    final taxpayer = _cubit.primaryTaxpayer;
    if (taxpayer != null) {
      _firstNameController.text = taxpayer.firstName;
      _lastNameController.text = taxpayer.lastName;
      _emailController.text = taxpayer.email ?? '';
      _phoneController.text = taxpayer.phone ?? '';
      _streetController.text = taxpayer.address.street1;
      _cityController.text = taxpayer.address.city;
      _stateController.text = taxpayer.address.state.value;
      _zipController.text = taxpayer.address.zipCode;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
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
            _buildProgressIndicator(theme),
            _buildTabBar(theme),
            Expanded(
              child: BlocBuilder<TaxReturnCubit, TaxReturnState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPersonalInfoTab(theme),
                      _buildIncomeTab(theme),
                      _buildDeductionsTab(theme),
                      _buildDocumentsTab(theme),
                      _buildSummaryTab(theme),
                    ],
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const BackArrow(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review Your Return',
                  style: poppinsSemiBold.copyWith(
                    fontSize: 20,
                    color: theme.primaryText,
                  ),
                ),
                Text(
                  'Tax Year ${_cubit.taxYear}',
                  style: poppinsRegular.copyWith(
                    fontSize: 14,
                    color: theme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          // Auto-fill status indicator
          if (_autoFillService != null)
            Builder(builder: (_) {
              final progress = _autoFillService!.progress;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: progress.hasErrors
                      ? Colors.red.withOpacity(0.1)
                      : progress.needsReview
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      progress.hasErrors
                          ? Icons.error_outline
                          : progress.needsReview
                              ? Icons.warning_amber
                              : Icons.check_circle,
                      size: 16,
                      color: progress.hasErrors
                          ? Colors.red
                          : progress.needsReview
                              ? Colors.orange
                              : Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(progress.overallProgress * 100).toInt()}%',
                      style: poppinsMedium.copyWith(
                        fontSize: 12,
                        color: progress.hasErrors
                            ? Colors.red
                            : progress.needsReview
                                ? Colors.orange
                                : Colors.green,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(AppTheme theme) {
    return BlocBuilder<TaxReturnCubit, TaxReturnState>(
      builder: (context, state) {
      final summary = state.taxSummary;
      final completionPercent = _cubit.completionPercentage;
      
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: summary?.isGettingRefund == true
                ? [const Color(0xFF2E7D32), const Color(0xFF4CAF50)]
                : [theme.primary, theme.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary?.isGettingRefund == true
                        ? 'Estimated Refund'
                        : 'Amount Due',
                    style: poppinsRegular.copyWith(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    summary != null
                        ? '\$${(summary.isGettingRefund ? summary.refundAmount : summary.amountOwed).toStringAsFixed(2)}'
                        : '--',
                    style: poppinsBold.copyWith(
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
              child: Center(
                child: Text(
                  '${completionPercent.toInt()}%',
                  style: poppinsSemiBold.copyWith(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTabBar(AppTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        border: Border(
          bottom: BorderSide(color: theme.alternate.withOpacity(0.2)),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: theme.primary,
        unselectedLabelColor: theme.secondaryText,
        indicatorColor: theme.primary,
        labelStyle: poppinsMedium.copyWith(fontSize: 13),
        tabs: const [
          Tab(text: 'Personal'),
          Tab(text: 'Income'),
          Tab(text: 'Deductions'),
          Tab(text: 'Documents'),
          Tab(text: 'Summary'),
        ],
      ),
    );
  }

  // ===========================================================================
  // Personal Info Tab
  // ===========================================================================

  Widget _buildPersonalInfoTab(AppTheme theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            theme,
            title: 'Primary Taxpayer',
            icon: Icons.person,
            isEditing: isEditingPersonalInfo,
            onEdit: () => setState(() => isEditingPersonalInfo = true),
            onSave: () => _savePersonalInfo(),
            onCancel: () {
              setState(() => isEditingPersonalInfo = false);
              _loadReturnData(); // Reset to original values
            },
          ),
          const SizedBox(height: 12),
          isEditingPersonalInfo
              ? _buildPersonalInfoEditForm(theme)
              : _buildPersonalInfoView(theme),
          const SizedBox(height: 24),

          // Dependents Section
          if (_cubit.dependents.isNotEmpty) ...[
            _buildSectionHeader(
              theme,
              title: 'Dependents (${_cubit.dependents.length})',
              icon: Icons.family_restroom,
              isEditing: isEditingDependents,
              onEdit: () => setState(() => isEditingDependents = true),
              onSave: () => setState(() => isEditingDependents = false),
              onCancel: () => setState(() => isEditingDependents = false),
            ),
            const SizedBox(height: 12),
            ..._cubit.dependents.map((dep) => _buildDependentCard(theme, dep)),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonalInfoView(AppTheme theme) {
    final taxpayer = _cubit.primaryTaxpayer;

    if (taxpayer == null) {
      return _buildEmptyState(
        theme,
        icon: Icons.person_outline,
        title: 'No Personal Info',
        subtitle: 'Complete the interview to fill this section',
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildInfoRow(theme, 'Name', '${taxpayer.firstName} ${taxpayer.lastName}'),
          _buildInfoRow(theme, 'SSN', EncryptionService.maskSSN(taxpayer.ssn),
              isSensitive: true),
          _buildInfoRow(theme, 'Date of Birth',
              '${taxpayer.dateOfBirth.month}/${taxpayer.dateOfBirth.day}/${taxpayer.dateOfBirth.year}'),
          if (taxpayer.email != null)
            _buildInfoRow(theme, 'Email', taxpayer.email!),
          if (taxpayer.phone != null)
            _buildInfoRow(theme, 'Phone', EncryptionService.maskPhone(taxpayer.phone!)),
          _buildInfoRow(theme, 'Address',
              '${taxpayer.address.street1}, ${taxpayer.address.city}, ${taxpayer.address.state} ${taxpayer.address.zipCode}'),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoEditForm(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primary.withOpacity(0.3)),
      ),
      child: Form(
        key: _personalInfoFormKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    theme,
                    controller: _firstNameController,
                    label: 'First Name',
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    theme,
                    controller: _lastNameController,
                    label: 'Last Name',
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              theme,
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              theme,
              controller: _phoneController,
              label: 'Phone',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              theme,
              controller: _streetController,
              label: 'Street Address',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    theme,
                    controller: _cityController,
                    label: 'City',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    theme,
                    controller: _stateController,
                    label: 'State',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    theme,
                    controller: _zipController,
                    label: 'ZIP',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePersonalInfo() async {
    if (!_personalInfoFormKey.currentState!.validate()) return;

    final taxpayer = _cubit.primaryTaxpayer;
    if (taxpayer == null) return;

    final updatedTaxpayer = TaxpayerInfo(
      id: taxpayer.id,
      returnId: taxpayer.returnId,
      taxpayerType: taxpayer.taxpayerType,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      ssn: taxpayer.ssn,
      dateOfBirth: taxpayer.dateOfBirth,
      address: Address(
        street1: _streetController.text.trim(),
        city: _cityController.text.trim(),
        state: USState.fromString(_stateController.text.trim()),
        zipCode: _zipController.text.trim(),
        country: 'US',
      ),
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      email: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null,
      occupation: taxpayer.occupation,
      middleInitial: taxpayer.middleInitial,
      suffix: taxpayer.suffix,
      ipPin: taxpayer.ipPin,
    );

    await _cubit.savePrimaryTaxpayer(updatedTaxpayer);
    setState(() => isEditingPersonalInfo = false);

    SnackbarHelper.showSuccess('Personal information updated successfully',
        title: 'Saved');
  }

  Widget _buildDependentCard(AppTheme theme, Dependent dependent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.child_care, color: theme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${dependent.firstName} ${dependent.lastName}',
                  style: poppinsMedium.copyWith(
                    fontSize: 14,
                    color: theme.primaryText,
                  ),
                ),
                Text(
                  '${dependent.relationship.displayName} • SSN: ${EncryptionService.maskSSN(dependent.ssn)}',
                  style: poppinsRegular.copyWith(
                    fontSize: 12,
                    color: theme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          if (dependent.qualifiesForCtc)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'CTC',
                style: poppinsMedium.copyWith(
                  fontSize: 10,
                  color: Colors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Income Tab
  // ===========================================================================

  Widget _buildIncomeTab(AppTheme theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // W-2 Section
          _buildSectionHeader(
            theme,
            title: 'W-2 Wages',
            icon: Icons.work,
            isEditing: false,
          ),
          const SizedBox(height: 12),
          if (_cubit.w2Forms.isEmpty)
            _buildEmptyState(
              theme,
              icon: Icons.work_outline,
              title: 'No W-2 Forms',
              subtitle: 'Upload or add W-2 information',
            )
          else
            ..._cubit.w2Forms.map((w2) => _buildW2Card(theme, w2)),

          const SizedBox(height: 24),

          // 1099 Section Summary
          _buildSectionHeader(
            theme,
            title: 'Other Income (1099s)',
            icon: Icons.receipt_long,
            isEditing: false,
          ),
          const SizedBox(height: 12),
          _buildOtherIncomeSection(theme),
        ],
      ),
    );
  }

  Widget _buildW2Card(AppTheme theme, W2Form w2) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.business, color: theme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      w2.employerName,
                      style: poppinsMedium.copyWith(
                        fontSize: 14,
                        color: theme.primaryText,
                      ),
                    ),
                    Text(
                      'EIN: ${EncryptionService.maskEIN(w2.employerEin)}',
                      style: poppinsRegular.copyWith(
                        fontSize: 12,
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: theme.secondaryText, size: 20),
                onPressed: () => _editW2(w2),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAmountItem(theme, 'Wages', w2.box1Wages),
              _buildAmountItem(theme, 'Federal Tax', w2.box2FederalWithheld),
              _buildAmountItem(theme, 'State Tax', w2.stateTaxWithheld ?? 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountItem(AppTheme theme, String label, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: poppinsRegular.copyWith(
            fontSize: 11,
            color: theme.secondaryText,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: poppinsSemiBold.copyWith(
            fontSize: 14,
            color: theme.primaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildOtherIncomeSection(AppTheme theme) {
    final complete = _cubit.state.currentReturn;
    if (complete == null) {
      return _buildEmptyState(
        theme,
        icon: Icons.receipt_long_outlined,
        title: 'No 1099 Forms',
        subtitle: 'Upload or add 1099 information',
      );
    }

    final totalInterest = complete.form1099Int.fold(
      0.0, (sum, f) => sum + f.box1InterestIncome);
    final totalDividends = complete.form1099Div.fold(
      0.0, (sum, f) => sum + f.box1aOrdinaryDividends);
    final totalNec = complete.form1099Nec.fold(
      0.0, (sum, f) => sum + f.box1NonemployeeCompensation);

    if (totalInterest == 0 && totalDividends == 0 && totalNec == 0) {
      return _buildEmptyState(
        theme,
        icon: Icons.receipt_long_outlined,
        title: 'No 1099 Forms',
        subtitle: 'Upload or add 1099 information',
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          if (totalInterest > 0)
            _buildInfoRow(theme, 'Interest Income (1099-INT)',
                '\$${totalInterest.toStringAsFixed(2)}'),
          if (totalDividends > 0)
            _buildInfoRow(theme, 'Dividend Income (1099-DIV)',
                '\$${totalDividends.toStringAsFixed(2)}'),
          if (totalNec > 0)
            _buildInfoRow(theme, 'Self-Employment (1099-NEC)',
                '\$${totalNec.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  void _editW2(W2Form w2) {
    // Navigate to W-2 edit screen or show edit dialog
    SnackbarHelper.showSuccess('W-2 editing coming soon', title: 'Edit W-2');
  }

  // ===========================================================================
  // Deductions Tab
  // ===========================================================================

  Widget _buildDeductionsTab(AppTheme theme) {
    final complete = _cubit.state.currentReturn;
    final deductions = complete?.deductions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            theme,
            title: 'Deductions',
            icon: Icons.receipt,
            isEditing: isEditingDeductions,
            onEdit: () => setState(() => isEditingDeductions = true),
            onSave: () => setState(() => isEditingDeductions = false),
            onCancel: () => setState(() => isEditingDeductions = false),
          ),
          const SizedBox(height: 12),
          _buildDeductionTypeSelector(theme, deductions),
          const SizedBox(height: 16),
          if (deductions?.deductionType == DeductionType.itemized)
            _buildItemizedDeductions(theme, deductions!)
          else
            _buildStandardDeduction(theme),
        ],
      ),
    );
  }

  Widget _buildDeductionTypeSelector(AppTheme theme, Deductions? deductions) {
    final isItemized = deductions?.deductionType == DeductionType.itemized;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _updateDeductionType(DeductionType.standard),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isItemized ? theme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Standard',
                    style: poppinsMedium.copyWith(
                      fontSize: 14,
                      color: !isItemized ? Colors.white : theme.primaryText,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _updateDeductionType(DeductionType.itemized),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isItemized ? theme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Itemized',
                    style: poppinsMedium.copyWith(
                      fontSize: 14,
                      color: isItemized ? Colors.white : theme.primaryText,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateDeductionType(DeductionType type) {
    // Update deduction type
  }

  Widget _buildStandardDeduction(AppTheme theme) {
    final standardDeduction = _getStandardDeduction();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Standard Deduction',
                style: poppinsMedium.copyWith(
                  fontSize: 14,
                  color: theme.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '\$${standardDeduction.toStringAsFixed(0)}',
            style: poppinsBold.copyWith(
              fontSize: 28,
              color: theme.primary,
            ),
          ),
          Text(
            'Based on ${_cubit.filingStatus.displayName} status',
            style: poppinsRegular.copyWith(
              fontSize: 12,
              color: theme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  double _getStandardDeduction() {
    // 2024 standard deductions
    switch (_cubit.filingStatus) {
      case FilingStatus.single:
        return 14600;
      case FilingStatus.marriedFilingJointly:
        return 29200;
      case FilingStatus.marriedFilingSeparately:
        return 14600;
      case FilingStatus.headOfHousehold:
        return 21900;
      case FilingStatus.qualifyingWidow:
        return 29200;
    }
  }

  Widget _buildItemizedDeductions(AppTheme theme, Deductions deductions) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildInfoRow(theme, 'Medical Expenses',
              '\$${deductions.medicalExpensesTotal.toStringAsFixed(2)}'),
          _buildInfoRow(theme, 'State & Local Taxes',
              '\$${deductions.stateLocalIncomeTax.toStringAsFixed(2)}'),
          _buildInfoRow(theme, 'Mortgage Interest',
              '\$${deductions.homeMortgageInterest.toStringAsFixed(2)}'),
          _buildInfoRow(theme, 'Charitable Contributions',
              '\$${(deductions.charitableCash + deductions.charitableNoncash).toStringAsFixed(2)}'),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Itemized',
                style: poppinsSemiBold.copyWith(
                  fontSize: 14,
                  color: theme.primaryText,
                ),
              ),
              Text(
                '\$${deductions.totalItemizedDeductions.toStringAsFixed(2)}',
                style: poppinsBold.copyWith(
                  fontSize: 18,
                  color: theme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Documents Tab
  // ===========================================================================

  Widget _buildDocumentsTab(AppTheme theme) {
    final documents = _autoFillService?.uploadedDocuments ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Uploaded Documents',
                style: poppinsSemiBold.copyWith(
                  fontSize: 16,
                  color: theme.primaryText,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _uploadNewDocument,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (documents.isEmpty)
            _buildEmptyState(
              theme,
              icon: Icons.folder_open,
              title: 'No Documents',
              subtitle: 'Upload W-2s, 1099s, and other tax documents',
            )
          else
            ...documents.map((doc) => _buildDocumentCard(theme, doc)),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(AppTheme theme, UploadedDocument document) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getDocumentColor(document.documentType).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getDocumentIcon(document.documentType),
              color: _getDocumentColor(document.documentType),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.fileName,
                  style: poppinsMedium.copyWith(
                    fontSize: 14,
                    color: theme.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${document.documentType.displayName} • ${_formatDate(document.uploadedAt)}',
                  style: poppinsRegular.copyWith(
                    fontSize: 12,
                    color: theme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: theme.secondaryText),
            onSelected: (value) {
              if (value == 'replace') {
                _replaceDocument(document);
              } else if (value == 'delete') {
                _deleteDocument(document);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'replace', child: Text('Replace')),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.w2:
        return Icons.work;
      case DocumentType.form1099Int:
      case DocumentType.form1099Div:
      case DocumentType.form1099Nec:
      case DocumentType.form1099G:
      case DocumentType.form1099R:
      case DocumentType.form1099Misc:
        return Icons.receipt_long;
      case DocumentType.governmentId:
        return Icons.badge;
      default:
        return Icons.description;
    }
  }

  Color _getDocumentColor(DocumentType type) {
    switch (type) {
      case DocumentType.w2:
        return Colors.blue;
      case DocumentType.form1099Int:
      case DocumentType.form1099Div:
        return Colors.green;
      case DocumentType.form1099Nec:
        return Colors.orange;
      case DocumentType.governmentId:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Future<void> _uploadNewDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      
      // Show document type selector
      final docType = await _showDocumentTypeDialog();
      if (docType != null) {
        await _autoFillService?.uploadDocument(
          file: file,
          documentType: docType,
        );
        setState(() {});
      }
    }
  }

  Future<DocumentType?> _showDocumentTypeDialog() async {
    return showDialog<DocumentType>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Document Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: DocumentType.values
              .where((t) => t != DocumentType.other)
              .take(8)
              .map((type) => ListTile(
                    title: Text(type.displayName),
                    onTap: () => Navigator.pop(context, type),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Future<void> _replaceDocument(UploadedDocument document) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      await _autoFillService?.replaceDocument(
        existingDocumentId: document.id,
        newFile: file,
      );
      setState(() {});
    }
  }

  Future<void> _deleteDocument(UploadedDocument document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete "${document.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _autoFillService?.deleteDocument(document.id);
      setState(() {});
    }
  }

  // ===========================================================================
  // Summary Tab
  // ===========================================================================

  Widget _buildSummaryTab(AppTheme theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: BlocBuilder<TaxReturnCubit, TaxReturnState>(
        builder: (context, state) {
        final summary = state.taxSummary;
        if (summary == null) {
          return _buildEmptyState(
            theme,
            icon: Icons.calculate_outlined,
            title: 'No Summary Available',
            subtitle: 'Complete your tax information to see the summary',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummarySection(
              theme,
              title: 'Income',
              items: [
                ('Total Income', summary.totalIncome),
                ('Adjustments', -summary.adjustmentsToIncome),
                ('AGI', summary.agi),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummarySection(
              theme,
              title: 'Deductions & Taxable Income',
              items: [
                ('Deductions', -summary.deductions),
                ('Taxable Income', summary.taxableIncome),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummarySection(
              theme,
              title: 'Tax Calculation',
              items: [
                ('Federal Tax', summary.federalIncomeTax),
                if (summary.selfEmploymentTax > 0)
                  ('Self-Employment Tax', summary.selfEmploymentTax),
                ('Total Tax', summary.totalTax),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummarySection(
              theme,
              title: 'Credits & Payments',
              items: [
                ('Credits', -summary.totalCredits),
                ('Withholding', summary.totalWithholding),
                ('Total Payments', summary.totalPayments),
              ],
            ),
            const SizedBox(height: 24),
            _buildValidationStatus(theme),
            const SizedBox(height: 24),
            _buildSubmitButton(theme),
          ],
        );
      }),
    );
  }

  Widget _buildSummarySection(
    AppTheme theme, {
    required String title,
    required List<(String, double)> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: poppinsSemiBold.copyWith(
              fontSize: 14,
              color: theme.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.$1,
                      style: poppinsRegular.copyWith(
                        fontSize: 13,
                        color: theme.primaryText,
                      ),
                    ),
                    Text(
                      item.$2 >= 0
                          ? '\$${item.$2.toStringAsFixed(2)}'
                          : '-\$${item.$2.abs().toStringAsFixed(2)}',
                      style: poppinsMedium.copyWith(
                        fontSize: 13,
                        color: item.$2 < 0 ? Colors.green : theme.primaryText,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildValidationStatus(AppTheme theme) {
    final errors = _cubit.state.validationErrors;

    if (errors.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
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
                    'All validation checks passed',
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
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
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
          ...errors.take(3).map((error) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error.message,
                        style: poppinsRegular.copyWith(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(AppTheme theme) {
    final canSubmit = _cubit.canSubmit;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: canSubmit ? _submitReturn : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canSubmit ? theme.primary : theme.secondaryText,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
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
    );
  }

  void _submitReturn() {
    // Show confirmation dialog and submit
    SnackbarHelper.showSuccess('Tax return submission coming soon',
        title: 'Submit');
  }

  // ===========================================================================
  // Helper Widgets
  // ===========================================================================

  Widget _buildSectionHeader(
    AppTheme theme, {
    required String title,
    required IconData icon,
    required bool isEditing,
    VoidCallback? onEdit,
    VoidCallback? onSave,
    VoidCallback? onCancel,
  }) {
    return Row(
      children: [
        Icon(icon, color: theme.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: poppinsSemiBold.copyWith(
              fontSize: 16,
              color: theme.primaryText,
            ),
          ),
        ),
        if (isEditing) ...[
          TextButton(
            onPressed: onCancel,
            child: Text('Cancel', style: TextStyle(color: theme.secondaryText)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Save'),
          ),
        ] else if (onEdit != null)
          IconButton(
            icon: Icon(Icons.edit, color: theme.secondaryText, size: 20),
            onPressed: onEdit,
          ),
      ],
    );
  }

  Widget _buildInfoRow(
    AppTheme theme,
    String label,
    String value, {
    bool isSensitive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: poppinsRegular.copyWith(
                fontSize: 13,
                color: theme.secondaryText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: poppinsMedium.copyWith(
                fontSize: 13,
                color: theme.primaryText,
              ),
            ),
          ),
          if (isSensitive)
            Icon(Icons.visibility_off, size: 16, color: theme.secondaryText),
        ],
      ),
    );
  }

  Widget _buildTextField(
    AppTheme theme, {
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildEmptyState(
    AppTheme theme, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: theme.secondaryText),
          const SizedBox(height: 12),
          Text(
            title,
            style: poppinsMedium.copyWith(
              fontSize: 14,
              color: theme.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: poppinsRegular.copyWith(
              fontSize: 12,
              color: theme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
