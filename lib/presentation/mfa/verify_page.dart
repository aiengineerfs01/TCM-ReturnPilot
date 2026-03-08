import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/domain/theme/pin_theme.dart';
import 'package:tcm_return_pilot/services/auth_service.dart';
import 'package:tcm_return_pilot/widgets/app_top_bar.dart';
import 'package:tcm_return_pilot/widgets/custom_buttons.dart';
import 'package:tcm_return_pilot/widgets/solvquest_logo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcm_return_pilot/presentation/authentication/cubit/auth_cubit.dart';

class MFAVerifyPage extends StatefulWidget {
  static const route = '/mfa/verify';
  const MFAVerifyPage({super.key});

  static const String routeName = 'MFAVerifyPage';
  static const String routePath = '/mfaVerifyPage';

  @override
  State<MFAVerifyPage> createState() => _MFAVerifyPageState();
}

class _MFAVerifyPageState extends State<MFAVerifyPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _pinController = TextEditingController();

  @override
  initState() {
    super.initState();
    _pinController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.of(context).primaryBackground,
      body: Column(
        children: [
          AppTopBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(21, 20, 21, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verify MFA',
                    style: poppinsSemiBold.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Enter the 6-digit code from your authentication app to continue.',
                    style: poppinsMedium.copyWith(
                      fontSize: 14,
                      color: theme.grey2,
                    ),
                  ),
                  const SizedBox(height: 40),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Pinput(
                      length: 6,
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      defaultPinTheme: AppPinThemes.defaultTheme(context),
                      focusedPinTheme: AppPinThemes.focusedTheme(context),
                      submittedPinTheme: AppPinThemes.submittedTheme(context),
                      separatorBuilder: (index) => const SizedBox(width: 12),
                      onCompleted: (value) async {
                        // await _authService.verifyTotpCode(value);
                      },
                    ),
                  ),

                  const SizedBox(height: 35),

                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) => PrimaryButton(
                      title: 'Verify',
                      isLoading: state.isLoading,
                      onTap: _pinController.text.length < 6
                          ? null
                          : () async {
                              await _authService.verifyTotpCode(
                                _pinController.text,
                                onSuccess: () => context.read<AuthCubit>().handlePostMfa(),
                                setLoading: (v) {},
                              );
                            },
                    ),
                  ),

                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.center,
                    child: RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                'By proceeding you are indicating that you have read and agree to our ',
                            style: poppinsRegular.copyWith(
                              fontSize: 14,
                              color: theme.grey4,
                            ),
                          ),
                          TextSpan(
                            text: 'consent terms',
                            style: poppinsSemiBold.copyWith(
                              fontSize: 15,
                              color: theme.grey4,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Navigator.pop(context),
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
  }
}
