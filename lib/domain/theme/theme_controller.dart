import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences? _prefs;

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

/// Controller for managing app theme state.
/// Uses GetX for reactive state management and persists preference.
class ThemeController extends GetxController {
  static ThemeController get to => Get.find<ThemeController>();

  // ============================================
  // REACTIVE STATE
  // ============================================
  final Rx<AppThemeMode> _themeMode = AppThemeMode.system.obs;
  //final RxBool _isDarkMode = true.obs;
  final RxBool _isDarkMode = false.obs;

  // ============================================
  // GETTERS
  // ============================================
  
  /// Current theme mode setting (system, light, or dark)
  AppThemeMode get themeMode => _themeMode.value;
  
  /// Whether dark mode is currently active (computed from mode + system)
  bool get isDarkMode => _isDarkMode.value;
  
  /// Get the Flutter ThemeMode for GetMaterialApp
  ThemeMode get flutterThemeMode {
    switch (_themeMode.value) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  // ============================================
  // LIFECYCLE
  // ============================================
  
  @override
  void onInit() {
    super.onInit();
    _initPrefs();
    _loadSavedTheme();
    _updateIsDarkMode();
    
    // Listen to system theme changes
    final dispatcher = SchedulerBinding.instance.platformDispatcher;
    dispatcher.onPlatformBrightnessChanged = () {
      if (_themeMode.value == AppThemeMode.system) {
        _updateIsDarkMode();
      }
    };
  }

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ============================================
  // PUBLIC METHODS
  // ============================================
  
  /// Set the theme mode and persist it
  void setThemeMode(AppThemeMode mode) {
    _themeMode.value = mode;
    _saveTheme(mode);
    _updateIsDarkMode();
    
    // Update GetMaterialApp theme
    Get.changeThemeMode(flutterThemeMode);
  }

  /// Toggle between light and dark mode
  /// If currently on system, will switch to the opposite of system preference
  void toggleTheme() {
    if (_isDarkMode.value) {
      setThemeMode(AppThemeMode.light);
    } else {
      setThemeMode(AppThemeMode.dark);
    }
  }

  /// Cycle through theme modes: system -> light -> dark -> system
  void cycleThemeMode() {
    final currentIndex = AppThemeMode.values.indexOf(_themeMode.value);
    final nextIndex = (currentIndex + 1) % AppThemeMode.values.length;
    setThemeMode(AppThemeMode.values[nextIndex]);
  }

  // ============================================
  // PRIVATE METHODS
  // ============================================
  
  void _loadSavedTheme() {
    final savedTheme = _prefs?.getString(_kThemeKey);
    if (savedTheme != null) {
      try {
        _themeMode.value = AppThemeMode.values.firstWhere(
          (e) => e.name == savedTheme,
          orElse: () => AppThemeMode.system,
        );
      } catch (_) {
        _themeMode.value = AppThemeMode.system;
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
    switch (_themeMode.value) {
      case AppThemeMode.system:
        final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
        _isDarkMode.value = brightness == Brightness.dark;
        break;
      case AppThemeMode.light:
        _isDarkMode.value = false;
        break;
      case AppThemeMode.dark:
        _isDarkMode.value = true;
        break;
    }
  }
}

const String _kThemeKey = '__app_theme_mode__';
