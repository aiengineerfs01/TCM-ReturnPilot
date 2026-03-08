import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcm_return_pilot/constants/strings.dart';
import 'package:tcm_return_pilot/constants/typography.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/presentation/main/cubit/main_nav_cubit.dart';
import 'package:tcm_return_pilot/presentation/main/tabs/home_tab.dart';
import 'package:tcm_return_pilot/presentation/main/tabs/documents_tab.dart';
import 'package:tcm_return_pilot/presentation/main/tabs/interview_tab.dart';
import 'package:tcm_return_pilot/presentation/main/tabs/support_tab.dart';
import 'package:tcm_return_pilot/presentation/main/tabs/settings_tab.dart';

/// Main navigation screen with bottom navigation bar.
/// Contains 4 tabs: Home, Documents, Support, Settings.
class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  static const String routeName = 'MainNavScreen';
  static const String routePath = '/main';

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  /// List of tab screens
  final List<Widget> _tabs = const [
    HomeTab(),
    DocumentsTab(),
    InterviewTab(),
    SupportTab(),
    SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackground,
      body: BlocBuilder<MainNavCubit, MainNavState>(
        builder: (context, state) => IndexedStack(index: state.currentIndex, children: _tabs),
      ),
      bottomNavigationBar: BlocBuilder<MainNavCubit, MainNavState>(
        builder: (context, state) => Container(
          decoration: const BoxDecoration(color: Color(0xFF0B2D6C)),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 6, right: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Strings.homeIcon,
                    label: 'Home',
                    index: MainNavCubit.homeTab,
                    currentIndex: state.currentIndex,
                  ),
                  _buildNavItem(
                    icon: Strings.documentsIcon,
                    label: 'Documents',
                    index: MainNavCubit.documentsTab,
                    currentIndex: state.currentIndex,
                  ),
                  _buildNavItem(
                    icon: Strings.documentsIcon,
                    label: 'Interview',
                    index: MainNavCubit.interviewTab,
                    currentIndex: state.currentIndex,
                  ),
                  _buildNavItem(
                    icon: Strings.supportIcon,
                    label: 'Support',
                    index: MainNavCubit.supportTab,
                    currentIndex: state.currentIndex,
                  ),
                  _buildNavItem(
                    icon: Strings.settingsIcon,
                    label: 'Settings',
                    index: MainNavCubit.settingsTab,
                    currentIndex: state.currentIndex,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    // required IconData icon,
    // required IconData activeIcon,
    required String icon,
    required String label,
    required int index,
    required int currentIndex,
  }) {
    final isSelected = currentIndex == index;
    // Active: teal/green (#5CC1B4), Inactive: white
    final color = isSelected ? const Color(0xFF5CC1B4) : Colors.white;

    return InkWell(
      onTap: () => context.read<MainNavCubit>().changeTab(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //Icon(isSelected ? activeIcon : icon, color: color, size: 26),
            Image.asset(
              icon,
              height: 26,
              color: isSelected ? const Color(0xFF5CC1B4) : Colors.white,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: poppinsMedium.copyWith(fontSize: 12, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
