import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcm_return_pilot/constants/strings.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/presentation/authentication/controller/auth_controller.dart';
import 'package:tcm_return_pilot/utils/validators.dart';
import 'package:tcm_return_pilot/widgets/back_arrow.dart';
import 'package:tcm_return_pilot/widgets/custom_buttons.dart';
import 'package:tcm_return_pilot/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const String routeName = 'ForgotPassword';
  static const String routePath = '/forgotPassword';

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthController _authController = Get.find<AuthController>();
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppTheme.of(context).primaryBackground,
        body: Obx(() {
          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 45, 24, 0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [BackArrow()]),
                    SizedBox(height: 50),
                    Align(
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(0),
                        child: Image.asset(
                          Strings.forgotPassword,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          0,
                          32,
                          0,
                          0,
                        ),
                        child: Text(
                          'Forgot Password',
                          style: poppinsMedium.copyWith(fontSize: 24),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                      child: Text(
                        'Please enter your email address to reset your password',
                        textAlign: TextAlign.center,
                        style: poppinsMedium.copyWith(
                          fontSize: 14,
                          color: AppTheme.of(context).secondaryText,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      hintText: 'Enter your email address',
                      controller: _emailController,
                      validator: Validator.emailValidator,
                    ),
                    SizedBox(height: 20),
                    PrimaryButton(
                      onTap: _authController.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                _authController.resetPassword(
                                  _emailController.text.trim(),
                                );
                              }
                            },
                      child: _authController.isLoading
                          ? const CircularProgressIndicator.adaptive()
                          : Text(
                              'Continue',
                              style: poppinsMedium.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                    ),

                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          0,
                          20,
                          0,
                          0,
                        ),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    'Don’t remember your email?\nContact us at ',
                                style: poppinsMedium.copyWith(
                                  fontSize: 14,
                                  color: AppTheme.of(context).secondaryText,
                                ),
                              ),
                              TextSpan(
                                text: 'returnpilot.com',
                                style: poppinsMedium.copyWith(
                                  fontSize: 14,
                                  color: AppTheme.of(context).info,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
