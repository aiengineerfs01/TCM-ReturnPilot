import 'package:flutter/material.dart';

/// Centralized color definitions for the app.
/// Contains both light and dark mode color palettes.
abstract class AppColors {
  // ============================================
  // LIGHT MODE COLORS
  // ============================================
  static const light = _LightColors();

  // ============================================
  // DARK MODE COLORS
  // ============================================
  static const dark = _DarkColors();

  // ============================================
  // SHARED COLORS (same in both themes)
  // ============================================
  static const Color transparent = Colors.transparent;
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Status colors (consistent across themes)
  static const Color success = Color(0xFF12B76A);
  static const Color warning = Color(0xFFFEB739);
  static const Color error = Color(0xFFDE3024);
  static const Color info = Color(0xFF1C4494);

  // Brand colors
  static const Color mintGreen = Color(0xFF00BD57);
  static const Color purple = Color(0xFF9D43B6);
}

/// Light mode color palette
class _LightColors {
  const _LightColors();

  // Primary colors
  Color get primary => const Color(0xFF0B2D6C);
  Color get primaryLight => const Color(0xFF123474);
  Color get secondary => const Color(0xFF5CC1B4);
  Color get tertiary => const Color(0xFFEE8B60);
  Color get alternate => const Color(0xFFE0E3E7);

  // Background colors
  Color get background => const Color(0xFFFDFDFD);
  Color get secondaryBackground => const Color(0xFFFFFFFF);
  Color get surface => const Color(0xFFFFFFFF);
  Color get scaffoldBackground => const Color(0xFFFFFFFF);

  // Text colors
  Color get primaryText => const Color(0xFF212021);
  Color get secondaryText => const Color(0xFF78828A);
  Color get hintText => const Color(0xFFACACAC);

  // Border colors
  Color get border => const Color(0xFFE3E9ED);
  Color get borderSecondary => const Color(0xFFECF1F6);
  Color get divider => const Color(0xFFD0D5DD);

  // Grey palette
  Color get grey1 => const Color(0xFFEDEDF1);
  Color get grey2 => const Color(0xFF8A91A6);
  Color get grey3 => const Color(0xFFD0D5DD);
  Color get grey4 => const Color(0xFF6C748B);
  Color get grey5 => const Color(0xFFD7D9E0);
  Color get grey6 => const Color(0xFF575D72);
  Color get grey7 => const Color(0xFFB4B9C5);
  Color get grey8 => const Color(0xFFF6F7F9);
  Color get grey9 => const Color(0xFFD9D9D9);
  Color get darkGrey => const Color(0xFF8F8F8F);
  Color get lightGrey => const Color(0xFFD2D2D2);
  Color get lightGrey2 => const Color(0xFFF5F7F9);
  Color get lightGrey3 => const Color(0xFFBCBDD2);
  Color get lightGrey4 => const Color(0xFFF1F2F4);
  Color get greyColor => const Color(0xFF707070);

  // Blue palette
  Color get blue => const Color(0xFF1e3c72);
  Color get blue1 => const Color(0xFFE6EEF8);
  Color get blue2 => const Color(0xFFF3F6FC);
  Color get darkBlue => const Color(0xFF091A38);
  Color get navyBlue => const Color(0xFF091A38);

  // Black palette
  Color get black1 => const Color(0xFF1F1F1F);
  Color get black2 => const Color(0xFF3D414F);
  Color get black3 => const Color(0xFF474C5D);

  // White palette
  Color get white2 => const Color(0xFFF6F6F6);

  // Green palette
  Color get green => const Color(0xFF12B76A);
  Color get green1 => const Color(0xFFD1FADF);
  Color get green2 => const Color(0xFF079455);
  Color get appGreen => const Color(0xFF00A38C);

  // Yellow palette
  Color get yellow => const Color(0xFFFEB739);
  Color get yellow2 => const Color(0xFFD0AA25);
  Color get yellow3 => const Color(0xFFF6EDCC);

  // Red palette
  Color get red => const Color(0xFFDE3024);
  Color get red2 => const Color(0xFFFEE4E2);
  Color get redColor2 => const Color(0xFFCF0210);
  Color get redColor3 => const Color(0xFFFF3932);

  // Accent colors
  Color get accent1 => const Color(0xFFEBEBEB);
  Color get accent2 => const Color(0xFFB2B2B2);
  Color get accent3 => const Color(0x7C000000);
  Color get accent4 => const Color(0xFF1F92ED);

  // Button colors
  Color get buttonYes => const Color(0xFF47B57B);
  Color get buttonNo => const Color(0xFFCEC6EB);
  Color get buttonBlueYes => const Color(0xFF0092D3);
  Color get buttonBlueNo => const Color(0xFF21CDAD);

  // Misc
  Color get appColor => const Color(0xFF64862E);
  Color get backdrop => const Color(0xFF919151);
  Color get navBarPressed => const Color(0xFFACACAC);
  Color get appGrey => const Color(0xFFD9D9D9);

  // Card & Container
  Color get card => const Color(0xFFFFFFFF);
  Color get cardShadow => const Color(0x0D000000);

  // Input fields
  Color get inputFill => const Color(0xFFF5F7F9);
  Color get inputBorder => const Color(0xFFE3E9ED);
  Color get inputFocusBorder => const Color(0xFF0B2D6C);

  // Icon colors
  Color get iconPrimary => const Color(0xFF0B2D6C);
  Color get iconSecondary => const Color(0xFF78828A);
}

/// Dark mode color palette
class _DarkColors {
  const _DarkColors();

  // Primary colors
  Color get primary => const Color(0xFF0B2D6C);
  //Color get primaryLight => const Color(0xFF5BA3E8);
  Color get primaryLight => const Color(0xFF123474);
  Color get secondary => const Color(0xFF5CC1B4);
  Color get tertiary => const Color(0xFFEE8B60);
  Color get alternate => const Color(0xFF262D34);

  // Background colors
  Color get background => const Color(0xFF121417);
  Color get secondaryBackground => const Color(0xFF1A1D21);
  Color get surface => const Color(0xFF1E2228);
  Color get scaffoldBackground => const Color(0xFF121417);

  // Text colors
  Color get primaryText => const Color(0xFFFFFFFF);
  Color get secondaryText => const Color(0xFFB0B0B0);
  Color get hintText => const Color(0xFF6B6B6B);

  // Border colors
  Color get border => const Color(0xFF2E3338);
  Color get borderSecondary => const Color(0xFF3A3F45);
  Color get divider => const Color(0xFF3A3F45);

  // Grey palette
  Color get grey1 => const Color(0xFF2E3338);
  Color get grey2 => const Color(0xFF8A91A6);
  Color get grey3 => const Color(0xFF4A5058);
  Color get grey4 => const Color(0xFF9BA3B0);
  Color get grey5 => const Color(0xFF3A4048);
  Color get grey6 => const Color(0xFFB0B5C0);
  Color get grey7 => const Color(0xFF5A6068);
  Color get grey8 => const Color(0xFF1E2228);
  Color get darkGrey => const Color(0xFF6B6B6B);
  Color get lightGrey => const Color(0xFF4A4A4A);
  Color get lightGrey2 => const Color(0xFF2A2D32);
  Color get lightGrey3 => const Color(0xFF5A5E68);
  Color get lightGrey4 => const Color(0xFF252830);
  Color get greyColor => const Color(0xFF909090);

  // Blue palette
  Color get blue => const Color(0xFF4A7AB8);
  Color get blue1 => const Color(0xFF1E2A38);
  Color get blue2 => const Color(0xFF1A2430);
  Color get darkBlue => const Color(0xFFB0C0D0);
  Color get navyBlue => const Color(0xFF2A3A50);

  // Black palette (inverted for dark mode)
  Color get black1 => const Color(0xFFE0E0E0);
  Color get black2 => const Color(0xFFC0C5D0);
  Color get black3 => const Color(0xFFB8BDC8);

  // White palette (inverted for dark mode)
  Color get white2 => const Color(0xFF1E2228);

  // Green palette
  Color get green => const Color(0xFF12B76A);
  Color get green1 => const Color(0xFF1A3028);
  Color get green2 => const Color(0xFF10A050);
  Color get appGreen => const Color(0xFF00A38C);

  // Yellow palette
  Color get yellow => const Color(0xFFFEB739);
  Color get yellow2 => const Color(0xFFD0AA25);
  Color get yellow3 => const Color(0xFF2A2818);

  // Red palette
  Color get red => const Color(0xFFDE3024);
  Color get red2 => const Color(0xFF3A1A18);
  Color get redColor2 => const Color(0xFFCF0210);
  Color get redColor3 => const Color(0xFFFF3932);

  // Accent colors
  Color get accent1 => const Color(0xFF2E3338);
  Color get accent2 => const Color(0xFF606060);
  Color get accent3 => const Color(0x7CFFFFFF);
  Color get accent4 => const Color(0xFF1F92ED);

  // Button colors
  Color get buttonYes => const Color(0xFF47B57B);
  Color get buttonNo => const Color(0xFF4A4A50);
  Color get buttonBlueYes => const Color(0xFF0092D3);
  Color get buttonBlueNo => const Color(0xFF4A5058);

  // Misc
  Color get appColor => const Color(0xFF7A9A40);
  Color get backdrop => const Color(0xFF3A3A40);
  Color get navBarPressed => const Color(0xFF606060);
  Color get appGrey => const Color(0xFF4A4A50);

  // Card & Container
  Color get card => const Color(0xFF1E2228);
  Color get cardShadow => const Color(0x1AFFFFFF);

  // Input fields
  Color get inputFill => const Color(0xFF1E2228);
  Color get inputBorder => const Color(0xFF2E3338);
  Color get inputFocusBorder => const Color(0xFF4A90D9);

  // Icon colors
  Color get iconPrimary => const Color(0xFF4A90D9);
  Color get iconSecondary => const Color(0xFFB0B0B0);
}
