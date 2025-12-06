import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/presentation/authentication/controller/auth_controller.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/presentation/mfa/enroll_page.dart';
import 'package:tcm_return_pilot/utils/validators.dart';
import 'package:tcm_return_pilot/widgets/app_logo.dart';
import 'package:tcm_return_pilot/widgets/back_arrow.dart';
import 'package:tcm_return_pilot/widgets/custom_buttons.dart';
import 'package:tcm_return_pilot/widgets/custom_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static const String routeName = 'SignUpScreen';
  static const String routePath = '/signUp';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthController _authController = Get.put(AuthController());
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.of(context).primaryBackground,
        body: Obx(() {
          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 50, 24, 0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [BackArrow()]),
                    const SizedBox(height: 32),
                    AppLogo(color: theme.primary, width: 300),

                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Create Account →',
                        style: poppinsSemiBold.copyWith(fontSize: 24),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'It only takes a moment to join.',
                        style: poppinsMedium.copyWith(
                          fontSize: 14,
                          color: AppTheme.of(context).secondaryText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Full Name',
                      style: poppinsMedium.copyWith(
                        color: theme.appSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hintText: 'Enter your full name',
                      controller: _nameController,
                      validator: Validator.nameValidator,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Email Address',
                      style: poppinsMedium.copyWith(
                        color: theme.appSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hintText: 'Enter your email address',
                      controller: _emailController,
                      validator: Validator.emailValidator,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Password',
                      style: poppinsMedium.copyWith(
                        color: theme.appSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hintText: 'Enter your password',
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
                    const SizedBox(height: 32),
                    PrimaryButton(
                      onTap: _authController.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                await _authController.signUp(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                  _nameController.text.trim(),
                                );
                              }
                            },
                      child: _authController.isLoading
                          ? const CircularProgressIndicator.adaptive()
                          : Text(
                              'Create Account',
                              style: poppinsMedium.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Already have an account? ',
                              style: poppinsMedium.copyWith(
                                fontSize: 14,
                                color: AppTheme.of(context).secondaryText,
                              ),
                            ),
                            TextSpan(
                              text: 'Log in',
                              style: poppinsMedium.copyWith(
                                fontSize: 14,
                                color: AppTheme.of(context).info,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
