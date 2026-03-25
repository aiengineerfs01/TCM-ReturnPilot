import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcm_return_pilot/constants/strings.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/presentation/authentication/cubit/auth_cubit.dart';
import 'package:tcm_return_pilot/widgets/custom_buttons.dart';
import 'package:tcm_return_pilot/widgets/safe_pop_scope.dart';
import 'package:tcm_return_pilot/widgets/solvquest_logo.dart';

class VerificationInProgressScreen extends StatefulWidget {
  const VerificationInProgressScreen({super.key});

  static const String routeName = 'VerificationInProgressScreen';
  static const String routePath = '/verification-in-progress';

  @override
  State<VerificationInProgressScreen> createState() =>
      _VerificationInProgressScreenState();
}

class _VerificationInProgressScreenState
    extends State<VerificationInProgressScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return SafePopScope(
      child: Scaffold(
        backgroundColor: theme.primaryBackground,
        body: SafeArea(
          child: Column(
            children: [
              Image.asset(
                Strings.verificationProgress,
                height: 300,
                fit: BoxFit.contain,
              ),

            const SizedBox(height: 35),

            // Title
            Text(
              'Verification in Progress',
              style: poppinsSemiBold.copyWith(
                fontSize: 26,
                color: theme.primaryText,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Subtitle
            Text(
              "We're reviewing your information.\nThis usually takes a short time. You’ll be notified\nonce it’s complete.",
              style: poppinsRegular.copyWith(fontSize: 15, color: theme.black1),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 35),

            // Continue Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) => PrimaryButton(
                  isLoading: state.isLoading,
                  onTap: () {
                    context.read<AuthCubit>().onVerificationProgressContinue();
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
            ),

            const SizedBox(height: 16),

            // Logout Button
            TextButton(
              onPressed: () => context.read<AuthCubit>().logout(),
              child: Text(
                'Log out',
                style: poppinsMedium.copyWith(
                  color: theme.primaryText,
                  fontSize: 14,
                ),
              ),
            ),

            const Spacer(flex: 1),

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
