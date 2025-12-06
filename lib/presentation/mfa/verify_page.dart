import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/domain/theme/pin_theme.dart';
import 'package:tcm_return_pilot/presentation/authentication/signin_screen.dart';
import 'package:tcm_return_pilot/presentation/authentication/signup_screen.dart';
import 'package:tcm_return_pilot/presentation/home/home_screen.dart';
import 'package:tcm_return_pilot/presentation/mfa/widgets/enroll_mfa_guide_dialog.dart';
import 'package:tcm_return_pilot/presentation/mfa/widgets/verify_mfa_guide_dialog.dart';
import 'package:tcm_return_pilot/services/auth_service.dart';
import 'package:tcm_return_pilot/utils/dialogs.dart';
import 'package:tcm_return_pilot/widgets/custom_snackbar.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: (){
                      showAppDialog(context, VerifyMFAGuideDialog());
                    },
                    child: Icon(
                      Icons.info_outline,
                      size: 25,
                      color: AppTheme.of(context).accent3,
                    ),
                  ),
                  Text('Verify MFA', style: AppTheme.of(context).headlineSmall),
                  GestureDetector(
                    onTap: () async {
                      var result = await _authService.signOut();
                      if (result != null) {
                        AppSnackBar.show(
                          title: 'Error',
                          message: result.toString(),
                        );
                      }
                      if (context.mounted) {
                        Navigator.pushNamed(context, SignInScreen.routePath);
                      }
                    },
                    child: Icon(
                      Icons.logout,
                      size: 25,
                      color: AppTheme.of(context).error,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: 72,
                        color: AppTheme.of(context).primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Verification Required',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enter the 6-digit code from your authentication app to continue.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      const SizedBox(height: 32),
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
                          submittedPinTheme: AppPinThemes.submittedTheme(
                            context,
                          ),
                          onCompleted: (value) async {
                            await _authService.verifyTotpCode(value);
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
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
}
