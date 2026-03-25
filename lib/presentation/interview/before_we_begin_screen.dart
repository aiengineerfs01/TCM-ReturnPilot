import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tcm_return_pilot/constants/strings.dart';

class BeforeWeBeginScreen extends StatelessWidget {
  const BeforeWeBeginScreen({super.key});

  static const _navyBlue = Color(0xFF0B2D6C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 17),
            child: Column(
              children: [
                // ReturnPilot logo (blue version for white bg)
                Image.asset(
                  Strings.returnPilotLogoBluePng,
                  height: 75,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 17),

                // Card 1: Before We Begin
                _buildInfoCard(
                  child: Column(
                    children: [
                      const Text(
                        'Before We Begin',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          height: 26 / 22,
                          color: _navyBlue,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'If you already have tax documents handy, you can share them with us now.\nIf not, that\'s okay! we will guide you step by step.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          height: 22 / 13,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Card 2: Refund or Balanced Owed Estimates
                _buildInfoCard(
                  child: Column(
                    children: [
                      const Text(
                        'Refund or Balanced Owed Estimates appear as we collect information.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          height: 22 / 14,
                          color: _navyBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your estimate may start blank or partial and will update as documents and answers are added.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          height: 22 / 13,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Buttons
                // Upload Documents Now (solid)
                SizedBox(
                  width: double.infinity,
                  height: 53.3,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to documents tab or upload flow
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _navyBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Text(
                      'Upload Documents Now',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 15.55,
                        height: 27 / 15.55,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Start Interview (outlined)
                SizedBox(
                  width: double.infinity,
                  height: 53.3,
                  child: OutlinedButton(
                    onPressed: () {
                      context.push('/interview');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _navyBlue,
                      side: const BorderSide(color: _navyBlue, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Text(
                      'Start Interview',
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
                const SizedBox(height: 10),

                // Card 3: Review disclaimer
                _buildInfoCard(
                  child: const Text(
                    'Every return is reviewed by a licensed tax professional before filing.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      height: 22 / 13,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Card 4: Pricing Note
                _buildInfoCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 21,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Pricing Note',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 19,
                            height: 26 / 19,
                            color: _navyBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildBulletPoint(
                        'Simple tax returns are filed with a one-time fee.',
                      ),
                      const SizedBox(height: 4),
                      _buildBulletPoint(
                        'Optional ReturnPilot Plus includes year-round tools and covers future filings while active.',
                      ),
                      const SizedBox(height: 4),
                      _buildBulletPoint(
                        'If additional services are ever required, you\'ll see pricing before you\'re asked to continue.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      width: double.infinity,
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 0, vertical: 21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.91),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            blurRadius: 17.46,
          ),
        ],
      ),
      child: Padding(
        padding: padding != null
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 20),
        child: child,
      ),
    );
  }

  static Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Icon(Icons.circle, size: 5, color: Color(0xFF333333)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 13,
              height: 22 / 13,
              color: Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }
}
