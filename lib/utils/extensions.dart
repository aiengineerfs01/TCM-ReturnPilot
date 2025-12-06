import 'package:flutter/foundation.dart';

extension FileExtension on String {
  String get fileExt {
    if (!contains('.')) return "";
    return split('.').last.toLowerCase();
  }
}

extension DebugLog on Object {
  void logDebug([String? prefix]) {
    if (kDebugMode) {
      // Only prints in debug mode — never in release mode
      // Adds optional prefix for cleaner logs
      // Example: user.logDebug("USER DATA");
      if (prefix != null) {
        // ignore: avoid_print
        print("$prefix: $this");
      } else {
        // ignore: avoid_print
        print(this);
      }
    }
  }
}
