import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/presentation/authentication/cubit/auth_cubit.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/utils/validators.dart';
import 'package:tcm_return_pilot/widgets/app_top_bar.dart';
import 'package:tcm_return_pilot/widgets/custom_buttons.dart';
import 'package:tcm_return_pilot/widgets/custom_text_field.dart';
import 'package:tcm_return_pilot/widgets/solvquest_logo.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static const String routeName = 'SignUpScreen';
  static const String routePath = '/signUp';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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
        body: BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                AppTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      21,
                      20,
                      21,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create an Account',
                          style: poppinsSemiBold.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'It only takes a moment to join',
                          style: poppinsMedium.copyWith(
                            fontSize: 14,
                            color: theme.grey2,
                          ),
                        ),
                        const SizedBox(height: 30),

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
                        const SizedBox(height: 4),
                        Text(
                          'At least 8 characters with uppercase letters and numbers',
                          style: poppinsRegular.copyWith(
                            fontSize: 13,
                            color: theme.grey2,
                          ),
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
                              _confirmPasswordVisible =
                                  !_confirmPasswordVisible;
                            });
                          },
                          controller: _confirmPasswordController,
                          validator: (value) =>
                              Validator.confirmPasswordValidator(
                                value,
                                _passwordController.text,
                              ),
                        ),
                        const SizedBox(height: 30),
                        PrimaryButton(
                          onTap: state.isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    await context.read<AuthCubit>().signUp(
                                      _emailController.text.trim(),
                                      _passwordController.text.trim(),
                                      _nameController.text.trim(),
                                    );
                                  }
                                },
                          child: state.isLoading
                              ? const CircularProgressIndicator.adaptive()
                              : Text(
                                  'Signup',
                                  style: poppinsMedium.copyWith(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.center,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Already have an account? ',
                                  style: poppinsRegular.copyWith(
                                    fontSize: 15,
                                    color: AppTheme.of(context).secondaryText,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Sign in',
                                  style: poppinsMedium.copyWith(
                                    fontSize: 14,
                                    color: theme.appGreen,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      if (context.canPop()) context.pop();
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        Center(child: SolvquestLogo(height: 45)),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
