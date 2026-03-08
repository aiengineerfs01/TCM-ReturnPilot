import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:tcm_return_pilot/domain/theme/app_colors.dart';

/// Abstract theme class that provides access to all theme colors.
/// Use `AppTheme.of(context)` to get the current theme colors.
abstract class AppTheme {
  // ============================================
  // STATIC ACCESSORS
  // ============================================

  /// Get the current theme based on context brightness
  static AppTheme of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? DarkModeTheme() : LightModeTheme();
  }

  /// Get current theme without context (uses platform brightness)
  static AppTheme get current {
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark ? DarkModeTheme() : LightModeTheme();
  }

  /// Check if current theme is dark
  static bool get isDark {
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }

  // ============================================
  // THEME DATA GENERATORS
  // ============================================

  /// Generate light theme data for MaterialApp
  static ThemeData get lightTheme {
    final colors = AppColors.light;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: colors.primary,
      scaffoldBackgroundColor: colors.scaffoldBackground,
      colorScheme: ColorScheme.light(
        primary: colors.primary,
        secondary: colors.secondary,
        tertiary: colors.tertiary,
        surface: colors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: colors.primaryText,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 2,
        shadowColor: colors.cardShadow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: colors.inputFill,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.inputFocusBorder, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
      ),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
      ),
      iconTheme: IconThemeData(
        color: colors.iconPrimary,
      ),
    );
  }

  /// Generate dark theme data for MaterialApp
  static ThemeData get darkTheme {
    final colors = AppColors.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: colors.primary,
      scaffoldBackgroundColor: colors.scaffoldBackground,
      colorScheme: ColorScheme.dark(
        primary: colors.primary,
        secondary: colors.secondary,
        tertiary: colors.tertiary,
        surface: colors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: colors.primaryText,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 2,
        shadowColor: colors.cardShadow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: colors.inputFill,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.inputFocusBorder, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
      ),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
      ),
      iconTheme: IconThemeData(
        color: colors.iconPrimary,
      ),
    );
  }

  // ============================================
  // ABSTRACT COLOR PROPERTIES
  // ============================================

  // Primary colors
  Color get primary;
  Color get primaryLight;
  Color get secondary;
  Color get tertiary;
  Color get alternate;

  // Background colors
  Color get primaryBackground;
  Color get secondaryBackground;
  Color get surface;
  Color get scaffoldBackground;

  // Text colors
  Color get primaryText;
  Color get secondaryText;
  Color get hintText;

  // Border colors
  Color get borderColor;
  Color get borderColor2;
  Color get divider;

  // Grey palette
  Color get grey1;
  Color get grey2;
  Color get grey3;
  Color get grey4;
  Color get grey5;
  Color get grey6;
  Color get grey7;
  Color get grey8;
  Color get darkGrey;
  Color get lightGrey;
  Color get lightGrey2;
  Color get lightGrey3;
  Color get lightGrey4;
  Color get greyColor;

  // Blue palette
  Color get blue;
  Color get blue1;
  Color get blue2;
  Color get darkBlue;
  Color get navyBlue;

  // Black palette
  Color get black1;
  Color get black2;
  Color get black3;

  // White palette
  Color get white2;

  // Green palette
  Color get green;
  Color get green1;
  Color get green2;
  Color get appGreen;

  // Yellow palette
  Color get yellow;
  Color get yellow2;
  Color get yellow3;

  // Red palette
  Color get red;
  Color get red2;
  Color get redColor2;
  Color get redColor3;

  // Status colors
  Color get success;
  Color get warning;
  Color get error;
  Color get info;

  // Accent colors
  Color get accent1;
  Color get accent2;
  Color get accent3;
  Color get accent4;

  // Button colors
  Color get uBUTTONyes;
  Color get uBUTTONno;
  Color get bBUTTONyes;
  Color get bBUTTONno;

  // Misc
  Color get transparent;
  Color get appColor;
  Color get backdrop;
  Color get navBarPressed;
  Color get appGrey;
  Color get everBlack;
  Color get appSecondary;

  // Card & Container
  Color get card;
  Color get cardShadow;

  // Input fields
  Color get inputFill;
  Color get inputBorder;
  Color get inputFocusBorder;

  // Icon colors
  Color get iconPrimary;
  Color get iconSecondary;

  // Typography
  Typography get typography => ThemeTypography(this);

  // Typography style shortcuts for convenience
  TextStyle get displayLarge => typography.displayLarge;
  TextStyle get displayMedium => typography.displayMedium;
  TextStyle get displaySmall => typography.displaySmall;
  TextStyle get headlineLarge => typography.headlineLarge;
  TextStyle get headlineMedium => typography.headlineMedium;
  TextStyle get headlineSmall => typography.headlineSmall;
  TextStyle get titleLarge => typography.titleLarge;
  TextStyle get titleMedium => typography.titleMedium;
  TextStyle get titleSmall => typography.titleSmall;
  TextStyle get labelLarge => typography.labelLarge;
  TextStyle get labelMedium => typography.labelMedium;
  TextStyle get labelSmall => typography.labelSmall;
  TextStyle get bodyLarge => typography.bodyLarge;
  TextStyle get bodyMedium => typography.bodyMedium;
  TextStyle get bodySmall => typography.bodySmall;
}

/// Light mode theme implementation
class LightModeTheme extends AppTheme {
  final _colors = AppColors.light;

  // Primary colors
  @override
  Color get primary => _colors.primary;
  @override
  Color get primaryLight => _colors.primaryLight;
  @override
  Color get secondary => _colors.secondary;
  @override
  Color get tertiary => _colors.tertiary;
  @override
  Color get alternate => _colors.alternate;

  // Background colors
  @override
  Color get primaryBackground => _colors.background;
  @override
  Color get secondaryBackground => _colors.secondaryBackground;
  @override
  Color get surface => _colors.surface;
  @override
  Color get scaffoldBackground => _colors.scaffoldBackground;

  // Text colors
  @override
  Color get primaryText => _colors.primaryText;
  @override
  Color get secondaryText => _colors.secondaryText;
  @override
  Color get hintText => _colors.hintText;

  // Border colors
  @override
  Color get borderColor => _colors.border;
  @override
  Color get borderColor2 => _colors.borderSecondary;
  @override
  Color get divider => _colors.divider;

  // Grey palette
  @override
  Color get grey1 => _colors.grey1;
  @override
  Color get grey2 => _colors.grey2;
  @override
  Color get grey3 => _colors.grey3;
  @override
  Color get grey4 => _colors.grey4;
  @override
  Color get grey5 => _colors.grey5;
  @override
  Color get grey6 => _colors.grey6;
  @override
  Color get grey7 => _colors.grey7;
  @override
  Color get grey8 => _colors.grey8;
  @override
  Color get darkGrey => _colors.darkGrey;
  @override
  Color get lightGrey => _colors.lightGrey;
  @override
  Color get lightGrey2 => _colors.lightGrey2;
  @override
  Color get lightGrey3 => _colors.lightGrey3;
  @override
  Color get lightGrey4 => _colors.lightGrey4;
  @override
  Color get greyColor => _colors.greyColor;

  // Blue palette
  @override
  Color get blue => _colors.blue;
  @override
  Color get blue1 => _colors.blue1;
  @override
  Color get blue2 => _colors.blue2;
  @override
  Color get darkBlue => _colors.darkBlue;
  @override
  Color get navyBlue => _colors.navyBlue;

  // Black palette
  @override
  Color get black1 => _colors.black1;
  @override
  Color get black2 => _colors.black2;
  @override
  Color get black3 => _colors.black3;

  // White palette
  @override
  Color get white2 => _colors.white2;

  // Green palette
  @override
  Color get green => _colors.green;
  @override
  Color get green1 => _colors.green1;
  @override
  Color get green2 => _colors.green2;
  @override
  Color get appGreen => _colors.appGreen;

  // Yellow palette
  @override
  Color get yellow => _colors.yellow;
  @override
  Color get yellow2 => _colors.yellow2;
  @override
  Color get yellow3 => _colors.yellow3;

  // Red palette
  @override
  Color get red => _colors.red;
  @override
  Color get red2 => _colors.red2;
  @override
  Color get redColor2 => _colors.redColor2;
  @override
  Color get redColor3 => _colors.redColor3;

  // Status colors
  @override
  Color get success => AppColors.success;
  @override
  Color get warning => AppColors.warning;
  @override
  Color get error => AppColors.error;
  @override
  Color get info => AppColors.info;

  // Accent colors
  @override
  Color get accent1 => _colors.accent1;
  @override
  Color get accent2 => _colors.accent2;
  @override
  Color get accent3 => _colors.accent3;
  @override
  Color get accent4 => _colors.accent4;

  // Button colors
  @override
  Color get uBUTTONyes => _colors.buttonYes;
  @override
  Color get uBUTTONno => _colors.buttonNo;
  @override
  Color get bBUTTONyes => _colors.buttonBlueYes;
  @override
  Color get bBUTTONno => _colors.buttonBlueNo;

  // Misc
  @override
  Color get transparent => AppColors.transparent;
  @override
  Color get appColor => _colors.appColor;
  @override
  Color get backdrop => _colors.backdrop;
  @override
  Color get navBarPressed => _colors.navBarPressed;
  @override
  Color get appGrey => _colors.appGrey;
  @override
  Color get everBlack => const Color(0xFF9B5926);
  @override
  Color get appSecondary => const Color(0xFF1F2C37);

  // Card & Container
  @override
  Color get card => _colors.card;
  @override
  Color get cardShadow => _colors.cardShadow;

  // Input fields
  @override
  Color get inputFill => _colors.inputFill;
  @override
  Color get inputBorder => _colors.inputBorder;
  @override
  Color get inputFocusBorder => _colors.inputFocusBorder;

  // Icon colors
  @override
  Color get iconPrimary => _colors.iconPrimary;
  @override
  Color get iconSecondary => _colors.iconSecondary;
}

/// Dark mode theme implementation
class DarkModeTheme extends AppTheme {
  final _colors = AppColors.dark;

  // Primary colors
  @override
  Color get primary => _colors.primary;
  @override
  Color get primaryLight => _colors.primaryLight;
  @override
  Color get secondary => _colors.secondary;
  @override
  Color get tertiary => _colors.tertiary;
  @override
  Color get alternate => _colors.alternate;

  // Background colors
  @override
  Color get primaryBackground => _colors.background;
  @override
  Color get secondaryBackground => _colors.secondaryBackground;
  @override
  Color get surface => _colors.surface;
  @override
  Color get scaffoldBackground => _colors.scaffoldBackground;

  // Text colors
  @override
  Color get primaryText => _colors.primaryText;
  @override
  Color get secondaryText => _colors.secondaryText;
  @override
  Color get hintText => _colors.hintText;

  // Border colors
  @override
  Color get borderColor => _colors.border;
  @override
  Color get borderColor2 => _colors.borderSecondary;
  @override
  Color get divider => _colors.divider;

  // Grey palette
  @override
  Color get grey1 => _colors.grey1;
  @override
  Color get grey2 => _colors.grey2;
  @override
  Color get grey3 => _colors.grey3;
  @override
  Color get grey4 => _colors.grey4;
  @override
  Color get grey5 => _colors.grey5;
  @override
  Color get grey6 => _colors.grey6;
  @override
  Color get grey7 => _colors.grey7;
  @override
  Color get grey8 => _colors.grey8;
  @override
  Color get darkGrey => _colors.darkGrey;
  @override
  Color get lightGrey => _colors.lightGrey;
  @override
  Color get lightGrey2 => _colors.lightGrey2;
  @override
  Color get lightGrey3 => _colors.lightGrey3;
  @override
  Color get lightGrey4 => _colors.lightGrey4;
  @override
  Color get greyColor => _colors.greyColor;

  // Blue palette
  @override
  Color get blue => _colors.blue;
  @override
  Color get blue1 => _colors.blue1;
  @override
  Color get blue2 => _colors.blue2;
  @override
  Color get darkBlue => _colors.darkBlue;
  @override
  Color get navyBlue => _colors.navyBlue;

  // Black palette
  @override
  Color get black1 => _colors.black1;
  @override
  Color get black2 => _colors.black2;
  @override
  Color get black3 => _colors.black3;

  // White palette
  @override
  Color get white2 => _colors.white2;

  // Green palette
  @override
  Color get green => _colors.green;
  @override
  Color get green1 => _colors.green1;
  @override
  Color get green2 => _colors.green2;
  @override
  Color get appGreen => _colors.appGreen;

  // Yellow palette
  @override
  Color get yellow => _colors.yellow;
  @override
  Color get yellow2 => _colors.yellow2;
  @override
  Color get yellow3 => _colors.yellow3;

  // Red palette
  @override
  Color get red => _colors.red;
  @override
  Color get red2 => _colors.red2;
  @override
  Color get redColor2 => _colors.redColor2;
  @override
  Color get redColor3 => _colors.redColor3;

  // Status colors
  @override
  Color get success => AppColors.success;
  @override
  Color get warning => AppColors.warning;
  @override
  Color get error => AppColors.error;
  @override
  Color get info => AppColors.info;

  // Accent colors
  @override
  Color get accent1 => _colors.accent1;
  @override
  Color get accent2 => _colors.accent2;
  @override
  Color get accent3 => _colors.accent3;
  @override
  Color get accent4 => _colors.accent4;

  // Button colors
  @override
  Color get uBUTTONyes => _colors.buttonYes;
  @override
  Color get uBUTTONno => _colors.buttonNo;
  @override
  Color get bBUTTONyes => _colors.buttonBlueYes;
  @override
  Color get bBUTTONno => _colors.buttonBlueNo;

  // Misc
  @override
  Color get transparent => AppColors.transparent;
  @override
  Color get appColor => _colors.appColor;
  @override
  Color get backdrop => _colors.backdrop;
  @override
  Color get navBarPressed => _colors.navBarPressed;
  @override
  Color get appGrey => _colors.appGrey;
  @override
  Color get everBlack => const Color(0xFF9B5926);
  @override
  Color get appSecondary => const Color(0xFFD9D9D9);

  // Card & Container
  @override
  Color get card => _colors.card;
  @override
  Color get cardShadow => _colors.cardShadow;

  // Input fields
  @override
  Color get inputFill => _colors.inputFill;
  @override
  Color get inputBorder => _colors.inputBorder;
  @override
  Color get inputFocusBorder => _colors.inputFocusBorder;

  // Icon colors
  @override
  Color get iconPrimary => _colors.iconPrimary;
  @override
  Color get iconSecondary => _colors.iconSecondary;
}

// ============================================
// TYPOGRAPHY
// ============================================

abstract class Typography {
  String get displayLargeFamily;
  TextStyle get displayLarge;
  String get displayMediumFamily;
  TextStyle get displayMedium;
  String get displaySmallFamily;
  TextStyle get displaySmall;
  String get headlineLargeFamily;
  TextStyle get headlineLarge;
  String get headlineMediumFamily;
  TextStyle get headlineMedium;
  String get headlineSmallFamily;
  TextStyle get headlineSmall;
  String get titleLargeFamily;
  TextStyle get titleLarge;
  String get titleMediumFamily;
  TextStyle get titleMedium;
  String get titleSmallFamily;
  TextStyle get titleSmall;
  String get labelLargeFamily;
  TextStyle get labelLarge;
  String get labelMediumFamily;
  TextStyle get labelMedium;
  String get labelSmallFamily;
  TextStyle get labelSmall;
  String get bodyLargeFamily;
  TextStyle get bodyLarge;
  String get bodyMediumFamily;
  TextStyle get bodyMedium;
  String get bodySmallFamily;
  TextStyle get bodySmall;
}

class ThemeTypography extends Typography {
  ThemeTypography(this.theme);

  final AppTheme theme;
  static const String _fontFamily = 'Poppins';

  @override
  String get displayLargeFamily => _fontFamily;
  @override
  TextStyle get displayLarge => TextStyle(
        fontFamily: _fontFamily,
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
        fontSize: 50.0,
      );

  @override
  String get displayMediumFamily => _fontFamily;
  @override
  TextStyle get displayMedium => TextStyle(
        fontFamily: _fontFamily,
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 44.0,
      );

  @override
  String get displaySmallFamily => _fontFamily;
  @override
  TextStyle get displaySmall => TextStyle(
        fontFamily: _fontFamily,
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 36.0,
      );

  @override
  String get headlineLargeFamily => _fontFamily;
  @override
  TextStyle get headlineLarge => TextStyle(
        fontFamily: _fontFamily,
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 32.0,
      );

  @override
  String get headlineMediumFamily => _fontFamily;
  @override
  TextStyle get headlineMedium => TextStyle(
        fontFamily: _fontFamily,
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 28.0,
      );

  @override
  String get headlineSmallFamily => _fontFamily;
  @override
  TextStyle get headlineSmall => TextStyle(
        fontFamily: _fontFamily,
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 24.0,
      );

  @override
  String get titleLargeFamily => _fontFamily;
  @override
  TextStyle get titleLarge => TextStyle(
        fontFamily: _fontFamily,
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 22.0,
      );

  @override
  String get titleMediumFamily => _fontFamily;
  @override
  TextStyle get titleMedium => TextStyle(
        fontFamily: _fontFamily,
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 18.0,
      );

  @override
  String get titleSmallFamily => _fontFamily;
  @override
  TextStyle get titleSmall => TextStyle(
        fontFamily: _fontFamily,
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 17.0,
      );

  @override
  String get labelLargeFamily => _fontFamily;
  @override
  TextStyle get labelLarge => TextStyle(
        fontFamily: _fontFamily,
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 16.0,
      );

  @override
  String get labelMediumFamily => _fontFamily;
  @override
  TextStyle get labelMedium => TextStyle(
        fontFamily: _fontFamily,
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 15.0,
      );

  @override
  String get labelSmallFamily => _fontFamily;
  @override
  TextStyle get labelSmall => TextStyle(
        fontFamily: _fontFamily,
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 14.0,
      );

  @override
  String get bodyLargeFamily => _fontFamily;
  @override
  TextStyle get bodyLarge => TextStyle(
        fontFamily: _fontFamily,
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 13.0,
      );

  @override
  String get bodyMediumFamily => _fontFamily;
  @override
  TextStyle get bodyMedium => TextStyle(
        fontFamily: _fontFamily,
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 12.0,
      );

  @override
  String get bodySmallFamily => _fontFamily;
  @override
  TextStyle get bodySmall => TextStyle(
        fontFamily: _fontFamily,
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 11.0,
      );
}

// ============================================
// TEXT STYLE EXTENSION
// ============================================

extension TextStyleHelper on TextStyle {
  TextStyle override({
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? lineHeight,
    List<Shadow>? shadows,
  }) {
    return copyWith(
      fontFamily: fontFamily,
      color: color,
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
      height: lineHeight,
      shadows: shadows,
    );
  }
}
