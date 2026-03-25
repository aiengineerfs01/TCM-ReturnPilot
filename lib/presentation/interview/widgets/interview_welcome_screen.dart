import 'package:flutter/material.dart';
import 'package:tcm_return_pilot/constants/typography.dart';

/// Welcome screen widget for the interview flow.
/// Displays "Welcome to ReturnPilot" with branding and CTA button.
class InterviewWelcomeScreen extends StatelessWidget {
  final VoidCallback onStartTaxReturn;

  const InterviewWelcomeScreen({super.key, required this.onStartTaxReturn});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0B2D6C),
        borderRadius: BorderRadius.circular(0),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 43),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Welcome to text
              Text(
                'Welcome to',
                style: poppinsBold.copyWith(
                  fontSize: 27,
                  height: 40 / 27,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 14),

              // ReturnPilot Logo
              _buildLogo(),

              const SizedBox(height: 14),

              // Description text
              Text(
                'We will guide you step by step to prepare your tax return.',
                style: poppinsRegular.copyWith(
                  fontSize: 13,
                  height: 22 / 13,
                  color: const Color(0xFFD9D9D9),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 26),

              Text(
                'You will see your Refund or Balanced Owed update as we go, and you can stop and come back at anytime.',
                style: poppinsRegular.copyWith(
                  fontSize: 13,
                  height: 22 / 13,
                  color: const Color(0xFFD9D9D9),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 85),

              // Start My Tax Return Button
              SizedBox(
                width: double.infinity,
                height: 53.3,
                child: ElevatedButton(
                  onPressed: onStartTaxReturn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0B2D6C),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22.21,
                      vertical: 13.32,
                    ),
                  ),
                  child: Text(
                    'Start My Tax Return',
                    style: poppinsSemiBold.copyWith(
                      fontSize: 15.55,
                      height: 27 / 15.55,
                      color: const Color(0xFF0B2D6C),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // ReturnPilot text logo
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'R',
                style: poppinsBold.copyWith(
                  fontSize: 32,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'ETURN',
                style: poppinsBold.copyWith(
                  fontSize: 26,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              TextSpan(
                text: 'P',
                style: poppinsBold.copyWith(
                  fontSize: 32,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'ILOT',
                style: poppinsBold.copyWith(
                  fontSize: 26,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              TextSpan(
                text: '™',
                style: poppinsRegular.copyWith(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Tagline
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Powered by ',
                style: poppinsRegular.copyWith(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              TextSpan(
                text: 'SolvQuest AI TCM',
                style: poppinsSemiBold.copyWith(
                  fontSize: 10,
                  color: const Color(0xFF5CC1B4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Tax & Compliance Master',
          style: poppinsRegular.copyWith(
            fontSize: 9,
            color: Colors.white.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
