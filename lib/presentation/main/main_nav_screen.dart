import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcm_return_pilot/constants/strings.dart';
import 'package:tcm_return_pilot/presentation/main/cubit/main_nav_cubit.dart';
import 'package:tcm_return_pilot/presentation/main/tabs/home_tab.dart';
import 'package:tcm_return_pilot/presentation/main/tabs/documents_tab.dart';
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
  final List<Widget> _tabs = const [
    HomeTab(),
    DocumentsTab(),
    SupportTab(),
    SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MainNavCubit, MainNavState>(
        builder: (context, state) =>
            IndexedStack(index: state.currentIndex, children: _tabs),
      ),
      bottomNavigationBar: BlocBuilder<MainNavCubit, MainNavState>(
        builder: (context, state) => Container(
          height: 75,
          color: const Color(0xFF0B2D6C),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _NavItem(
                    icon: Strings.homeIcon,
                    label: 'Home',
                    isSelected: state.currentIndex == MainNavCubit.homeTab,
                    onTap: () => context
                        .read<MainNavCubit>()
                        .changeTab(MainNavCubit.homeTab),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Strings.documentsIcon,
                    label: 'Tax Documents',
                    isSelected:
                        state.currentIndex == MainNavCubit.documentsTab,
                    onTap: () => context
                        .read<MainNavCubit>()
                        .changeTab(MainNavCubit.documentsTab),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Strings.supportIcon,
                    label: 'Support',
                    isSelected:
                        state.currentIndex == MainNavCubit.supportTab,
                    onTap: () => context
                        .read<MainNavCubit>()
                        .changeTab(MainNavCubit.supportTab),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Strings.settingsIcon,
                    label: 'Settings',
                    isSelected:
                        state.currentIndex == MainNavCubit.settingsTab,
                    onTap: () => context
                        .read<MainNavCubit>()
                        .changeTab(MainNavCubit.settingsTab),
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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFF00A38C) : Colors.white;
    final opacity = isSelected ? 1.0 : 0.7;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: opacity,
        child: SizedBox(
          height: 75,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                icon,
                height: 24,
                width: 24,
                color: color,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                  height: 18 / 10,
                  letterSpacing: -0.165,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
