import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';
import 'package:tcm_return_pilot/domain/theme/theme_controller.dart';

/// A simple toggle button for switching between light and dark mode.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({
    super.key,
    this.size = 24.0,
    this.showLabel = false,
  });

  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Obx(() {
      final controller = ThemeController.to;
      final isDark = controller.isDarkMode;

      return GestureDetector(
        onTap: controller.toggleTheme,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  key: ValueKey(isDark),
                  size: size,
                  color: isDark ? Colors.amber : theme.primary,
                ),
              ),
              if (showLabel) ...[
                const SizedBox(width: 8),
                Text(
                  isDark ? 'Dark' : 'Light',
                  style: TextStyle(
                    color: theme.primaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}

/// A segmented control for selecting theme mode (System, Light, Dark).
class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Obx(() {
      final controller = ThemeController.to;

      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.grey1,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
            final isSelected = controller.themeMode == mode;
            return GestureDetector(
              onTap: () => controller.setThemeMode(mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? theme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      mode.icon,
                      size: 18,
                      color: isSelected ? Colors.white : theme.secondaryText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      mode.label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : theme.secondaryText,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}

/// A list tile for theme selection in settings screens.
class ThemeSettingsTile extends StatelessWidget {
  const ThemeSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Obx(() {
      final controller = ThemeController.to;

      return ListTile(
        leading: Icon(
          controller.themeMode.icon,
          color: theme.primary,
        ),
        title: Text(
          'Theme',
          style: TextStyle(
            color: theme.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          controller.themeMode.label,
          style: TextStyle(color: theme.secondaryText),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: theme.secondaryText,
        ),
        onTap: () => _showThemeDialog(context),
      );
    });
  }

  void _showThemeDialog(BuildContext context) {
    final theme = AppTheme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surface,
        title: Text(
          'Choose Theme',
          style: TextStyle(color: theme.primaryText),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
            return Obx(() {
              final controller = ThemeController.to;
              final isSelected = controller.themeMode == mode;

              return RadioListTile<AppThemeMode>(
                value: mode,
                groupValue: controller.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    controller.setThemeMode(value);
                    Navigator.pop(context);
                  }
                },
                title: Row(
                  children: [
                    Icon(
                      mode.icon,
                      size: 20,
                      color: isSelected ? theme.primary : theme.secondaryText,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      mode.label,
                      style: TextStyle(
                        color: theme.primaryText,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                activeColor: theme.primary,
              );
            });
          }).toList(),
        ),
      ),
    );
  }
}

/// A dropdown for selecting theme mode.
class ThemeDropdown extends StatelessWidget {
  const ThemeDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Obx(() {
      final controller = ThemeController.to;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.borderColor),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<AppThemeMode>(
            value: controller.themeMode,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: theme.secondaryText,
            ),
            dropdownColor: theme.surface,
            borderRadius: BorderRadius.circular(12),
            items: AppThemeMode.values.map((mode) {
              return DropdownMenuItem(
                value: mode,
                child: Row(
                  children: [
                    Icon(mode.icon, size: 18, color: theme.primary),
                    const SizedBox(width: 8),
                    Text(
                      mode.label,
                      style: TextStyle(color: theme.primaryText),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (mode) {
              if (mode != null) {
                controller.setThemeMode(mode);
              }
            },
          ),
        ),
      );
    });
  }
}
