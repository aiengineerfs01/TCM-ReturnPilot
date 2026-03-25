import 'package:flutter/material.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';

class EnrollMfaGuideDialog extends StatefulWidget {
  const EnrollMfaGuideDialog({super.key});

  @override
  State<EnrollMfaGuideDialog> createState() => _EnrollMfaGuideDialogState();
}

class _EnrollMfaGuideDialogState extends State<EnrollMfaGuideDialog> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.of(context).accent1.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.security_rounded,
                color: AppTheme.of(context).primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'How to Set Up Google Authenticator',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Google Authenticator helps keep your account secure with a 6-digit verification code that changes every 30 seconds.',
              style: AppTheme.of(context).bodyLarge.copyWith(
                color: AppTheme.of(context).accent3,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.of(context).primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.of(context).accent1.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStep(
                    context,
                    number: '1',
                    title: 'Install the App',
                    description:
                        'Download “Google Authenticator” from the Play Store or App Store on your mobile device.',
                  ),
                  const SizedBox(height: 12),
                  _buildStep(
                    context,
                    number: '2',
                    title: 'Add Your Account',
                    description:
                        'Open the app → Tap the “+” button → Choose “Scan a QR code”. Then scan the QR shown on this screen.\n\nIf scanning isn’t possible, choose “Enter a setup key manually” and paste the code displayed here.',
                  ),
                  const SizedBox(height: 12),
                  _buildStep(
                    context,
                    number: '3',
                    title: 'Get Your Code',
                    description:
                        'After adding, your app will show a 6-digit code that refreshes automatically. Enter that code below to complete the setup.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.of(context).primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Got it',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.of(context).primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.of(
                  context,
                ).titleMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTheme.of(context).labelMedium.copyWith(
                  height: 1.4,
                  color: AppTheme.of(context).accent3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
