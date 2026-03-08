import 'package:flutter/material.dart';
import 'package:tcm_return_pilot/utils/snackbar.dart';

class AppSnackBar {
  static void show({
    required String title,
    required String message,
    Color backgroundColor = Colors.redAccent,
    Color textColor = Colors.white,
    int durationMs = 2000,
  }) {
    if (backgroundColor == Colors.redAccent || backgroundColor == Colors.red) {
      SnackbarHelper.showError(message, title: title);
    } else {
      SnackbarHelper.showSuccess(message, title: title);
    }
  }
}
