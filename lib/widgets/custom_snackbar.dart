import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AppSnackBar {
  static void show({
    required String title,
    required String message,
    Color backgroundColor = Colors.redAccent,
    Color textColor = Colors.white,
    SnackPosition position = SnackPosition.BOTTOM,
    int durationMs = 2000,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: backgroundColor.withOpacity(0.8),
      colorText: textColor,
      duration: Duration(milliseconds: durationMs),
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
    );
  }
}
