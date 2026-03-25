import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/presentation/authentication/cubit/auth_cubit.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = 'HomeScreen';
  static const String routePath = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.primaryBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Welcome Back',
                  style: poppinsSemiBold.copyWith(
                    fontSize: 28,
                    color: theme.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'What would you like to do today?',
                  style: poppinsRegular.copyWith(
                    fontSize: 16,
                    color: theme.secondaryText,
                  ),
                ),
                const SizedBox(height: 40),

                // Tax Dashboard Card
                _buildFeatureCard(
                  theme: theme,
                  icon: Icons.account_balance,
                  title: 'Tax Dashboard',
                  subtitle: 'File your 2024 tax return',
                  color: theme.primary,
                  onTap: () => context.push('/tax-dashboard'),
                ),
                const SizedBox(height: 16),

                // Interview Card
                _buildFeatureCard(
                  theme: theme,
                  icon: Icons.chat_bubble_outline,
                  title: 'Tax Interview',
                  subtitle: 'AI-assisted tax filing',
                  color: Colors.teal,
                  onTap: () => context.push('/interview'),
                ),

                const Spacer(),

                // Logout Button
                Center(
                  child: TextButton.icon(
                    onPressed: () => context.read<AuthCubit>().logout(),
                    icon: Icon(Icons.logout, color: theme.error),
                    label: Text(
                      'Logout',
                      style: poppinsMedium.copyWith(
                        color: theme.error,
                        fontSize: 16,
                      ),
                    ),
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

  Widget _buildFeatureCard({
    required AppTheme theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.alternate.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: poppinsSemiBold.copyWith(
                      fontSize: 18,
                      color: theme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: poppinsRegular.copyWith(
                      fontSize: 14,
                      color: theme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: theme.secondaryText, size: 18),
          ],
        ),
      ),
    );
  }
}
