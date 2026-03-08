import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/widgets/custom_buttons.dart';

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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 80,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    'Email Verified!',
                    // style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    //   fontWeight: FontWeight.bold,
                    // ),
                    style: theme.headlineSmall.copyWith(
                      color: theme.appSecondary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Your email has been successfully verified. You can now sign in to your account.',
                    textAlign: TextAlign.center,
                    style: poppinsMedium.copyWith(
                      color: theme.accent3,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Login Button
                  PrimaryButton(
                    title: 'Sign In',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
