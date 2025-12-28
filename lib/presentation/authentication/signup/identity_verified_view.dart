import 'package:flutter/material.dart';
import 'package:tcm_return_pilot/constants/strings.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/presentation/home/home_screen.dart';
import 'package:tcm_return_pilot/widgets/custom_buttons.dart';
import 'package:tcm_return_pilot/widgets/solvquest_logo.dart';

class IdentityVerifiedScreen extends StatelessWidget {
  const IdentityVerifiedScreen({super.key});

  static const String routeName = 'IdentityVerifiedScreen';
  static const String routePath = '/identity-verified';

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Success Shield Icon
            Image.asset(
              Strings.identityVerified,
              height: 174,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 50),

            // Title
            Text(
              'Identity Verified! ',
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
                'Your identity has been successfully verified\nand your account has been created.',
                style: poppinsRegular.copyWith(
                  fontSize: 15,
                  color: theme.black1,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 50),

            // Continue Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PrimaryButton(
                onTap: () {
                  // Navigate to home screen or dashboard
                  Navigator.pushReplacementNamed(context, HomeScreen.routePath);
                },
                child: Text(
                  'Continue',
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
    );
  }
}
