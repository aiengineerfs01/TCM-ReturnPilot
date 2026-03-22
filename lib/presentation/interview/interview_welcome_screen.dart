import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tcm_return_pilot/constants/strings.dart';

class InterviewWelcomeScreen extends StatelessWidget {
  const InterviewWelcomeScreen({super.key});

  static const _navyBlue = Color(0xFF0B2D6C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navyBlue,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 47),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // "Welcome to" text
                const Text(
                  'Welcome to',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 27,
                    height: 40 / 27,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),

                // ReturnPilot logo
                Image.asset(
                  Strings.returnPilotLogoPng,
                  height: 81,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 14),

                // Description text
                const Text(
                  'We will guide you step by step to prepare your tax return.\n\nYou will see your Refund or Balanced Owed update as we go, and you can stop and come back at anytime.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    height: 22 / 13,
                    color: Color(0xFFD9D9D9),
                  ),
                ),
                const SizedBox(height: 85),

                // "Start My Tax Return" button
                SizedBox(
                  width: double.infinity,
                  height: 53.3,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/before-we-begin');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _navyBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Text(
                      'Start My Tax Return',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 15.55,
                        height: 27 / 15.55,
                        color: _navyBlue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
