import 'package:flutter/material.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';

class VerifyMFAGuideDialog extends StatefulWidget {
  const VerifyMFAGuideDialog({super.key});

  @override
  State<VerifyMFAGuideDialog> createState() => _VerifyMFAGuideDialogState();
}

class _VerifyMFAGuideDialogState extends State<VerifyMFAGuideDialog> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security_rounded,
                  color: AppTheme.of(context).primary,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  'How to Verify MFA',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            _buildStep(
              icon: Icons.qr_code_2_rounded,
              title: '1. Open your Authenticator App',
              description:
                  'Use Google Authenticator, Microsoft Authenticator, or Authy on your phone for which you add while signup',
            ),
            _buildStep(
              icon: Icons.lock_clock_rounded,
              title: '2. Find “Return Pilot” or your account email',
              description:
                  'Locate the 6-digit code shown under your registered account in the app.',
            ),
            _buildStep(
              icon: Icons.input_rounded,
              title: '3. Enter the 6-digit code here',
              description:
                  'The code refreshes every 30 seconds. Enter it before it expires.',
            ),

            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  backgroundColor: AppTheme.of(context).primary,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                ),
                icon: const Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: Colors.white,
                ),
                label: const Text(
                  'Got it',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.of(context).primary, size: 22),
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
                  ).labelLarge.copyWith(color: Colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTheme.of(context).bodyLarge.copyWith(
                    color: AppTheme.of(context).accent3,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
