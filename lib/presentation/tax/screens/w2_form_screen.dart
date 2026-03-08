/// =============================================================================
/// W-2 Form Screen
///
/// Screen for adding/editing W-2 wage and tax statement details.
/// All box numbers match IRS Form W-2.
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

class W2FormScreen extends StatefulWidget {
  const W2FormScreen({super.key});

  static const String routeName = 'W2FormScreen';
  static const String routePath = '/w2-form';

  @override
  State<W2FormScreen> createState() => _W2FormScreenState();
}

class _W2FormScreenState extends State<W2FormScreen> {
  final _formKey = GlobalKey<FormState>();

  W2Form? _existingW2;
  bool _isEditing = false;

  // Form controllers
  final _employerNameController = TextEditingController();
  final _employerEinController = TextEditingController();
  final _employerAddressController = TextEditingController();
  final _box1Controller = TextEditingController();
  final _box2Controller = TextEditingController();
  final _box3Controller = TextEditingController();
  final _box4Controller = TextEditingController();
  final _box5Controller = TextEditingController();
  final _box6Controller = TextEditingController();
  final _box12aController = TextEditingController();
  final _box12aCodeController = TextEditingController();
  final _box17Controller = TextEditingController();
  final _box18Controller = TextEditingController();
  final _box19Controller = TextEditingController();

  TaxReturnCubit get _cubit => context.read<TaxReturnCubit>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['w2'] != null) {
      _existingW2 = args['w2'] as W2Form;
      _isEditing = true;
      _populateForm();
    }
  }

  void _populateForm() {
    if (_existingW2 == null) return;

    _employerNameController.text = _existingW2!.employerName;
    _employerEinController.text = _existingW2!.employerEin;
    _employerAddressController.text =
        _existingW2!.employerAddress.formattedAddress;
    _box1Controller.text = _existingW2!.box1Wages.toString();
    _box2Controller.text = _existingW2!.box2FederalWithheld.toString();
    _box3Controller.text = _existingW2!.box3SsWages.toString();
    _box4Controller.text = _existingW2!.box4SsTax.toString();
    _box5Controller.text = _existingW2!.box5MedicareWages.toString();
    _box6Controller.text = _existingW2!.box6MedicareTax.toString();
    _box17Controller.text = (_existingW2!.stateTaxWithheld ?? 0).toString();
    _box18Controller.text = (_existingW2!.localWages ?? 0).toString();
    _box19Controller.text = (_existingW2!.localTaxWithheld ?? 0).toString();
  }

  @override
  void dispose() {
    _employerNameController.dispose();
    _employerEinController.dispose();
    _employerAddressController.dispose();
    _box1Controller.dispose();
    _box2Controller.dispose();
    _box3Controller.dispose();
    _box4Controller.dispose();
    _box5Controller.dispose();
    _box6Controller.dispose();
    _box12aController.dispose();
    _box12aCodeController.dispose();
    _box17Controller.dispose();
    _box18Controller.dispose();
    _box19Controller.dispose();
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
                      // Employer Information
                      _buildSectionTitle(theme, 'Employer Information'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        theme: theme,
                        controller: _employerNameController,
                        label: 'Employer Name',
                        hint: 'Enter employer name',
                        required: true,
                      ),
                      _buildTextField(
                        theme: theme,
                        controller: _employerEinController,
                        label: 'Employer EIN (Box b)',
                        hint: 'XX-XXXXXXX',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _EinInputFormatter(),
                        ],
                      ),
                      _buildTextField(
                        theme: theme,
                        controller: _employerAddressController,
                        label: 'Employer Address',
                        hint: 'Street, City, State ZIP',
                        maxLines: 2,
                      ),

                      const SizedBox(height: 24),

                      // Wages & Taxes
                      _buildSectionTitle(theme, 'Wages and Taxes'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCurrencyField(
                              theme: theme,
                              controller: _box1Controller,
                              label: 'Box 1 - Wages, Tips',
                              required: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCurrencyField(
                              theme: theme,
                              controller: _box2Controller,
                              label: 'Box 2 - Federal Tax',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Social Security
                      _buildSectionTitle(theme, 'Social Security'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCurrencyField(
                              theme: theme,
                              controller: _box3Controller,
                              label: 'Box 3 - SS Wages',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCurrencyField(
                              theme: theme,
                              controller: _box4Controller,
                              label: 'Box 4 - SS Tax',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Medicare
                      _buildSectionTitle(theme, 'Medicare'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCurrencyField(
                              theme: theme,
                              controller: _box5Controller,
                              label: 'Box 5 - Medicare Wages',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCurrencyField(
                              theme: theme,
                              controller: _box6Controller,
                              label: 'Box 6 - Medicare Tax',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // State & Local
                      _buildSectionTitle(
                        theme,
                        'State & Local Taxes (Optional)',
                      ),
                      const SizedBox(height: 12),
                      _buildCurrencyField(
                        theme: theme,
                        controller: _box17Controller,
                        label: 'Box 17 - State Income Tax',
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCurrencyField(
                              theme: theme,
                              controller: _box18Controller,
                              label: 'Box 18 - Local Wages',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCurrencyField(
                              theme: theme,
                              controller: _box19Controller,
                              label: 'Box 19 - Local Tax',
                            ),
                          ),
                        ],
                      ),

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
                  _isEditing ? 'Edit W-2' : 'Add W-2',
                  style: poppinsSemiBold.copyWith(
                    fontSize: 24,
                    color: theme.primaryText,
                  ),
                ),
                Text(
                  'Wage and Tax Statement',
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
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
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
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLines: maxLines,
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
          onPressed: state.isLoading ? null : _saveW2,
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
                  _isEditing ? 'Update W-2' : 'Add W-2',
                  style: poppinsSemiBold.copyWith(fontSize: 16),
                ),
        ),
      ),
    );
  }

  Future<void> _saveW2() async {
    if (!_formKey.currentState!.validate()) return;

    // Parse address from single line (simplified - in production would have separate fields)
    final addressParts = _employerAddressController.text.split(',');
    final Address employerAddress = Address(
      street1: addressParts.isNotEmpty ? addressParts[0].trim() : 'Unknown',
      city: addressParts.length > 1 ? addressParts[1].trim() : 'Unknown',
      state: USState.ca, // Default state - in production would be a dropdown
      zipCode: '00000', // Default - in production would be a field
    );

    final w2 = W2Form(
      id: _existingW2?.id,
      returnId: _cubit.taxReturn?.id ?? '',
      employerName: _employerNameController.text,
      employerEin: _employerEinController.text,
      employerAddress: employerAddress,
      box1Wages: double.tryParse(_box1Controller.text) ?? 0,
      box2FederalWithheld: double.tryParse(_box2Controller.text) ?? 0,
      box3SsWages: double.tryParse(_box3Controller.text) ?? 0,
      box4SsTax: double.tryParse(_box4Controller.text) ?? 0,
      box5MedicareWages: double.tryParse(_box5Controller.text) ?? 0,
      box6MedicareTax: double.tryParse(_box6Controller.text) ?? 0,
      stateTaxWithheld: double.tryParse(_box17Controller.text),
      localWages: double.tryParse(_box18Controller.text),
      localTaxWithheld: double.tryParse(_box19Controller.text),
    );

    if (_isEditing) {
      await _cubit.updateW2Form(w2);
    } else {
      await _cubit.addW2Form(w2);
    }

    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'W-2 updated successfully' : 'W-2 added successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

/// Custom formatter for EIN (XX-XXXXXXX)
class _EinInputFormatter extends TextInputFormatter {
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
      if (i == 2) buffer.write('-');
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
