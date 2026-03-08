import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/domain/theme/theme_cubit.dart';
import 'package:tcm_return_pilot/presentation/authentication/cubit/auth_cubit.dart';

/// Settings tab content for the main navigation screen.
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Settings',
              style: poppinsSemiBold.copyWith(
                fontSize: 28,
                color: theme.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Customize your experience',
              style: poppinsRegular.copyWith(
                fontSize: 16,
                color: theme.secondaryText,
              ),
            ),
            const SizedBox(height: 32),

            // Appearance Section
            _buildSectionHeader(theme, 'Appearance'),
            const SizedBox(height: 12),
            _buildSettingsTile(
              theme: theme,
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              trailing: BlocBuilder<ThemeCubit, ThemeState>(
                builder: (context, state) => Switch.adaptive(
                  value: state.isDarkMode,
                  onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
                  activeColor: theme.primary,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Account Section
            _buildSectionHeader(theme, 'Account'),
            const SizedBox(height: 12),
            _buildSettingsTile(
              theme: theme,
              icon: Icons.person_outline,
              title: 'Profile',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _buildSettingsTile(
              theme: theme,
              icon: Icons.security_outlined,
              title: 'Security',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _buildSettingsTile(
              theme: theme,
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () {},
            ),

            const SizedBox(height: 24),

            // Legal Section
            _buildSectionHeader(theme, 'Legal'),
            const SizedBox(height: 12),
            _buildSettingsTile(
              theme: theme,
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _buildSettingsTile(
              theme: theme,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {},
            ),

            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.read<AuthCubit>().logout(),
                icon: Icon(Icons.logout, color: theme.error),
                label: Text(
                  'Logout',
                  style: poppinsSemiBold.copyWith(
                    color: theme.error,
                    fontSize: 16,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: theme.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(AppTheme theme, String title) {
    return Text(
      title,
      style: poppinsSemiBold.copyWith(
        fontSize: 14,
        color: theme.secondaryText,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingsTile({
    required AppTheme theme,
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
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
            Icon(icon, color: theme.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: poppinsMedium.copyWith(
                  fontSize: 16,
                  color: theme.primaryText,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios,
                  color: theme.secondaryText,
                  size: 16,
                ),
          ],
        ),
      ),
    );
  }
}
