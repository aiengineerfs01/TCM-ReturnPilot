import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tcm_return_pilot/constants/strings.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/widgets/custom_buttons.dart';
import 'package:tcm_return_pilot/widgets/solvquest_logo.dart';

class EmailVerifyScreen extends StatelessWidget {
  static const route = '/email/verify';

  const EmailVerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) => false,
      canPop: false,
      child: Scaffold(
        backgroundColor: theme.primaryBackground,
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Success Shield Icon
              Image.asset(
                Strings.identityVerifiedCheck,
                height: 100,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 50),

              // Title
              Text(
                'Email Verified!',
                style: poppinsSemiBold.copyWith(
                  fontSize: 26,
                  color: theme.primaryText,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'Your email has been successfully verified.\nYou can now sign in to your account.',
                  style: poppinsRegular.copyWith(
                    fontSize: 15,
                    color: theme.black1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 50),

              // Sign In Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PrimaryButton(
                  onTap: () {
                    context.go('/sign-in');
                  },
                  child: Text(
                    'Sign In',
                    style: poppinsMedium.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // Solvquest Logo
              const Center(child: SolvquestLogo(height: 45)),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
