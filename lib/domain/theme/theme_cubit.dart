import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =============================================================================
// Theme Mode Enum
// =============================================================================

/// Theme mode options
enum AppThemeMode {
  system,
  light,
  dark;

  String get label {
    switch (this) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }

  IconData get icon {
    switch (this) {
      case AppThemeMode.system:
        return Icons.brightness_auto_rounded;
      case AppThemeMode.light:
        return Icons.light_mode_rounded;
      case AppThemeMode.dark:
        return Icons.dark_mode_rounded;
    }
  }
}

// =============================================================================
// Theme State
// =============================================================================

class ThemeState {
  final AppThemeMode themeMode;
  final bool isDarkMode;

  const ThemeState({
    this.themeMode = AppThemeMode.system,
    this.isDarkMode = false,
  });

  ThemeState copyWith({
    AppThemeMode? themeMode,
    bool? isDarkMode,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  /// Get the Flutter ThemeMode for MaterialApp.router / MaterialApp
  ThemeMode get flutterThemeMode {
    switch (themeMode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}

// =============================================================================
// Theme Cubit
// =============================================================================

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState()) {
    _init();
  }

  static const String _kThemeKey = '__app_theme_mode__';
  SharedPreferences? _prefs;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  Future<void> _init() async {
    await _initPrefs();
    _loadSavedTheme();
    _updateIsDarkMode();

    // Listen to system theme changes
    final dispatcher = SchedulerBinding.instance.platformDispatcher;
    dispatcher.onPlatformBrightnessChanged = () {
      if (state.themeMode == AppThemeMode.system) {
        _updateIsDarkMode();
      }
    };
  }

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ---------------------------------------------------------------------------
  // Public Methods
  // ---------------------------------------------------------------------------

  /// Set the theme mode and persist it
  void setThemeMode(AppThemeMode mode) {
    _saveTheme(mode);
    _updateIsDarkModeForMode(mode);
  }

  /// Toggle between light and dark mode.
  /// If currently on system, switches to the opposite of system preference.
  void toggleTheme() {
    if (state.isDarkMode) {
      setThemeMode(AppThemeMode.light);
    } else {
      setThemeMode(AppThemeMode.dark);
    }
  }

  /// Cycle through theme modes: system -> light -> dark -> system
  void cycleThemeMode() {
    final currentIndex = AppThemeMode.values.indexOf(state.themeMode);
    final nextIndex = (currentIndex + 1) % AppThemeMode.values.length;
    setThemeMode(AppThemeMode.values[nextIndex]);
  }

  // ---------------------------------------------------------------------------
  // Private Methods
  // ---------------------------------------------------------------------------

  void _loadSavedTheme() {
    final savedTheme = _prefs?.getString(_kThemeKey);
    if (savedTheme != null) {
      try {
        final mode = AppThemeMode.values.firstWhere(
          (e) => e.name == savedTheme,
          orElse: () => AppThemeMode.system,
        );
        emit(state.copyWith(themeMode: mode));
      } catch (_) {
        emit(state.copyWith(themeMode: AppThemeMode.system));
      }
    }
  }

  void _saveTheme(AppThemeMode mode) {
    if (mode == AppThemeMode.system) {
      _prefs?.remove(_kThemeKey);
    } else {
      _prefs?.setString(_kThemeKey, mode.name);
    }
  }

  void _updateIsDarkMode() {
    _updateIsDarkModeForMode(state.themeMode);
  }

  void _updateIsDarkModeForMode(AppThemeMode mode) {
    bool isDark;
    switch (mode) {
      case AppThemeMode.system:
        final brightness =
            SchedulerBinding.instance.platformDispatcher.platformBrightness;
        isDark = brightness == Brightness.dark;
        break;
      case AppThemeMode.light:
        isDark = false;
        break;
      case AppThemeMode.dark:
        isDark = true;
        break;
    }
    emit(state.copyWith(themeMode: mode, isDarkMode: isDark));
  }
}
