import 'package:flutter/material.dart';
import 'package:tcm_return_pilot/constants/typography.dart';

/// Before We Begin screen widget for the interview flow.
/// Displays information cards and action buttons before starting the interview.
class BeforeWeBeginScreen extends StatelessWidget {
  final VoidCallback onUploadDocuments;
  final VoidCallback onStartInterview;

  const BeforeWeBeginScreen({
    super.key,
    required this.onUploadDocuments,
    required this.onStartInterview,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colors based on theme
    final backgroundColor = isDark ? const Color(0xFF16171D) : Colors.white;
    final cardColor = isDark ? const Color(0xFF323232) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0B2D6C);
    final secondaryTextColor = isDark
        ? const Color(0xFFD9D9D9)
        : Colors.black87;
    final buttonBorderColor = isDark ? Colors.white : const Color(0xFF0B2D6C);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26.5, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Logo
              _buildLogo(isDark),

              const SizedBox(height: 25),

              // Before We Begin Card
              _buildInfoCard(
                cardColor: cardColor,
                child: Column(
                  children: [
                    Text(
                      'Before We Begin',
                      style: poppinsBold.copyWith(
                        fontSize: 22,
                        height: 26 / 22,
                        color: primaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'If you already have tax documents handy, you can share them with us now.\nIf not, that\'s okay! we will guide you step by step.',
                      style: poppinsMedium.copyWith(
                        fontSize: 13,
                        height: 22 / 13,
                        color: secondaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Refund Estimates Card
              _buildInfoCard(
                cardColor: cardColor,
                child: Column(
                  children: [
                    Text(
                      'Refund or Balanced Owed Estimates appear as we collect information.',
                      style: poppinsBold.copyWith(
                        fontSize: 14,
                        height: 22 / 14,
                        color: isDark
                            ? const Color(0xFFD9D9D9)
                            : primaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isDark
                          ? 'Refund or Balanced Owed Estimates appear as we collect information.'
                          : 'Your estimate may start blank or partial and will update as documents and answers are added.',
                      style: poppinsMedium.copyWith(
                        fontSize: 13,
                        height: 22 / 13,
                        color: secondaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Action Buttons
              Column(
                children: [
                  // Upload Documents Button
                  SizedBox(
                    width: double.infinity,
                    height: 53.3,
                    child: ElevatedButton(
                      onPressed: onUploadDocuments,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B2D6C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: isDark
                              ? const BorderSide(color: Colors.white, width: 1)
                              : BorderSide.none,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22.21,
                          vertical: 13.32,
                        ),
                      ),
                      child: Text(
                        'Upload Documents Now',
                        style: poppinsSemiBold.copyWith(
                          fontSize: 15.55,
                          height: 27 / 15.55,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Start Interview Button
                  SizedBox(
                    width: double.infinity,
                    height: 53.3,
                    child: OutlinedButton(
                      onPressed: onStartInterview,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: buttonBorderColor,
                        elevation: 0,
                        side: BorderSide(color: buttonBorderColor, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22.21,
                          vertical: 13.32,
                        ),
                      ),
                      child: Text(
                        'Start Interview',
                        style: poppinsSemiBold.copyWith(
                          fontSize: 15.55,
                          height: 27 / 15.55,
                          color: buttonBorderColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Pricing Note Card
              _buildInfoCard(
                cardColor: cardColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 21,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Pricing Note',
                        style: poppinsBold.copyWith(
                          fontSize: 19,
                          height: 26 / 19,
                          color: primaryTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildBulletPoint(
                      'Simple tax returns are filed with a one-time fee.',
                      secondaryTextColor,
                    ),
                    const SizedBox(height: 4),
                    _buildBulletPoint(
                      'Optional ReturnPilot Plus includes year-round tools and covers future filings while active.',
                      secondaryTextColor,
                    ),
                    const SizedBox(height: 4),
                    _buildBulletPoint(
                      'If additional services are ever required, you\'ll see pricing before you\'re asked to continue.',
                      secondaryTextColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
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
                  fontSize: 28,
                  color: const Color(0xFF0B2D6C),
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'ETURN',
                style: poppinsBold.copyWith(
                  fontSize: 22,
                  color: const Color(0xFF0B2D6C),
                  letterSpacing: 1,
                ),
              ),
              TextSpan(
                text: 'P',
                style: poppinsBold.copyWith(
                  fontSize: 28,
                  color: const Color(0xFF0B2D6C),
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'ILOT',
                style: poppinsBold.copyWith(
                  fontSize: 22,
                  color: const Color(0xFF0B2D6C),
                  letterSpacing: 1,
                ),
              ),
              TextSpan(
                text: '™',
                style: poppinsRegular.copyWith(
                  fontSize: 12,
                  color: const Color(0xFF0B2D6C),
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
                  fontSize: 9,
                  color: isDark
                      ? Colors.white.withOpacity(0.8)
                      : Colors.black54,
                ),
              ),
              TextSpan(
                text: 'SolvQuest AI TCM',
                style: poppinsSemiBold.copyWith(
                  fontSize: 9,
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
            fontSize: 8,
            color: isDark ? Colors.white.withOpacity(0.7) : Colors.black45,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required Color cardColor,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 21,
    ),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10.91),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 17.46,
            offset: Offset.zero,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildBulletPoint(String text, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: poppinsMedium.copyWith(
            fontSize: 13,
            height: 22 / 13,
            color: textColor,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: poppinsMedium.copyWith(
              fontSize: 13,
              height: 22 / 13,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
