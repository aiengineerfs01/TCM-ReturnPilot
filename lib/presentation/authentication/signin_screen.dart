import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/presentation/authentication/controller/auth_controller.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/presentation/authentication/forgot_password.dart';
import 'package:tcm_return_pilot/presentation/authentication/signup_screen.dart';
import 'package:tcm_return_pilot/presentation/authentication/update_password_screen.dart';
import 'package:tcm_return_pilot/presentation/authentication/welcome_consent_screen.dart';
import 'package:tcm_return_pilot/presentation/mfa/verify_page.dart';
import 'package:tcm_return_pilot/utils/validators.dart';
import 'package:tcm_return_pilot/widgets/app_logo.dart';
import 'package:tcm_return_pilot/widgets/back_arrow.dart';
import 'package:tcm_return_pilot/widgets/custom_buttons.dart';
import 'package:tcm_return_pilot/widgets/custom_text_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  static const String routeName = 'SignInScreen';
  static const String routePath = '/signInScreen';

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthController _authController = Get.put(AuthController());
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _passwordVisible = false;

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
        body: Obx(() {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// --- Header Row ---
                  const BackArrow(),

                  const SizedBox(height: 32),
                  AppLogo(color: theme.primary, width: 300),

                  /// --- Welcome Text ---
                  Center(
                    child: Text(
                      'Hi, Welcome Back! 👋',
                      style: poppinsSemiBold.copyWith(fontSize: 24),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Center(
                    child: Text(
                      'Your journey continues here.',
                      style: poppinsRegular.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  /// --- Email Field ---
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

                  /// --- Password Field ---
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

                  /// --- Remember Me + Forgot Password ---
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (v) => setState(() => _rememberMe = v!),
                        activeColor: theme.primary,
                        checkColor: Colors.white,
                        side: BorderSide(color: theme.secondaryText, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Text(
                        'Remember Me',
                        style: poppinsMedium.copyWith(
                          color: theme.appSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          WelcomeConsentScreen.routePath,
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: poppinsMedium.copyWith(
                            color: theme.primary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  /// --- Sign In Button ---
                  PrimaryButton(
                    title: 'Sign In',
                    onTap: _authController.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              await _authController.login(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                              );
                            }
                          },

                    child: _authController.isLoading
                        ? const CircularProgressIndicator.adaptive()
                        : Text(
                            'Sign In',
                            style: poppinsMedium.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                  ),

                  const SizedBox(height: 16),

                  /// --- Sign Up Prompt ---
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: poppinsRegular.copyWith(fontSize: 14),
                        children: [
                          TextSpan(
                            text: "Don’t have an account? ",
                            style: poppinsRegular.copyWith(
                              color: theme.secondaryText,
                            ),
                          ),
                          TextSpan(
                            text: "Sign Up",
                            style: poppinsSemiBold.copyWith(color: theme.info),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Navigator.pushNamed(
                                context,
                                SignUpScreen.routePath,
                              ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
