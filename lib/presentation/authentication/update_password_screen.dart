import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/pin_theme.dart';
import 'package:tcm_return_pilot/presentation/authentication/cubit/auth_cubit.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/presentation/mfa/widgets/verify_mfa_guide_dialog.dart';
import 'package:tcm_return_pilot/services/auth_service.dart';
import 'package:tcm_return_pilot/utils/dialogs.dart';
import 'package:tcm_return_pilot/utils/snackbar.dart';
import 'package:tcm_return_pilot/utils/validators.dart';
import 'package:tcm_return_pilot/widgets/app_logo.dart';
import 'package:tcm_return_pilot/widgets/back_arrow.dart';
import 'package:tcm_return_pilot/widgets/custom_buttons.dart';
import 'package:tcm_return_pilot/widgets/custom_text_field.dart';

class UpdatePassword extends StatefulWidget {
  static const route = '/password/update';
  const UpdatePassword({super.key});

  @override
  State<UpdatePassword> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();
  final TextEditingController _pinController = TextEditingController();

  bool _rememberMe = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.primaryBackground,
        body: BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// --- Header Row ---
                  BackArrow(
                    onTap: () {
                      context.go('/sign-in');
                    },
                  ),

                  const SizedBox(height: 32),
                  AppLogo(color: theme.primary, width: 300),

                  /// --- Welcome Text ---
                  Center(
                    child: Text(
                      'Reset Password 🔑',
                      style: poppinsSemiBold.copyWith(fontSize: 24),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Center(
                    child: Text(
                      'Please enter your new password below.',
                      style: poppinsRegular.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  /// --- Password Field ---
                  Text(
                    'New Password',
                    style: poppinsMedium.copyWith(
                      color: theme.appSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),

                  CustomTextField(
                    hintText: 'Enter your new password',
                    suffixIcon: _passwordVisible
                        ? Icons.visibility_off
                        : Icons.remove_red_eye,
                    isSuffixIcon: true,
                    isPassword: !_passwordVisible,
                    onSuffixIconPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                    controller: _passwordController,
                    validator: Validator.passwordValidator,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Confirm Password',
                    style: poppinsMedium.copyWith(
                      color: theme.appSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText: 'Confirm your password',
                    suffixIcon: _confirmPasswordVisible
                        ? Icons.visibility_off
                        : Icons.remove_red_eye,
                    isSuffixIcon: true,
                    isPassword: !_confirmPasswordVisible,
                    onSuffixIconPressed: () {
                      setState(() {
                        _confirmPasswordVisible = !_confirmPasswordVisible;
                      });
                    },
                    controller: _confirmPasswordController,
                    validator: (value) => Validator.confirmPasswordValidator(
                      value,
                      _passwordController.text,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'MFA Verification',
                        style: poppinsMedium.copyWith(
                          color: theme.appSecondary,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          showAppDialog(context, VerifyMFAGuideDialog());
                        },
                        child: Icon(
                          Icons.info_outline,
                          size: 20,
                          color: AppTheme.of(context).accent3,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Enter the 6-digit code from your authentication app to continue.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).primaryBackground,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Pinput(
                      length: 6,
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      defaultPinTheme: AppPinThemes.defaultTheme(context),
                      focusedPinTheme: AppPinThemes.focusedTheme(context),
                      submittedPinTheme: AppPinThemes.submittedTheme(context),
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// --- Sign In Button ---
                  PrimaryButton(
                    onTap: state.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              if (_pinController.text.trim().length != 6) {
                                SnackbarHelper.showError(
                                  'Please enter the 6-digit MFA code.',
                                );
                                return;
                              }
                              context.read<AuthCubit>().updatePassword(
                                _pinController.text.trim(),
                                _passwordController.text.trim(),
                              );
                            }
                          },

                    child: state.isLoading
                        ? const CircularProgressIndicator.adaptive()
                        : Text(
                            'Update Password',
                            style: poppinsMedium.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
