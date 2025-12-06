import 'package:flutter/material.dart';
import 'package:tcm_return_pilot/domain/theme/app_theme.dart';

import 'package:pinput/pinput.dart'; // if you’re using the Pinput package

class AppPinThemes {
  static PinTheme defaultTheme(BuildContext context) => PinTheme(
    width: 50,
    height: 50,
    textStyle: AppTheme.of(context).titleMedium,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppTheme.of(context).accent3),
    ),
  );

  static PinTheme focusedTheme(BuildContext context) => PinTheme(
    width: 50,
    height: 50,
    textStyle: AppTheme.of(context).titleMedium,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppTheme.of(context).primary, width: 2),
    ),
  );

  static PinTheme submittedTheme(BuildContext context) => PinTheme(
    width: 50,
    height: 50,
    textStyle: AppTheme.of(context).titleMedium,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppTheme.of(context).primary),
    ),
  );
}
