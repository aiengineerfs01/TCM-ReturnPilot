import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcm_return_pilot/constants/typography.dart';

const kThemeModeKey = '__theme_mode__';

SharedPreferences? _prefs;

abstract class AppTheme {
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();

  static ThemeMode get themeMode {
    final darkMode = _prefs?.getBool(kThemeModeKey);
    return darkMode == null
        ? ThemeMode.system
        : darkMode
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  static void saveThemeMode(ThemeMode mode) => mode == ThemeMode.system
      ? _prefs?.remove(kThemeModeKey)
      : _prefs?.setBool(kThemeModeKey, mode == ThemeMode.dark);

  static AppTheme of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkModeTheme()
        : LightModeTheme();
  }

  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary;
  late Color secondary;
  late Color tertiary;
  late Color alternate;
  late Color primaryText;
  late Color secondaryText;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color borderColor;
  late Color borderColor2;
  late Color appSecondary;
  late Color accent1;
  late Color accent2;
  late Color accent3;
  late Color accent4;
  late Color success;
  late Color warning;
  late Color error;
  late Color info;

  late Color uBUTTONyes;
  late Color uBUTTONno;
  late Color bBUTTONyes;
  late Color bBUTTONno;
  late Color transparent;
  late Color appColor;
  late Color everBlack;
  late Color backdropBack;
  late Color navBarPressed;

  @Deprecated('Use displaySmallFamily instead')
  String get title1Family => displaySmallFamily;
  @Deprecated('Use displaySmall instead')
  TextStyle get title1 => typography.displaySmall;
  @Deprecated('Use headlineMediumFamily instead')
  String get title2Family => typography.headlineMediumFamily;
  @Deprecated('Use headlineMedium instead')
  TextStyle get title2 => typography.headlineMedium;
  @Deprecated('Use headlineSmallFamily instead')
  String get title3Family => typography.headlineSmallFamily;
  @Deprecated('Use headlineSmall instead')
  TextStyle get title3 => typography.headlineSmall;
  @Deprecated('Use titleMediumFamily instead')
  String get subtitle1Family => typography.titleMediumFamily;
  @Deprecated('Use titleMedium instead')
  TextStyle get subtitle1 => typography.titleMedium;
  @Deprecated('Use titleSmallFamily instead')
  String get subtitle2Family => typography.titleSmallFamily;
  @Deprecated('Use titleSmall instead')
  TextStyle get subtitle2 => typography.titleSmall;
  @Deprecated('Use bodyMediumFamily instead')
  String get bodyText1Family => typography.bodyMediumFamily;
  @Deprecated('Use bodyMedium instead')
  TextStyle get bodyText1 => typography.bodyMedium;
  @Deprecated('Use bodySmallFamily instead')
  String get bodyText2Family => typography.bodySmallFamily;
  @Deprecated('Use bodySmall instead')
  TextStyle get bodyText2 => typography.bodySmall;

  String get displayLargeFamily => typography.displayLargeFamily;
  bool get displayLargeIsCustom => typography.displayLargeIsCustom;
  TextStyle get displayLarge => typography.displayLarge;
  String get displayMediumFamily => typography.displayMediumFamily;
  bool get displayMediumIsCustom => typography.displayMediumIsCustom;
  TextStyle get displayMedium => typography.displayMedium;
  String get displaySmallFamily => typography.displaySmallFamily;
  bool get displaySmallIsCustom => typography.displaySmallIsCustom;
  TextStyle get displaySmall => typography.displaySmall;
  String get headlineLargeFamily => typography.headlineLargeFamily;
  bool get headlineLargeIsCustom => typography.headlineLargeIsCustom;
  TextStyle get headlineLarge => typography.headlineLarge;
  String get headlineMediumFamily => typography.headlineMediumFamily;
  bool get headlineMediumIsCustom => typography.headlineMediumIsCustom;
  TextStyle get headlineMedium => typography.headlineMedium;
  String get headlineSmallFamily => typography.headlineSmallFamily;
  bool get headlineSmallIsCustom => typography.headlineSmallIsCustom;
  TextStyle get headlineSmall => typography.headlineSmall;
  String get titleLargeFamily => typography.titleLargeFamily;
  bool get titleLargeIsCustom => typography.titleLargeIsCustom;
  TextStyle get titleLarge => typography.titleLarge;
  String get titleMediumFamily => typography.titleMediumFamily;
  bool get titleMediumIsCustom => typography.titleMediumIsCustom;
  TextStyle get titleMedium => typography.titleMedium;
  String get titleSmallFamily => typography.titleSmallFamily;
  bool get titleSmallIsCustom => typography.titleSmallIsCustom;
  TextStyle get titleSmall => typography.titleSmall;
  String get labelLargeFamily => typography.labelLargeFamily;
  bool get labelLargeIsCustom => typography.labelLargeIsCustom;
  TextStyle get labelLarge => typography.labelLarge;
  String get labelMediumFamily => typography.labelMediumFamily;
  bool get labelMediumIsCustom => typography.labelMediumIsCustom;
  TextStyle get labelMedium => typography.labelMedium;
  String get labelSmallFamily => typography.labelSmallFamily;
  bool get labelSmallIsCustom => typography.labelSmallIsCustom;
  TextStyle get labelSmall => typography.labelSmall;
  String get bodyLargeFamily => typography.bodyLargeFamily;
  bool get bodyLargeIsCustom => typography.bodyLargeIsCustom;
  TextStyle get bodyLarge => typography.bodyLarge;
  String get bodyMediumFamily => typography.bodyMediumFamily;
  bool get bodyMediumIsCustom => typography.bodyMediumIsCustom;
  TextStyle get bodyMedium => typography.bodyMedium;
  String get bodySmallFamily => typography.bodySmallFamily;
  bool get bodySmallIsCustom => typography.bodySmallIsCustom;
  TextStyle get bodySmall => typography.bodySmall;

  Typography get typography => ThemeTypography(this);
}

class LightModeTheme extends AppTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary = const Color(0xFF2A5298);
  late Color secondary = const Color(0xFF5CC1B4);
  late Color tertiary = const Color(0xFFEE8B60);
  late Color alternate = const Color(0xFFE0E3E7);
  late Color primaryText = const Color(0xFF212021);
  late Color secondaryText = const Color(0xFFACACAC);
  late Color primaryBackground = const Color(0xFFF6F6F6);
  late Color secondaryBackground = const Color(0xFFFFFFFF);
  late Color borderColor = const Color(0xFFE3E9ED);
  late Color borderColor2 = const Color(0xFFECF1F6);
  late Color appSecondary = const Color(0xFF1F2C37);
  late Color accent1 = const Color(0xFFEBEBEB);
  late Color accent2 = const Color(0xFFB2B2B2);
  late Color accent3 = const Color(0x7C000000);
  late Color accent4 = const Color(0xFF1F92ED);
  late Color success = const Color(0xFF4CAE52);
  late Color warning = const Color(0xFFFC991F);
  late Color error = const Color(0xFFF45252);
  late Color info = const Color(0xFF1C4494);

  late Color uBUTTONyes = const Color(0xFF47B57B);
  late Color uBUTTONno = const Color(0xFFCEC6EB);
  late Color bBUTTONyes = const Color(0xFF0092D3);
  late Color bBUTTONno = const Color(0xFF21CDAD);
  late Color transparent = const Color(0x3A584668);
  late Color appColor = const Color(0xFF64862E);
  late Color everBlack = const Color(0xFF9B5926);
  late Color backdropBack = const Color(0xFF919151);
  late Color navBarPressed = const Color(0xFFACACAC);
}

abstract class Typography {
  String get displayLargeFamily;
  bool get displayLargeIsCustom;
  TextStyle get displayLarge;
  String get displayMediumFamily;
  bool get displayMediumIsCustom;
  TextStyle get displayMedium;
  String get displaySmallFamily;
  bool get displaySmallIsCustom;
  TextStyle get displaySmall;
  String get headlineLargeFamily;
  bool get headlineLargeIsCustom;
  TextStyle get headlineLarge;
  String get headlineMediumFamily;
  bool get headlineMediumIsCustom;
  TextStyle get headlineMedium;
  String get headlineSmallFamily;
  bool get headlineSmallIsCustom;
  TextStyle get headlineSmall;
  String get titleLargeFamily;
  bool get titleLargeIsCustom;
  TextStyle get titleLarge;
  String get titleMediumFamily;
  bool get titleMediumIsCustom;
  TextStyle get titleMedium;
  String get titleSmallFamily;
  bool get titleSmallIsCustom;
  TextStyle get titleSmall;
  String get labelLargeFamily;
  bool get labelLargeIsCustom;
  TextStyle get labelLarge;
  String get labelMediumFamily;
  bool get labelMediumIsCustom;
  TextStyle get labelMedium;
  String get labelSmallFamily;
  bool get labelSmallIsCustom;
  TextStyle get labelSmall;
  String get bodyLargeFamily;
  bool get bodyLargeIsCustom;
  TextStyle get bodyLarge;
  String get bodyMediumFamily;
  bool get bodyMediumIsCustom;
  TextStyle get bodyMedium;
  String get bodySmallFamily;
  bool get bodySmallIsCustom;
  TextStyle get bodySmall;
}

class ThemeTypography extends Typography {
  ThemeTypography(this.theme);

  final AppTheme theme;

  String get displayLargeFamily => 'Fotolito';
  bool get displayLargeIsCustom => true;
  TextStyle get displayLarge => TextStyle(
    fontFamily: 'Fotolito',
    color: theme.primaryText,
    fontWeight: FontWeight.bold,
    fontSize: 50.0,
  );
  String get displayMediumFamily => 'Fotolito';
  bool get displayMediumIsCustom => true;
  TextStyle get displayMedium => TextStyle(
    fontFamily: 'Fotolito',
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 44.0,
  );
  String get displaySmallFamily => 'Fotolito';
  bool get displaySmallIsCustom => true;
  TextStyle get displaySmall => TextStyle(
    fontFamily: 'Fotolito',
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 36.0,
  );
  String get headlineLargeFamily => 'Fotolito';
  bool get headlineLargeIsCustom => true;
  TextStyle get headlineLarge => TextStyle(
    fontFamily: 'Fotolito',
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 32.0,
  );
  String get headlineMediumFamily => 'Fotolito';
  bool get headlineMediumIsCustom => true;
  TextStyle get headlineMedium => TextStyle(
    fontFamily: 'Fotolito',
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 28.0,
  );
  String get headlineSmallFamily => 'Fotolito';
  bool get headlineSmallIsCustom => true;
  TextStyle get headlineSmall => TextStyle(
    fontFamily: 'Fotolito',
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 24.0,
  );
  String get titleLargeFamily => 'Fotolito';
  bool get titleLargeIsCustom => true;
  TextStyle get titleLarge => TextStyle(
    fontFamily: 'Fotolito',
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 22.0,
  );
  String get titleMediumFamily => 'Fotolito';
  bool get titleMediumIsCustom => true;
  TextStyle get titleMedium => TextStyle(
    fontFamily: 'Fotolito',
    color: theme.primaryText,
    fontWeight: FontWeight.w600,
    fontSize: 18.0,
  );
  String get titleSmallFamily => 'Fotolito';
  bool get titleSmallIsCustom => true;
  TextStyle get titleSmall => TextStyle(
    fontFamily: 'Fotolito',
    color: theme.primaryText,
    fontWeight: FontWeight.w500,
    fontSize: 17.0,
  );
  String get labelLargeFamily => 'Fotolito';
  bool get labelLargeIsCustom => true;
  TextStyle get labelLarge => TextStyle(
    fontFamily: 'Fotolito',
    color: theme.primaryText,
    fontWeight: FontWeight.normal,
    fontSize: 16.0,
  );
  String get labelMediumFamily => 'Fotolito';
  bool get labelMediumIsCustom => true;
  TextStyle get labelMedium => TextStyle(
    fontFamily: 'Fotolito',
    color: theme.primaryText,
    fontWeight: FontWeight.normal,
    fontSize: 15.0,
  );
  String get labelSmallFamily => 'Fotolito';
  bool get labelSmallIsCustom => true;
  TextStyle get labelSmall => TextStyle(
    fontFamily: 'Fotolito',
    color: theme.primaryText,
    fontWeight: FontWeight.normal,
    fontSize: 14.0,
  );
  String get bodyLargeFamily => 'Fotolito';
  bool get bodyLargeIsCustom => true;
  TextStyle get bodyLarge => TextStyle(
    fontFamily: 'Fotolito',
    color: theme.primaryText,
    fontWeight: FontWeight.normal,
    fontSize: 13.0,
  );
  String get bodyMediumFamily => 'Fotolito';
  bool get bodyMediumIsCustom => true;
  TextStyle get bodyMedium => TextStyle(
    fontFamily: 'Fotolito',
    color: theme.primaryText,
    fontWeight: FontWeight.normal,
    fontSize: 12.0,
  );
  String get bodySmallFamily => 'Fotolito';
  bool get bodySmallIsCustom => true;
  TextStyle get bodySmall => TextStyle(
    fontFamily: 'Fotolito',
    color: theme.primaryText,
    fontWeight: FontWeight.normal,
    fontSize: 11.0,
  );
}

class DarkModeTheme extends AppTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary = const Color(0xFFAAC811);
  late Color secondary = const Color(0xFF4A4A4A);
  late Color tertiary = const Color(0xFF0092D3);
  late Color alternate = const Color(0xFF262D34);
  late Color primaryText = const Color(0xFFFFFFFF);
  late Color secondaryText = const Color(0xFFACACAC);
  late Color primaryBackground = const Color(0xFF25272C);
  late Color secondaryBackground = const Color(0xFF191A1F);
  late Color borderColor = const Color(0xFFE3E9ED);
  late Color borderColor2 = const Color(0xFFECF1F6);
  late Color appSecondary = const Color(0xFF1F2C37);
  late Color accent1 = const Color(0xFF393C43);
  late Color accent2 = const Color(0xFF737373);
  late Color accent3 = const Color(0x7C000000);
  late Color accent4 = const Color(0xFF1F92ED);
  late Color success = const Color(0xFF4CAE52);
  late Color warning = const Color(0xFFFC991F);
  late Color error = const Color(0xFFF45252);
  late Color info = const Color(0xFF1C4494);

  late Color uBUTTONyes = const Color(0xFF89A00E);
  late Color uBUTTONno = const Color(0xFF5D5D5D);
  late Color bBUTTONyes = const Color(0xFF0092D3);
  late Color bBUTTONno = const Color(0xFF5D5D5D);
  late Color transparent = const Color(0x3AFFFFFF);
  late Color appColor = const Color(0xFF64862E);
  late Color everBlack = const Color(0xFF9B5926);
  late Color backdropBack = const Color(0xFF4A4A4A);
  late Color navBarPressed = const Color(0xFFACACAC);
}

extension TextStyleHelper on TextStyle {
  TextStyle override({
    TextStyle? font,
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    bool useGoogleFonts = false,
    TextDecoration? decoration,
    double? lineHeight,
    List<Shadow>? shadows,
    String? package,
  }) {
    if (useGoogleFonts && fontFamily != null) {
      font = poppinsSemiBold.copyWith(
        fontFamily: fontFamily,
        fontWeight: fontWeight ?? this.fontWeight,
        fontStyle: fontStyle ?? this.fontStyle,
      );
    }

    return font != null
        ? font.copyWith(
            color: color ?? this.color,
            fontSize: fontSize ?? this.fontSize,
            letterSpacing: letterSpacing ?? this.letterSpacing,
            fontWeight: fontWeight ?? this.fontWeight,
            fontStyle: fontStyle ?? this.fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          )
        : copyWith(
            fontFamily: fontFamily,
            package: package,
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
