import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/presentation/authentication/controller/auth_controller.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/presentation/home/home_screen.dart';
import 'package:tcm_return_pilot/widgets/app_logo.dart';
import 'package:tcm_return_pilot/widgets/app_top_bar.dart';
import 'package:tcm_return_pilot/widgets/custom_buttons.dart';
import 'package:tcm_return_pilot/widgets/safe_pop_scope.dart';

class WelcomeConsentScreen extends StatefulWidget {
  const WelcomeConsentScreen({super.key});

  static const String routeName = 'WelcomeConsentScreen';
  static const String routePath = '/welcomeConsent';

  @override
  State<WelcomeConsentScreen> createState() => _WelcomeConsentScreenState();
}

class _WelcomeConsentScreenState extends State<WelcomeConsentScreen> {
  final AuthController _authController = Get.find<AuthController>();
  bool _consentChecked = false;
  bool _isLoading = false;

  Future<void> _handleContinue() async {
    if (!_consentChecked) {
      Get.snackbar(
        'Consent Required',
        'Please agree to continue.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);
    await _authController.updateProfileConsent(
      userId: _authController.user.value!.id,
      checkedConsent: _consentChecked,
    );
    setState(() => _isLoading = false);

    Get.offNamed(HomeScreen.routePath);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return SafePopScope(
      child: Scaffold(
        backgroundColor: theme.primaryBackground,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTopBar(),
              const SizedBox(height: 27),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  'Terms and Conditions',
                  style: poppinsBold.copyWith(
                    fontSize: 25,
                    color: theme.primaryText,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // --- Intro to Tax Process Section ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Understanding the Tax Process',
                      style: poppinsSemiBold.copyWith(
                        fontSize: 18,
                        color: theme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '1. **Document Upload:** Securely upload your financial documents.\n\n'
                      '2. **AI Review:** Our TCM AI analyzes your data for accuracy and deductions.\n\n'
                      '3. **Tax Calculation:** We compute your return and show you a clear breakdown.\n\n'
                      '4. **Submission:** After your consent, we file your tax documents securely.\n\n'
                      'Throughout this process, your data remains encrypted and handled with care.',
                      style: poppinsRegular.copyWith(
                        fontSize: 15,
                        color: theme.accent3,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- Consent Agreement Section ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Consent Agreement',
                      style: poppinsSemiBold.copyWith(
                        fontSize: 18,
                        color: theme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'By continuing, you consent to allow TCM (Tax Compliance Manager) to use AI '
                      'to process your tax data, verify accuracy, and securely share documents '
                      'with authorized entities for compliance and filing purposes.',
                      style: poppinsRegular.copyWith(
                        fontSize: 14,
                        color: theme.accent3,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Transform.translate(
                          offset: const Offset(-8, 0),
                          child: Checkbox(
                            value: _consentChecked,
                            onChanged: (v) =>
                                setState(() => _consentChecked = v!),
                            activeColor: theme.primary,
                            checkColor: Colors.white,
                            side: BorderSide(
                              color: theme.secondaryText,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),

                        Text(
                          'I have read and agree to the consent terms.',
                          style: poppinsMedium.copyWith(
                            fontSize: 13,
                            color: theme.primaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- Continue Button ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PrimaryButton(
                  onTap: _isLoading ? null : _handleContinue,
                  child: _isLoading
                      ? const CircularProgressIndicator.adaptive()
                      : Text(
                          'Continue →',
                          style: poppinsMedium.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
