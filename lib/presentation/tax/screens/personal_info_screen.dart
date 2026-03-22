/// =============================================================================
/// Personal Info Screen
///
/// Screen for managing taxpayer personal information:
/// - Filing status selection
/// - Primary taxpayer info
/// - Spouse info (if MFJ)
/// - Dependents management
/// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/models/tax/tax_models.dart';
import 'package:tcm_return_pilot/presentation/tax/cubit/tax_return_cubit.dart';
import 'package:tcm_return_pilot/widgets/back_arrow.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  static const String routeName = 'PersonalInfoScreen';
  static const String routePath = '/personal-info';

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  FilingStatus _selectedFilingStatus = FilingStatus.single;

  // Primary taxpayer controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ssnController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _occupationController = TextEditingController();

  // Address controllers
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  bool _dataPopulated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dataPopulated) {
      _dataPopulated = true;
      _populateExistingData();
    }
  }

  void _populateExistingData() {
    final cubit = context.read<TaxReturnCubit>();
    final taxpayer = cubit.primaryTaxpayer;
    final taxReturn = cubit.taxReturn;

    if (taxReturn != null) {
      _selectedFilingStatus = taxReturn.filingStatus;
    }

    if (taxpayer != null) {
      _firstNameController.text = taxpayer.firstName;
      _lastNameController.text = taxpayer.lastName;
      _ssnController.text = taxpayer.ssn;
      _emailController.text = taxpayer.email ?? '';
      _phoneController.text = taxpayer.phone ?? '';
      _occupationController.text = taxpayer.occupation ?? '';

      _dobController.text =
          '${taxpayer.dateOfBirth.month}/${taxpayer.dateOfBirth.day}/${taxpayer.dateOfBirth.year}';

      _streetController.text = taxpayer.address.street1;
      _cityController.text = taxpayer.address.city;
      _stateController.text = taxpayer.address.state.value;
      _zipController.text = taxpayer.address.zipCode;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ssnController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _occupationController.dispose();
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
                      // Filing Status Section
                      _buildFilingStatusSection(theme),
                      const SizedBox(height: 24),

                      // Primary Taxpayer Section
                      _buildPrimaryTaxpayerSection(theme),
                      const SizedBox(height: 24),

                      // Address Section
                      _buildAddressSection(theme),
                      const SizedBox(height: 24),

                      // Dependents Section
                      _buildDependentsSection(theme),
                      const SizedBox(height: 32),

                      // Save Button
                      _buildSaveButton(theme),
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
                  'Personal Information',
                  style: poppinsSemiBold.copyWith(
                    fontSize: 24,
                    color: theme.primaryText,
                  ),
                ),
                Text(
                  'Filing status and taxpayer details',
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

  Widget _buildFilingStatusSection(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filing Status',
          style: poppinsSemiBold.copyWith(
            fontSize: 18,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the status that applies to you',
          style: poppinsRegular.copyWith(
            fontSize: 14,
            color: theme.secondaryText,
          ),
        ),
        const SizedBox(height: 16),
        ...FilingStatus.values.map(
          (status) => _buildFilingStatusOption(theme, status),
        ),
      ],
    );
  }

  Widget _buildFilingStatusOption(AppTheme theme, FilingStatus status) {
    final isSelected = _selectedFilingStatus == status;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilingStatus = status;
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
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected ? theme.primary : theme.secondaryText,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.displayName,
                      style: poppinsMedium.copyWith(
                        fontSize: 14,
                        color: theme.primaryText,
                      ),
                    ),
                    Text(
                      _getFilingStatusDescription(status),
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
        ),
      ),
    );
  }

  String _getFilingStatusDescription(FilingStatus status) {
    switch (status) {
      case FilingStatus.single:
        return 'Unmarried or legally separated';
      case FilingStatus.marriedFilingJointly:
        return 'Married and filing together with spouse';
      case FilingStatus.marriedFilingSeparately:
        return 'Married but filing your own return';
      case FilingStatus.headOfHousehold:
        return 'Unmarried with qualifying dependent';
      case FilingStatus.qualifyingWidow:
        return 'Spouse died in past 2 years with dependent child';
    }
  }

  Widget _buildPrimaryTaxpayerSection(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Information',
          style: poppinsSemiBold.copyWith(
            fontSize: 18,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                theme: theme,
                controller: _firstNameController,
                label: 'First Name',
                required: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                theme: theme,
                controller: _lastNameController,
                label: 'Last Name',
                required: true,
              ),
            ),
          ],
        ),
        _buildTextField(
          theme: theme,
          controller: _ssnController,
          label: 'Social Security Number',
          hint: 'XXX-XX-XXXX',
          required: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _SsnInputFormatter(),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                theme: theme,
                controller: _dobController,
                label: 'Date of Birth',
                hint: 'MM/DD/YYYY',
                keyboardType: TextInputType.datetime,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                theme: theme,
                controller: _phoneController,
                label: 'Phone',
                hint: '(XXX) XXX-XXXX',
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        _buildTextField(
          theme: theme,
          controller: _emailController,
          label: 'Email',
          hint: 'your@email.com',
          keyboardType: TextInputType.emailAddress,
        ),
        _buildTextField(
          theme: theme,
          controller: _occupationController,
          label: 'Occupation',
          hint: 'Your occupation',
        ),
      ],
    );
  }

  Widget _buildAddressSection(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mailing Address',
          style: poppinsSemiBold.copyWith(
            fontSize: 18,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          theme: theme,
          controller: _streetController,
          label: 'Street Address',
          hint: '123 Main St',
          required: true,
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                theme: theme,
                controller: _cityController,
                label: 'City',
                required: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                theme: theme,
                controller: _stateController,
                label: 'State',
                hint: 'CA',
                required: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                theme: theme,
                controller: _zipController,
                label: 'ZIP',
                hint: '12345',
                required: true,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDependentsSection(AppTheme theme) {
    final dependents = context.read<TaxReturnCubit>().dependents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dependents',
                  style: poppinsSemiBold.copyWith(
                    fontSize: 18,
                    color: theme.primaryText,
                  ),
                ),
                Text(
                  'Children or qualifying relatives',
                  style: poppinsRegular.copyWith(
                    fontSize: 12,
                    color: theme.secondaryText,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => _showAddDependentDialog(theme),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
        ),
        const SizedBox(height: 16),
        if (dependents.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.alternate.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.family_restroom,
                  size: 48,
                  color: theme.secondaryText,
                ),
                const SizedBox(height: 12),
                Text(
                  'No dependents added',
                  style: poppinsRegular.copyWith(
                    fontSize: 14,
                    color: theme.secondaryText,
                  ),
                ),
              ],
            ),
          )
        else
          ...dependents.map((d) => _buildDependentCard(theme, d)),
      ],
    );
  }

  Widget _buildDependentCard(AppTheme theme, Dependent dependent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
              child: Icon(
                dependent.relationship.isQualifyingChildRelationship
                    ? Icons.child_care
                    : Icons.person,
                color: theme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${dependent.firstName} ${dependent.lastName}',
                    style: poppinsMedium.copyWith(
                      fontSize: 16,
                      color: theme.primaryText,
                    ),
                  ),
                  Text(
                    dependent.relationship.displayName,
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
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'CTC',
                  style: poppinsMedium.copyWith(
                    fontSize: 10,
                    color: Colors.green,
                  ),
                ),
              ),
            IconButton(
              onPressed: () {
                if (dependent.id != null) {
                  context.read<TaxReturnCubit>().removeDependent(dependent.id!);
                }
              },
              icon: Icon(Icons.delete_outline, color: theme.error),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required AppTheme theme,
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
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
                  fontSize: 12,
                  color: theme.primaryText,
                ),
              ),
              if (required)
                Text(
                  ' *',
                  style: poppinsMedium.copyWith(
                    fontSize: 12,
                    color: theme.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
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
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(AppTheme theme) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _savePersonalInfo,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Text(
          'Save Personal Information',
          style: poppinsSemiBold.copyWith(fontSize: 16),
        ),
      ),
    );
  }

  void _showAddDependentDialog(AppTheme theme) {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final ssnController = TextEditingController();
    final dobController = TextEditingController();
    DependentRelationship relationship = DependentRelationship.son;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Add Dependent',
            style: poppinsSemiBold.copyWith(fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ssnController,
                  decoration: const InputDecoration(
                    labelText: 'SSN *',
                    hintText: 'XXX-XX-XXXX',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dobController,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth *',
                    hintText: 'MM/DD/YYYY',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<DependentRelationship>(
                  value: relationship,
                  decoration: const InputDecoration(labelText: 'Relationship'),
                  items: DependentRelationship.values.map((r) {
                    return DropdownMenuItem(
                      value: r,
                      child: Text(r.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        relationship = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (firstNameController.text.isEmpty ||
                    lastNameController.text.isEmpty ||
                    ssnController.text.isEmpty) {
                  return;
                }

                // Parse DOB
                DateTime? dob;
                if (dobController.text.isNotEmpty) {
                  final parts = dobController.text.split('/');
                  if (parts.length == 3) {
                    dob = DateTime(
                      int.tryParse(parts[2]) ?? 2000,
                      int.tryParse(parts[0]) ?? 1,
                      int.tryParse(parts[1]) ?? 1,
                    );
                  }
                }

                final dependent = Dependent(
                  returnId: context.read<TaxReturnCubit>().returnId ?? '',
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  ssn: ssnController.text,
                  dateOfBirth: dob ?? DateTime(2020, 1, 1),
                  relationship: relationship,
                  monthsLivedWithTaxpayer: 12,
                );

                context.read<TaxReturnCubit>().addDependent(dependent);

                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePersonalInfo() async {
    // Update filing status
    context.read<TaxReturnCubit>().updateFilingStatus(_selectedFilingStatus);

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personal information saved'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

/// Custom formatter for SSN (XXX-XX-XXXX)
class _SsnInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('-', '');
    if (text.length > 9) {
      return oldValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 5) buffer.write('-');
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
