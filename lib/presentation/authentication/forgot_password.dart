import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tcm_return_pilot/constants/strings.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/domain/theme/theme.dart';
import 'package:tcm_return_pilot/presentation/authentication/cubit/auth_cubit.dart';
import 'package:tcm_return_pilot/utils/validators.dart';
import 'package:tcm_return_pilot/widgets/app_top_bar.dart';
import 'package:tcm_return_pilot/widgets/custom_buttons.dart';
import 'package:tcm_return_pilot/widgets/custom_text_field.dart';
import 'package:tcm_return_pilot/widgets/solvquest_logo.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const String routeName = 'ForgotPassword';
  static const String routePath = '/forgotPassword';

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppTheme.of(context).primaryBackground,
        body: BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                AppTopBar(),
                Expanded(
                  child: Padding(
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
                          'Forgot Password?',
                          style: poppinsSemiBold.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Enter your email to receive reset instructions.',
                          style: poppinsMedium.copyWith(
                            fontSize: 14,
                            color: theme.grey2,
                          ),
                        ),
                        const SizedBox(height: 30),

                        Center(
                          child: Image.asset(
                            Strings.forgotPassword,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            color: isDark ? Colors.white : AppColors.light.primary,
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
                        const SizedBox(height: 30),

                        PrimaryButton(
                          onTap: state.isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthCubit>().resetPassword(
                                      _emailController.text.trim(),
                                    );
                                  }
                                },
                          child: state.isLoading
                              ? const CircularProgressIndicator.adaptive()
                              : Text(
                                  'Continue',
                                  style: poppinsMedium.copyWith(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            'Don’t remember your email?',
                            style: poppinsSemiBold.copyWith(
                              color: theme.grey2,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.center,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Contact us at ',
                                  style: poppinsRegular.copyWith(
                                    fontSize: 15,
                                    color: AppTheme.of(context).secondaryText,
                                  ),
                                ),
                                TextSpan(
                                  text: 'returnpilot.com',
                                  style: poppinsRegular.copyWith(
                                    fontSize: 15,
                                    color: theme.appGreen,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => context.pop(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Spacer(),

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
