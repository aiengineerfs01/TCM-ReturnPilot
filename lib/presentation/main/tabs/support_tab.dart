import 'package:flutter/material.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';

/// Support tab content for the main navigation screen.
/// Placeholder for support and help functionality.
class SupportTab extends StatelessWidget {
  const SupportTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Support',
              style: poppinsSemiBold.copyWith(
                fontSize: 28,
                color: theme.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Get help when you need it',
              style: poppinsRegular.copyWith(
                fontSize: 16,
                color: theme.secondaryText,
              ),
            ),
            const SizedBox(height: 40),

            // Support options
            _buildSupportOption(
              theme: theme,
              icon: Icons.help_outline,
              title: 'FAQ',
              subtitle: 'Frequently asked questions',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _buildSupportOption(
              theme: theme,
              icon: Icons.chat_outlined,
              title: 'Live Chat',
              subtitle: 'Chat with our support team',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _buildSupportOption(
              theme: theme,
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'Send us an email',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _buildSupportOption(
              theme: theme,
              icon: Icons.phone_outlined,
              title: 'Call Us',
              subtitle: 'Speak with a representative',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption({
    required AppTheme theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: theme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: poppinsSemiBold.copyWith(
                      fontSize: 16,
                      color: theme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: poppinsRegular.copyWith(
                      fontSize: 13,
                      color: theme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: theme.secondaryText, size: 16),
          ],
        ),
      ),
    );
  }
}
