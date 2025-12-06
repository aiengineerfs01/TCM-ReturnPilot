import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarHelper {
  static void showError(String message, {String title = 'Error'}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.redAccent.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      icon: const Icon(Icons.error_outline, color: Colors.white, size: 28),
      duration: const Duration(seconds: 3),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInCubic,
      isDismissible: true,
      mainButton: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Dismiss', style: TextStyle(color: Colors.white70)),
      ),
    );
  }

  static void showSuccess(String message, {String title = 'Success'}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      icon: const Icon(
        Icons.check_circle_outline,
        color: Colors.white,
        size: 28,
      ),
      duration: const Duration(seconds: 3),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInCubic,
      isDismissible: true,
    );
  }
}
